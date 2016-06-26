#include "stuff.h"
#include "SparseMatrix.h"

#ifndef CLASS_H
#define CLASS_H

class Class {

public:

  Class (int id, int nbUniverseObjects, SparseMatrix *objectObjectSimilarities, flt **classObjectSimilarities, AllocationCriterion c);
  ~Class ();

  // Notify this class that an object is removed from it.
  // If "instantUpdate", all of this class's data will be updated
  // immediately (used for progressive algorithm), otherwise this
  // update is delayed to the next call of "step" (used for batch
  // algorithm).
  void leaveNotify (int objectId, bool instantUpdate=false);

  // Notify this class that an object is added to it.
  // If "instantUpdate", all of this class's data will be updated
  // immediately (used for progressive algorithm), otherwise this
  // update is delayed to the next call of "step" (used for batch
  // algorithm).
  void enterNotify (int objectId, bool instantUpdate=false);

  // Update class properties to take into account modifications made
  // this iteration If previous calls to "leaveNotify" and
  // "enterNotify" have been made with instantUpdate==true, this is a
  // no-op
  void step();

  // Compute the impact on the objective function of an object leaving this class to join another one
  // The actual value computed is dependent upon "criterion"
  // Returns 0 if target == current class or object not in class
  flt objectMoveQualityDelta(int objectId, Class *target);

  // Accessor methods
  bool nonEmpty() {return (nbObjects>0);}
  int getSize() {return nbObjects;}

  // For information
  static void printObjectiveFunctionValues (Class **classes, int nbClasses, FILE *fout = stderr);

private:

  // Class id
  int id;

  // Number of elements
  int nbObjects;

  // Class composition in set representation
  bool *objects;

  // Has there been any modification to this class in this iteration?
  bool change;

  // Non normalized sum of all s(o1,o2) where o2 belongs in this class.
  // Normalize by class size to obtain object-class similarity.
  // Always double precision.
  double *averageSimilarityAccumulator;

  // Class "quality", computed as the average inner object-object smilarity.
  // Updated incrementally, therefore always double precision.
  double quality;

  // Global data, repeated in each class object (not as static) to
  // potentially allow multiple classifs to be carried out
  // simultaneously
  SparseMatrix *objectObjectSimilarities;
  flt **classObjectSimilarities;
  int nbUniverseObjects;
  AllocationCriterion criterion;
};

#endif
