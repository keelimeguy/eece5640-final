#include <iostream>
#include <cstdlib>
#include <ctime>

extern void benchmark(char *out_host, char *in_host, int size);

#define SIZE 294912

int main() {
    // Allocate array
    char *input = (char*) malloc(SIZE*sizeof(char));
    char *output = (char*) malloc(SIZE*sizeof(char));

    // Seed random number generator
    srand(time(0));

    // Randomize input
    for (int i = 0; i < SIZE; ++i)
        input[i] = (char)rand();

    std::cout << "Begin." << std::endl;

    // Run GPU benchmark
    benchmark(output, input, SIZE);

    std::cout << "Done." << std::endl;

    // Free alocated memory
    free(input);
    free(output);

    return 0;
}
