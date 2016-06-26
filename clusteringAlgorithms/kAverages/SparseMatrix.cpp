#include "SparseMatrix.h"
#include <assert.h>
#include <stdio.h>



SparseMatrix::SparseMatrix (int nbLines, int nbColumns, flt **fullMatrix, flt threshold) {
  this->nbLines = nbLines;
  this->nbColumns = nbColumns;
  lines = new SparseVector* [nbLines];
  for (int i=0; i<nbLines; i++)
    lines[i] = new SparseVector(nbColumns, fullMatrix[i], threshold);
}

SparseMatrix::SparseMatrix (int nbLines, int nbColumns) {
  this->nbLines = nbLines;
  this->nbColumns = nbColumns;
  lines = new SparseVector* [nbLines];
  for (int i=0; i<nbLines; i++)
    lines[i] = new SparseVector();
}

SparseMatrix::SparseMatrix(int nbLines, int nbColumns, size_t *ir, size_t *jc, flt *pr) {
  //fprintf(stderr, "\n%i, %i, %p, %p, %p\n", nbLines, nbColumns, ir, jc, pr);
  this->nbLines = nbLines;
  this->nbColumns = nbColumns;
  lines = new SparseVector* [nbLines];
  for (int i=0; i<nbLines; i++) {
    lines[i] = new SparseVector(jc[i+1]-jc[i], ir+jc[i], pr+jc[i]);
  }
}

SparseMatrix::SparseMatrix (const char *fileName, flt threshold) {
  FILE *fin = fopen(fileName, "r");
  if (!fin) ERROR ("Could not open file '%s' for reading.", fileName);
  if (fscanf(fin, "Sparse matrix, %i lines, %i columns", &(this->nbLines), &(this->nbColumns)) != 2)
    ERROR ("Syntax error in header of matrix file '%s'.", fileName);
  lines = new SparseVector* [nbLines];
  flt *line = new flt [nbColumns];
  for (int i=0; i<nbLines; i++) {
    for (int j=0; j<nbColumns; j++)
      if (fscanf(fin, "%g", &(line[j])) != 1)
	ERROR ("Error while reading matrix file '%s'.", fileName);
    lines[i] = new SparseVector(nbColumns, line, threshold);
  }   
}

SparseMatrix::~SparseMatrix() {
  for (int i=0; i<nbLines; i++)
    delete lines[i];
  delete[] lines;
}

void SparseMatrix::setLine (int lineNumber, flt *line, flt threshold) {
  assert(lineNumber>=0 && lineNumber<nbLines);
  lines[lineNumber]->setContents(nbColumns, line, threshold);
}

SparseVector *SparseMatrix::getLine (int lineNumber) {
  assert(lineNumber>=0 && lineNumber<nbLines);
  return lines[lineNumber];
}


flt SparseMatrix::getValue (int line, int column) {
  assert(line>=0 && line<nbLines && column>=0 && column<nbColumns);
  return lines[line]->get(column);
}

flt SparseMatrix::getDensity () {
  double total = (double)nbLines*(double)nbColumns;
  double actual = 0;
  for (int i=0; i<nbLines; i++) 
    actual += lines[i]->getNbValues();
  return (flt)(actual/total);
}
