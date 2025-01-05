// main.c

#include <stdio.h>
#include <string.h>

// Declare the custom memory allocation functions
extern void init_allocator();
extern void* my_malloc(size_t size);
extern void* my_calloc(size_t num, size_t size);
extern void* my_realloc(void* ptr, size_t new_size);
extern void my_free(void* ptr);

int main() {
    // Initialize the custom memory allocator
    init_allocator();
    printf("Memory allocator initialized\n");

    // Test my_malloc
    printf("\nTesting my_malloc:\n");
    int* arr = (int*)my_malloc(5 * sizeof(int));
    if (arr) {
        printf("my_malloc succeeded, address: %p\n", (void*)arr);
        for (int i = 0; i < 5; i++) {
            arr[i] = i + 1;
        }
        for (int i = 0; i < 5; i++) {
            printf("%d ", arr[i]);
        }
        printf("\n");
    } else {
        printf("my_malloc failed\n");
    }

    // Test my_calloc
    printf("\nTesting my_calloc:\n");
    int* carr = (int*)my_calloc(5, sizeof(int));
    if (carr) {
        printf("my_calloc succeeded, address: %p\n", (void*)carr);
        for (int i = 0; i < 5; i++) {
            printf("%d ", carr[i]);
        }
        printf("\n");
    } else {
        printf("my_calloc failed\n");
    }

    // Test my_realloc
    printf("\nTesting my_realloc:\n");
    arr = (int*)my_realloc(arr, 10 * sizeof(int));
    if (arr) {
        printf("my_realloc succeeded, new address: %p\n", (void*)arr);
        for (int i = 5; i < 10; i++) {
            arr[i] = i + 1;
        }
        for (int i = 0; i < 10; i++) {
            printf("%d ", arr[i]);
        }
        printf("\n");
    } else {
        printf("my_realloc failed\n");
    }

    // Test my_free
    printf("\nTesting my_free:\n");
    my_free(arr);
    my_free(carr);
    printf("Memory freed\n");

    // Allocate and free again to test if the freed memory can be reused
    printf("\nTesting reallocation after free:\n");
    char* str = (char*)my_malloc(20);
    if (str) {
        printf("Reallocation succeeded, address: %p\n", (void*)str);
        strcpy(str, "Hello, World!");
        printf("%s\n", str);
        my_free(str);
    } else {
        printf("Reallocation failed\n");
    }

    return 0;
}