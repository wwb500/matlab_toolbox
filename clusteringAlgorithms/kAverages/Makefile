CPP      = g++ 
OPTIMIZE = -O3 -ffast-math -fomit-frame-pointer -march=native -mfpmath=sse
#OPTIMIZE = -g

all: kaverages

kaverages: main.o SparseVector.o SparseMatrix.o Object.o Class.o stuff.o kaverages.o
	$(CPP) $(OPTIMIZE) -lm -o kaverages_test kaverages.o main.o SparseVector.o SparseMatrix.o Object.o Class.o stuff.o

main.o: main.cpp stuff.h Object.h Class.h SparseMatrix.h SparseMatrix.h kaverages.h
	$(CPP) -c $(OPTIMIZE) -lm -o main.o main.cpp

kaverages.o: kaverages.cpp stuff.h Object.h Class.h SparseMatrix.h SparseMatrix.h
	$(CPP) -c $(OPTIMIZE) -lm -o kaverages.o kaverages.cpp

stuff.o: stuff.cpp stuff.h Object.h Class.h SparseMatrix.h SparseMatrix.h
	$(CPP) -c $(OPTIMIZE) -lm -o stuff.o stuff.cpp

Object.o: Object.cpp stuff.h Object.h Class.h SparseMatrix.h SparseMatrix.h
	$(CPP) -c $(OPTIMIZE) -lm -o Object.o Object.cpp

Class.o: Class.cpp stuff.h Object.h Class.h SparseMatrix.h SparseMatrix.h
	$(CPP) -c $(OPTIMIZE) -lm -o Class.o Class.cpp

SparseMatrix.o: SparseMatrix.cpp stuff.h Object.h Class.h SparseMatrix.h SparseMatrix.h
	$(CPP) -c $(OPTIMIZE) -lm -o SparseMatrix.o SparseMatrix.cpp

SparseVector.o: SparseVector.cpp stuff.h Object.h Class.h SparseMatrix.h SparseMatrix.h
	$(CPP) -c $(OPTIMIZE) -lm -o SparseVector.o SparseVector.cpp

clean:
	rm -f *.o 

realclean: clean
	rm -f kaverages kaverages_test kaverages.mex*
