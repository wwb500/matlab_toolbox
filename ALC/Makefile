CC=g++
CFLAGS=-c -Wall -O3 -funroll-loops -ffast-math
LDFLAGS= -lm

all: alc test

alc : main.o global.o ALC.o AlcLevel.o AlcConfig.o
	$(CC) main.o global.o ALC.o AlcLevel.o AlcConfig.o -o alc  $(LDFLAGS)

test : test.o global.o
	$(CC) test.o global.o -o test  $(LDFLAGS)

.c.o:
	$(CC) $(CFLAGS) $< -o $@

.cpp.o:
	$(CC) $(CFLAGS) $< -o $@

clean:
	rm *.o alc
