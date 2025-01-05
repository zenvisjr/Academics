#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <string.h>

#define NUM_ALLOCS 10
#define SMALL_OBJ_SIZE 64

extern void init_allocator();
extern void* my_malloc(size_t size);
extern void* my_calloc(size_t num, size_t size);
extern void* my_realloc(void* ptr, size_t new_size);
extern void my_free(void* ptr);

// Function to measure allocation speed
// Function to measure allocation speed
double benchmark_allocation_speed(void *(*alloc_func)(size_t), void (*free_func)(void *)) {
    clock_t start, end;
    void *ptrs[NUM_ALLOCS];
    start = clock();
    
    for (int i = 0; i < NUM_ALLOCS; ++i) {
        ptrs[i] = alloc_func(SMALL_OBJ_SIZE);
        if (ptrs[i] == NULL) {
            fprintf(stderr, "Memory allocation failed at iteration %d\n", i);
            return -1;  // Exit gracefully if allocation fails
        }
    }

    for (int i = 0; i < NUM_ALLOCS; ++i) {
        free_func(ptrs[i]);
    }

    end = clock();
    return ((double)(end - start)) / CLOCKS_PER_SEC;
}

// Function to measure memory fragmentation (simplified)
size_t measure_fragmentation(void *(*alloc_func)(size_t), void (*free_func)(void *)) {
    void *ptrs[NUM_ALLOCS];
    size_t total_free_memory = 0;

    // Allocate memory
    for (int i = 0; i < NUM_ALLOCS; ++i) {
        ptrs[i] = alloc_func(SMALL_OBJ_SIZE);
        if (ptrs[i] == NULL) {
            fprintf(stderr, "Memory allocation failed at iteration %d\n", i);
            return -1;  // Exit gracefully if allocation fails
        }
    }

    // Free every other block to simulate fragmentation
    for (int i = 0; i < NUM_ALLOCS; i += 2) {
        free_func(ptrs[i]);
        total_free_memory += SMALL_OBJ_SIZE;
    }

    // Measure fragmentation by freeing remaining blocks
    for (int i = 1; i < NUM_ALLOCS; i += 2) {
        free_func(ptrs[i]);
    }

    // Simplified fragmentation metric
    return total_free_memory;
}


// Function to average results from 3 runs
double average(double (*benchmark_func)(void *(*alloc_func)(size_t), void (*free_func)(void *)), void *(*alloc_func)(size_t), void (*free_func)(void *)) {
    double total = 0;
    for (int i = 0; i < 3; ++i) {
        total += benchmark_func(alloc_func, free_func);
    }
    return total / 3.0;
}

size_t average_fragmentation(size_t (*fragmentation_func)(void *(*alloc_func)(size_t), void (*free_func)(void *)), void *(*alloc_func)(size_t), void (*free_func)(void *)) {
    size_t total = 0;
    for (int i = 0; i < 3; ++i) {
        total += fragmentation_func(alloc_func, free_func);
    }
    return total / 3;
}

int main() {
    double std_alloc_speed, custom_alloc_speed, std_calloc_speed, custom_calloc_speed;
    double std_realloc_speed, custom_realloc_speed;
    size_t std_fragmentation, custom_fragmentation, std_calloc_fragmentation, custom_calloc_fragmentation;
    size_t std_realloc_fragmentation, custom_realloc_fragmentation;

    // Initialize custom allocator
    init_allocator();

    // Benchmark standard malloc, my_malloc, calloc, my_calloc, realloc, and my_realloc for allocation speed and fragmentation
    std_alloc_speed = average(benchmark_allocation_speed, malloc, free);
    custom_alloc_speed = average(benchmark_allocation_speed, my_malloc, my_free);
    std_calloc_speed = average(benchmark_allocation_speed, calloc, free);
    custom_calloc_speed = average(benchmark_allocation_speed, my_calloc, my_free);
    std_realloc_speed = average(benchmark_allocation_speed, realloc, free);
    custom_realloc_speed = average(benchmark_allocation_speed, my_realloc, my_free);

    std_fragmentation = average_fragmentation(measure_fragmentation, malloc, free);
    custom_fragmentation = average_fragmentation(measure_fragmentation, my_malloc, my_free);
    std_calloc_fragmentation = average_fragmentation(measure_fragmentation, calloc, free);
    custom_calloc_fragmentation = average_fragmentation(measure_fragmentation, my_calloc, my_free);
    std_realloc_fragmentation = average_fragmentation(measure_fragmentation, realloc, free);
    custom_realloc_fragmentation = average_fragmentation(measure_fragmentation, my_realloc, my_free);

    // Display results
    printf("Average Standard Alloc Speed (malloc): %.6f sec\n", std_alloc_speed);
    printf("Average Custom Alloc Speed (my_malloc): %.6f sec\n", custom_alloc_speed);
    printf("Average Standard Alloc Speed (calloc): %.6f sec\n", std_calloc_speed);
    printf("Average Custom Alloc Speed (my_calloc): %.6f sec\n", custom_calloc_speed);
    printf("Average Standard Alloc Speed (realloc): %.6f sec\n", std_realloc_speed);
    printf("Average Custom Alloc Speed (my_realloc): %.6f sec\n", custom_realloc_speed);

    printf("Average Standard Fragmentation (malloc): %zu\n", std_fragmentation);
    printf("Average Custom Fragmentation (my_malloc): %zu\n", custom_fragmentation);
    printf("Average Standard Fragmentation (calloc): %zu\n", std_calloc_fragmentation);
    printf("Average Custom Fragmentation (my_calloc): %zu\n", custom_calloc_fragmentation);
    printf("Average Standard Fragmentation (realloc): %zu\n", std_realloc_fragmentation);
    printf("Average Custom Fragmentation (my_realloc): %zu\n", custom_realloc_fragmentation);

    printf("Allocation Speed Improvement (my_malloc vs malloc): %.2f%%\n", ((std_alloc_speed - custom_alloc_speed) / std_alloc_speed) * 100);
    printf("Allocation Speed Improvement (my_calloc vs calloc): %.2f%%\n", ((std_calloc_speed - custom_calloc_speed) / std_calloc_speed) * 100);
    printf("Allocation Speed Improvement (my_realloc vs realloc): %.2f%%\n", ((std_realloc_speed - custom_realloc_speed) / std_realloc_speed) * 100);

    printf("Fragmentation Reduction (my_malloc vs malloc): %.2f%%\n", ((std_fragmentation - custom_fragmentation) / std_fragmentation) * 100);
    printf("Fragmentation Reduction (my_calloc vs calloc): %.2f%%\n", ((std_calloc_fragmentation - custom_calloc_fragmentation) / std_calloc_fragmentation) * 100);
    printf("Fragmentation Reduction (my_realloc vs realloc): %.2f%%\n", ((std_realloc_fragmentation - custom_realloc_fragmentation) / std_realloc_fragmentation) * 100);

    return 0;
}
