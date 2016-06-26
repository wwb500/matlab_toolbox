#include "SparseVector.h"
#include <string.h>
#include <assert.h>

SparseVector::SparseVector() {
  indices = NULL;
  values = NULL;
  nbValues = 0;
}

SparseVector::~SparseVector() {
  delete[] indices;
  delete[] values;
}

SparseVector::SparseVector(SparseVector *src) {
  nbValues = src->nbValues;
  indices = new int[nbValues];
  memcpy(indices, src->indices, nbValues*sizeof(int));
  values = new flt[nbValues];
  memcpy(values, src->values, nbValues*sizeof(flt));
}

SparseVector::SparseVector(int nbVals, size_t *inds, flt *vals) {
  nbValues = nbVals;
  indices = new int[nbValues];
  for (int i=0; i<nbValues; i++) indices[i] = (int)inds[i];
  values = new flt[nbValues];
  memcpy(values, vals, nbValues*sizeof(flt));
}

SparseVector::SparseVector(int dimension, flt *fullValues, flt threshold) {
  // Note : quite inefficient implementation to avoid too much memory
  // juggling Making tyhe assumption that this constructor is used
  // only rarely, e.g. when reading data from file.
  nbValues = 0;
  for (int i=0; i<dimension; i++)
    if (fullValues[i] > threshold) nbValues++;
  indices = new int[nbValues];
  values = new flt[nbValues];
  nbValues = 0;
  for (int i=0; i<dimension; i++)
    if (fullValues[i] > threshold) {
      values[nbValues] = fullValues[i];
      indices[nbValues++] = i;
    }
}


void SparseVector::copy (SparseVector *src) {
  delete[] values;
  delete[] indices;
  nbValues = src->nbValues;
  indices = new int[nbValues];
  memcpy(indices, src->indices, nbValues*sizeof(int));
  values = new flt[nbValues];
  memcpy(values, src->values, nbValues*sizeof(flt));
}

void SparseVector::setContents (int dimension, flt *fullValues, flt threshold) {
  // Note : quite inefficient implementation to avoid too much memory
  // juggling Making tyhe assumption that this constructor is used
  // only rarely. Typically used when creating a sparse matrix line by
  // line.
  delete[] values;
  delete[] indices;
  nbValues = 0;
  for (int i=0; i<dimension; i++)
    if (fullValues[i] > threshold) nbValues++;
  indices = new int[nbValues];
  values = new flt[nbValues];
  nbValues = 0;
  for (int i=0; i<dimension; i++)
    if (fullValues[i] > threshold) {
      values[nbValues] = fullValues[i];
      indices[nbValues++] = i;
    }
}

flt SparseVector::get (int i) {
  int min=0;
  int max=nbValues-1;
  while (min<=max) {
    int m = (min+max)/2;
    if (indices[m]==i) return values[m];
    if (indices[m]<i) min = m+1;
    else max = m-1;
  }
  return 0;
}

void SparseVector::add (SparseVector *other) {
  flt *newValues = (flt*) malloc ((nbValues+other->nbValues)*sizeof(flt));
  int *newIndices = (int*) malloc ((nbValues+other->nbValues)*sizeof(int));
  int newNbValues = 0;
  int i1=0, i2=0;
  while (i1<nbValues && i2<other->nbValues) {
    if (indices[i1] == other->indices[i2]) {
      newValues[newNbValues] = values[i1]+other->values[i2];
      indices[newNbValues++] = indices[i1];
      ++i1; ++i2;
    } else if (indices[i1] < other->indices[i2]) {
      newValues[newNbValues] = values[i1];
      indices[newNbValues++] = indices[i1];
      ++i1;
    } else {
      newValues[newNbValues] = other->values[i2];
      indices[newNbValues++] = other->indices[i2];
      ++i2;
    }
  }
  while (i1 < nbValues) {
    newValues[newNbValues] = values[i1];
    indices[newNbValues++] = indices[i1];
    ++i1;
  }
  while (i2 < other->nbValues) {
    newValues[newNbValues] = other->values[i2];
    indices[newNbValues++] = other->indices[i2];
    ++i2;
  }
  nbValues = newNbValues;
  delete[] values;
  delete[] indices;
  values = (flt*) realloc(newValues, nbValues*sizeof(flt));
  indices = (int*) realloc(newIndices, nbValues*sizeof(int));
}

void SparseVector::scale (flt scaleFactor) {
  for (int i=0; i<nbValues; i++)
    values[i] *= scaleFactor;
}




SVIterator::SVIterator (SparseVector *target) {
  this->target = target;
  position = 0;
}

void SVIterator::start() {
  position = 0;
}

bool SVIterator::hasMore() {
  return (position < target->nbValues);
}

void SVIterator::toNext() {
  position++;
}

int SVIterator::getIndex () {
  assert (position < target->nbValues);
  return target->indices[position];
}

flt SVIterator::getValue () {
  assert (position < target->nbValues);
  return target->values[position];
}
