CC = gcc
BIN = conv-harness
SRC = conv-harness.c

CFLAGS = -O3 -msse4 -fopenmp

$(BIN) : $(SRC)
	$(CC) $(CFLAGS) $^ -o $@