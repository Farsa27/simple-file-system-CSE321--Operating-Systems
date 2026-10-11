CC      = gcc
CFLAGS  = -Wall -Wextra -std=c11

all: simplefs_builder simplefs_adder

simplefs_builder: src/simplefs_builder.c src/simplefs.h
	$(CC) $(CFLAGS) src/simplefs_builder.c -o $@

simplefs_adder: src/simplefs_adder.c src/simplefs.h
	$(CC) $(CFLAGS) src/simplefs_adder.c -o $@

clean:
	rm -f simplefs_builder simplefs_adder *.img

.PHONY: all clean
