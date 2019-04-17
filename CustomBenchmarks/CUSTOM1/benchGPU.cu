#include <stdio.h>
#include <stdlib.h>
#include <cuda.h>

#include <iostream>

#define BLOCK_SIZE 512

#define checkCuda(ans) { gpuAssert((ans), __FILE__, __LINE__); }
inline void gpuAssert(cudaError_t code, const char *file, int line, bool abort=true)
{
   if (code != cudaSuccess) {
      fprintf(stdout,"GPUassert: %s %s %d\n", cudaGetErrorString(code), file, line);
      if (abort) exit(code);
   }
}

#define SET_SIZE 64
#define LINE_SIZE 128
#define STRIDE LINE_SIZE*SET_SIZE

__global__ void kernel(char *out, char *in, int size) {
    long tid = threadIdx.x + blockIdx.x * blockDim.x;
    if (tid < size) out[tid] = in[(tid*STRIDE)%size];
}

void benchmark(char *out_host, char *in_host, int size) {
    char *out_gpu, *in_gpu;

    // Allocate arrays in GPU memory
    checkCuda(cudaMalloc((void**)&(out_gpu), size*sizeof(char)));
    checkCuda(cudaMalloc((void**)&(in_gpu), size*sizeof(char)));

    // Copy input to GPU
    checkCuda(cudaMemcpy(in_gpu, in_host, size*sizeof(char), cudaMemcpyHostToDevice));

    dim3 dimGrid(1+(size-1)/BLOCK_SIZE);
    dim3 dimBlock(BLOCK_SIZE);

    // Execute kernel
    kernel<<<dimGrid, dimBlock>>>(out_gpu, in_gpu, size);

    // Print any errors that may have occured in kernel
    checkCuda(cudaPeekAtLastError());

    // Retrieve results from the GPU
    checkCuda(cudaMemcpy(out_host, out_gpu, size*sizeof(char), cudaMemcpyDeviceToHost));

    // Free resources and end the program
    checkCuda(cudaFree(out_gpu));
    checkCuda(cudaFree(in_gpu));
}
