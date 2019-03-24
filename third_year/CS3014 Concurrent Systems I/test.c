#include <stdalign.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

#define ARRAY_SIZE 10

int main(char** argv, int argc) {

	int16_t a = 10;
	printf("The align of int16_t is: %d\n", alignof(int16_t));

	size_t i;

	int16_t test1[ARRAY_SIZE];
	int16_t test2[ARRAY_SIZE] __attribute__ ((aligned (16)));

	for( i = 0; i<ARRAY_SIZE; i++){
		printf("test1[%u] = %p\n", i, &test1[i]);
		printf("test2[%u] = %p\n", i, &test2[i]);
	}
}