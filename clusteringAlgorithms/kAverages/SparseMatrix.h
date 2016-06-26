#include "stuff.h"
#include "SparseVector.h"

#ifndef SPARSE_MATRIX_H
#define SPARSE_MATRIX_H

class SparseMatrix {
    
public:
    SparseMatrix(int nbLines, int nbColumns);
    SparseMatrix(int nbLines, int nbColumns, flt **fullMatrix, flt threshold=0);
    SparseMatrix(int nbLines, int nbColumns, size_t *ir, size_t *jc, flt *pr);
    SparseMatrix(const char *fileName, flt threshold=0);
    
    ~SparseMatrix();
    
    void setLine(int lineNumber, flt *line, flt threshold=0);
    
    SparseVector *getLine(int lineNumber);
    
    flt getValue(int line, int column);
    
    flt getDensity();
    
private:
    
    int nbLines;
    int nbColumns;
    SparseVector **lines;
    
};

#endif
