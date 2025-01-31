#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>

#define CACHE_SIZE 1024  // Adjusted for IoT optimization
#define BLOCK_SIZE 16     // Smaller blocks for energy efficiency
#define ASSOCIATIVITY 2   // Reduced complexity for low-power devices

typedef struct {
    uint32_t tag;
    uint8_t data[BLOCK_SIZE];
    bool valid;
    bool dirty;
} CacheBlock;

CacheBlock cache[CACHE_SIZE / BLOCK_SIZE][ASSOCIATIVITY];

uint32_t access_memory(uint32_t address, bool write, uint8_t data) {
    uint32_t index = (address / BLOCK_SIZE) % (CACHE_SIZE / BLOCK_SIZE);
    uint32_t tag = address / CACHE_SIZE;
    int hit = -1;

    for (int i = 0; i < ASSOCIATIVITY; i++) {
        if (cache[index][i].valid && cache[index][i].tag == tag) {
            hit = i;
            break;
        }
    }

    if (hit != -1) { // Cache hit
        if (write) {
            cache[index][hit].data[address % BLOCK_SIZE] = data;
            cache[index][hit].dirty = true;
        }
        return cache[index][hit].data[address % BLOCK_SIZE];
    } else { // Cache miss
        int evict = rand() % ASSOCIATIVITY; // Random replacement policy for simplicity
        
        if (cache[index][evict].dirty) {
            // Write back to memory before replacement
            printf("Writing back dirty block before replacement\n");
        }

        cache[index][evict].tag = tag;
        cache[index][evict].valid = true;
        cache[index][evict].dirty = false;
        
        if (write) {
            cache[index][evict].data[address % BLOCK_SIZE] = data;
            cache[index][evict].dirty = true;
        }

        return cache[index][evict].data[address % BLOCK_SIZE];
    }
}

int main() {
    printf("Initializing IoT-optimized cache system...\n");
    for (int i = 0; i < CACHE_SIZE / BLOCK_SIZE; i++) {
        for (int j = 0; j < ASSOCIATIVITY; j++) {
            cache[i][j].valid = false;
            cache[i][j].dirty = false;
        }
    }
    return 0;
}
