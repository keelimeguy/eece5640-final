####################################################################
####################################################################
## READ this:                                                     ##
##   https://pfzuo.github.io/2019/01/09/Install-and-Run-GPGPUSim/ ##
####################################################################
####################################################################

SHELL := /bin/bash # Use bash syntax
CUR_DIR = $(shell pwd)

all: gpusim

##############################
# Make rules for gcc version #
##############################

check-gcc:
	@gcc -v 2>&1| grep -q 'gcc version 4.4' && echo 'gcc version OK' \
	  || (echo 'gcc-4.4 is required' && exit 1)

	@g++ -v 2>&1| grep -q 'gcc version 4.4' && echo 'g++ version OK' \
	  || (echo 'g++-4.4 is required' && exit 1)

# From https://pfzuo.github.io/2019/01/09/Install-and-Run-GPGPUSim/:
# 	sudo update-alternatives --config gcc
# 	sudo update-alternatives --config g++

##############################
# Make rules for gpusim tool #
##############################

gpusim: .dummy

.dummy: check-gcc gpgpu-sim_distribution/.dummy gpu-cache.cc gpu-cache.h
ifndef CUDA_INSTALL_PATH
	$(error CUDA_INSTALL_PATH is not set, try `sudo make cuda` then set environment variables appropriately.)
endif

	@which makedepend 2>&1| grep -q 'no makedepend in' \
	 && echo 'Missing dependency: try `apt-cache search makedepend`' && exit 1 || echo ''

	@cp gpu-cache.cc gpgpu-sim_distribution/src/gpgpu-sim/gpu-cache.cc
	@cp gpu-cache.h gpgpu-sim_distribution/src/gpgpu-sim/gpu-cache.h
	@cd gpgpu-sim_distribution \
	 && source setup_environment \
	 && make

	touch .dummy

clean-gpusim:
	rm .dummy

#############################
# Make rules for benchmarks #
#############################

CUDA_SDK_DIR=~/NVIDIA_GPU_Computing_SDK

benchmarks: check-gcc ispass2009-benchmarks/.dummy
	@if [ ! -e ${CUDA_SDK_DIR} ]; then \
		echo "${CUDA_SDK_DIR} is not found)" | exit 1; \
	fi

	-@cd ${CUDA_SDK_DIR}/C \
	 && make

	@cd ispass2009-benchmarks \
	 && make -f Makefile.ispass-2009


clean-benchmarks:
	@cd ispass2009-benchmarks \
	 && make clean -f Makefile.ispass-2009

############################
# Make rules for git repos #
############################

repos: ispass2009-benchmarks/.dummy gpgpu-sim_distribution/.dummy

ispass2009-benchmarks/.dummy:
	@if [ ! -d "ispass2009-benchmarks" ]; then \
		git clone https://github.com/gpgpu-sim/ispass2009-benchmarks.git; \
		cd ispass2009-benchmarks \
		 && git checkout 1716296b22bc78acdef08fb46a338f36f9dd4b96; \
		sed -i "s/.*boost_filesystem.*/LINKFLAGS      := -L\$(BOOST_LIB) -lboost_filesystem\$(BOOST_VER) -lboost_system\$(BOOST_VER)/g" ${CUR_DIR}/ispass2009-benchmarks/AES/Makefile; \
		sed -i "s/CUT_EXIT.*/\/\/&/g" ${CUR_DIR}/ispass2009-benchmarks/LIB/libor.cu; \
		sed -i "s/CUT_EXIT.*/\/\/&/g" ${CUR_DIR}/ispass2009-benchmarks/LPS/laplace3d.cu; \
		sed -i "s|../../../bin/release/|../bin/release/|g" ${CUR_DIR}/ispass2009-benchmarks/STO/README.GPGPU-Sim; \
		sed -i "s|../../../bin/release/|../bin/release/|g" ${CUR_DIR}/ispass2009-benchmarks/WP/README.GPGPU-Sim; \
		sed -i "s/\$(CFLAGS) -/-fPIC \$(CFLAGS) -/g" ${CUR_DIR}/ispass2009-benchmarks/WP/makefile; \
	fi

	touch ispass2009-benchmarks/.dummy

gpgpu-sim_distribution/.dummy:
	@if [ ! -d "gpgpu-sim_distribution" ]; then \
		git clone https://github.com/gpgpu-sim/gpgpu-sim_distribution.git; \
		cd gpgpu-sim_distribution \
		 && git checkout 7cd0edfe0cb654280c30afef89a563867d9e67ed; \
		sed -i '105ireturn false;' ${CUR_DIR}/gpgpu-sim_distribution/src/option_parser.cc; \
		sed -i '105i} catch (...) {' ${CUR_DIR}/gpgpu-sim_distribution/src/option_parser.cc; \
	fi

	touch gpgpu-sim_distribution/.dummy

clean-repos:
	rm gpgpu-sim_distribution/.dummy
	rm ispass2009-benchmarks/.dummy

#############################
# Make rules for cuda tools #
#############################

cuda: cuda_install/.dummy

cuda_install/.dummy:
	@mkdir -p cuda_install

	@ls /root 2>/dev/null || (echo 'Try running `sudo make cuda` instead.' && exit 1)

	@echo "Installing cudatoolkit_4.0.17"
	@if [ ! -f "cuda_install/cudatoolkit_4.0.17_linux_64_ubuntu10.10.run" ]; then \
		cd cuda_install \
		 && wget http://developer.download.nvidia.com/compute/cuda/4_0/toolkit/cudatoolkit_4.0.17_linux_64_ubuntu10.10.run \
		 && chmod +x ./cudatoolkit_4.0.17_linux_64_ubuntu10.10.run; \
	fi
	@cd cuda_install \
	 && ./cudatoolkit_4.0.17_linux_64_ubuntu10.10.run --confirm || echo ''

	# @echo "Installing devdriver_4.0"
	# @if [ ! -f "cuda_install/devdriver_4.0_linux_64_270.41.19.run" ]; then \
	# 	cd cuda_install \
	# 	 && wget http://developer.download.nvidia.com/compute/cuda/4_0/drivers/devdriver_4.0_linux_64_270.41.19.run \
	# 	 && chmod +x ./devdriver_4.0_linux_64_270.41.19.run; \
	# fi
	# @echo -n "About to run driver installer ... Proceed ? [y/N] " && read ans && [ $${ans:-N} == y ] \
	# 	&& cd cuda_install \
	# 	&& ./devdriver_4.0_linux_64_270.41.19.run --ui=none --no-runlevel-check || echo '';\

	@echo "Installing gpucomputingsdk_4.0.17"
	@if [ ! -f "cuda_install/gpucomputingsdk_4.0.17_linux.run" ]; then \
		cd cuda_install \
		 && wget http://developer.download.nvidia.com/compute/cuda/4_0/sdk/gpucomputingsdk_4.0.17_linux.run \
		 && chmod +x ./gpucomputingsdk_4.0.17_linux.run; \
	fi
	@cd cuda_install \
	 && ./gpucomputingsdk_4.0.17_linux.run --confirm || echo ''

	touch cuda_install/.dummy

clean-cuda:
	rm cuda_install/.dummy
