#/bin/bash

CUR_DIR=`pwd`

GPGPUSIM_DIR=${CUR_DIR}/gpusim/gpgpu-sim_distribution
BENCHMARK_DIR=${CUR_DIR}/gpusim/ispass2009-benchmarks
OUTPUT_DIR=${CUR_DIR}/output
CONFIG_DIR=${CUR_DIR}/configurations

CONFIG_FILE=${CONFIG_DIR}/gpgpusim.config
CONFIG_INTERCONNECT=${CONFIG_DIR}/config_fermi_islip.icnt
CONFIG_ENERGY_MODEL=${CONFIG_DIR}/gpuwattch_gtx480.xml

for dir in ${GPGPUSIM_DIR} ${CONFIG_DIR} ${BENCHMARK_BIN_DIR}; do
    if [ ! -d "${dir}" ]; then
        echo ${dir}' not found'
        exit 1
    fi
done

cd ${GPGPUSIM_DIR}/..
make gpusim || exit 1

source ${GPGPUSIM_DIR}/setup_environment

# Testing 4 indexing techniques: (L=linear, S=simple XOR, P=psuedo random interleaving, F=fermi hash set)
for set_index_fn in F P S L; do

    # Four cache configurations per technique: (fifo32, fifo64, lru32, lru64)
    assoc=4
    shmem_size=49152
    for nsets in 32 64; do
        if [ ${nsets} -eq 64 ]; then
            assoc=6
            shmem_size=16384
        fi

        # L=LRU, F=FIFO
        for replace_policy in L F; do

            sed -i "s/-gpgpu_cache:dl1 .*/-gpgpu_cache:dl1 ${nsets}:128:${assoc},${replace_policy}:L:m:N:${set_index_fn},A:32:8,8/g" ${CONFIG_FILE}
            sed -i "s/-gpgpu_shmem_size .*/-gpgpu_shmem_size ${shmem_size}/g" ${CONFIG_FILE}

            cd ${BENCHMARK_DIR}
            BENCHMARKS=`ls -1 -F | awk '/\//' | sed 's/\///'`;

            for BMK in ${BENCHMARKS}; do
                if [ -f ${BENCHMARK_DIR}/${BMK}/README.GPGPU-Sim ]; then

                    # The DG benchmark triggered my network firewall so I'm just gonna skip it
                    if [ ! "${BMK}" == "DG" ]; then

                        # Link configuration files
                        ln -v -s -f ${CONFIG_FILE} ${BENCHMARK_DIR}/$BMK
                        ln -v -s -f ${CONFIG_INTERCONNECT} ${BENCHMARK_DIR}/$BMK
                        ln -v -s -f ${CONFIG_ENERGY_MODEL} ${BENCHMARK_DIR}/$BMK

                        cd ${BENCHMARK_DIR}/$BMK

                        # Run benchmark
                        sh README.GPGPU-Sim 2>&1| tee ${OUTPUT_DIR}/out_${BMK}_${replace_policy}${nsets}_${set_index_fn}.txt \
                          || exit 1

                    fi
                fi

            done
        done

    done
done
