CC=gcc
CFLAGS=-std=c99 -c -Wall -O3
LDFLAGS= -lm

all: kaverages kkmeans naive_kkmeans txtMatrixToBinary generateMatrix agreement generateInit

kaverages : kaverages.o utils.o
	$(CC) kaverages.o utils.o -o kaverages  $(LDFLAGS)

kkmeans : kkmeans.o utils.o
	$(CC) kkmeans.o utils.o -o kkmeans $(LDFLAGS) 

naive_kkmeans : naive_kkmeans.o utils.o
	$(CC) naive_kkmeans.o utils.o -o naive_kkmeans $(LDFLAGS) 

agreement : agreement.o utils.o
	$(CC) agreement.o utils.o -o agreement $(LDFLAGS) 

generateInit : generateInit.o utils.o
	$(CC) generateInit.o utils.o -o generateInit $(LDFLAGS) 

txtMatrixToBinary : txtMatrixToBinary.o utils.o
	$(CC) txtMatrixToBinary.o utils.o -o txtMatrixToBinary $(LDFLAGS)

generateMatrix : generateMatrix.o utils.o
	$(CC) generateMatrix.o utils.o -o generateMatrix $(LDFLAGS)

.c.o:
	$(CC) $(CFLAGS) $< -o $@

clean:
	rm -rf *.o
