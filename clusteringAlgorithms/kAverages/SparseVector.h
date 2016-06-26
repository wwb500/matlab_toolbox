#include "stuff.h"

#ifndef SPARSE_VECTOR_H
#define SPARSE_VECTOR_H

class SVIterator;

class SparseVector {
  friend class SVIterator;

public:

  SparseVector ();
  SparseVector (SparseVector *src);
  SparseVector (int nbValues, size_t *ind, flt *vals);
  SparseVector (int dimension, flt *fullValues, flt threshold=0);

  ~SparseVector();

  void setContents (int dimension, flt *fullValues, flt threshold=0);

  void copy (SparseVector *src);

  flt get (int i);

  void add (SparseVector *other);
  void scale (flt scaleFactor);

  flt getNbValues () {return nbValues;}

private:

  int nbValues;
  int *indices;
  flt *values;
};

class SVIterator {

public:
  SVIterator (SparseVector *target);

  void start();
  bool hasMore();
  void toNext();

  int getIndex ();
  flt getValue ();

private:
  SparseVector *target;
  int position;

};

#endif
