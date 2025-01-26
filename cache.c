/*
Mystery Cache Geometries:
mystery0:
    block size =  64 bytes
    cache size = 4194304 bytes
    associativity = 16
mystery1:
    block size = 4 bytes
    cache size = 4096 bytes
    associativity = 1
mystery2:
    block size = 32 bytes
    cache size = 4096 bytes
    associativity = 128
*/
#include <stdlib.h>
#include <stdio.h>
#include "mystery-cache.h"
/*
   Returns the size (in B) of the cache.
*/
int get_cache_size(int block_len) {
  flush_cache();
  access_cache(0);

  int curr_step = 0;
  int max_bound = block_len;

  while (access_cache(0)) 
  {
    curr_step = block_len;
    int curr_offset = block_len;
    while (curr_offset <= max_bound) {
      curr_step = curr_offset;
      access_cache(curr_offset);
      curr_offset += block_len;
    }
    max_bound += block_len;
  }
  return curr_step;
}
/*
   Returns the associativity of the cache.
*/
int get_cache_assoc(int cache_size) {
  flush_cache();
  access_cache(0);
  int curr_pos = 0;
  int max_limit = 1;
  int ways = 0;
  while (access_cache(0)) 
  {
    ways = 0;
    curr_pos = cache_size;
    while (curr_pos <= max_limit) 
    {
      ways++;
      access_cache(curr_pos);
      curr_pos += cache_size;
    }
    max_limit += cache_size;
  }
  return ways;
}
/*
   Returns the size (in B) of each block in the cache.
*/
int get_block_size(void) {
  flush_cache();
  access_cache(0);
  int block_len = 0;
  while(access_cache(block_len)) 
  {
    block_len++;
  }
  return block_len;
}
int main(void) {
  int cache_size;
  int ways;
  int block_len;
  
  /* The cache needs to be initialized, but the parameters will be
     ignored by the mystery caches, as they are hard coded.
     You can test your geometry paramter discovery routines by 
     calling cache_init() w/ your own size and block size values. */
  cache_init(0,0);
  
  block_len = get_block_size();
  cache_size = get_cache_size(block_len);
  ways = get_cache_assoc(cache_size);
  printf("Cache size: %d bytes\n", cache_size);
  printf("Cache associativity: %d\n", ways);
  printf("Cache block size: %d bytes\n", block_len);
  
  return EXIT_SUCCESS;
}
