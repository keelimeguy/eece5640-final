# EECE5640 Final
  Using gpgpu-sim to explore set indexing on GPU caches

### Please review these files before running them:
  ./run.sh  
  ./gpusim/Makefile

### There will likely be dependencies you are missing:
  https://pfzuo.github.io/2019/01/09/Install-and-Run-GPGPUSim/


## Usage

### Install CUDA 4:
`cd ./gpusim && sudo make cuda`

Pay attention to the output telling you how to set your environment:
* Please make sure your PATH includes /usr/local/cuda/bin
* Please make sure your LD_LIBRARY_PATH includes /usr/local/cuda/lib

### Compile the rest of everything:
`cd ./gpusim && make`

### Run the analysis:
`./run.sh`
