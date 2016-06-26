#include "Class.h"
// #include "stuff.h" done by previous
#include <string.h>

Class::Class (int id, int nbUniverseObjects, SparseMatrix *objectObjectSimilarities, flt **classObjectSimilarities, AllocationCriterion c) {
  this->id = id;
  this->nbUniverseObjects = nbUniverseObjects;
  this->objectObjectSimilarities = objectObjectSimilarities;
  this->classObjectSimilarities = classObjectSimilarities;
  this->criterion = c;
  this->change = false;

  nbObjects = 0;
  averageSimilarityAccumulator = new double[nbUniverseObjects];
  memset (averageSimilarityAccumulator, 0, nbUniverseObjects*sizeof(double));
  objects = new bool[nbUniverseObjects];
  memset (objects, 0, nbUniverseObjects*sizeof(bool));
}

Class::~Class () {
  delete [] averageSimilarityAccumulator;
}

void Class::leaveNotify (int objectId, bool instantUpdate) {
  if (nbObjects<=2) return;
  SVIterator lineIterator(objectObjectSimilarities->getLine(objectId));
  for (lineIterator.start(); lineIterator.hasMore(); lineIterator.toNext())
    averageSimilarityAccumulator[lineIterator.getIndex()] -= lineIterator.getValue();

  if (instantUpdate) {
    quality = (nbObjects*quality - 2*classObjectSimilarities[id][objectId])/(nbObjects-2);
    flt n = (flt)(nbObjects-1);
    for (int i=0; i<nbUniverseObjects; i++)
      classObjectSimilarities[id][i] = averageSimilarityAccumulator[i]/n;
  } else {
    change = true;
  }

  objects[objectId] = false;
  nbObjects--;
}

void Class::enterNotify (int objectId, bool instantUpdate) {
  SVIterator lineIterator(objectObjectSimilarities->getLine(objectId));
  for (lineIterator.start(); lineIterator.hasMore(); lineIterator.toNext())
    averageSimilarityAccumulator[lineIterator.getIndex()] += lineIterator.getValue();

  if (instantUpdate) {
    quality = ((nbObjects-1)*quality + 2*classObjectSimilarities[id][objectId])/(nbObjects+1);
    flt n = (flt)(nbObjects+1);
    for (int i=0; i<nbUniverseObjects; i++)
      classObjectSimilarities[id][i] = averageSimilarityAccumulator[i]/n;
  } else {
    change = true;
  }

  objects[objectId] = true;
  nbObjects++;
}

void Class::step () {
  if (!nbObjects || !change) return;
  change = false;
  flt n = (flt)nbObjects;
  for (int i=0; i<nbUniverseObjects; i++)
    classObjectSimilarities[id][i] = averageSimilarityAccumulator[i]/n;
  quality = 0;
  for (int i=0; i<nbUniverseObjects; i++) if (objects[i]) quality += classObjectSimilarities[id][i];
  quality /= nbObjects;
}

// Returns 0 if s=t or object not in class s
flt Class::objectMoveQualityDelta(int objectId, Class *target) {
  if (!objects[objectId] || target->id==this->id || this->nbObjects <= 2) return 0;
  switch(criterion) {

  case rawSimilarity:
    return classObjectSimilarities[target->id][objectId]-classObjectSimilarities[id][objectId];

  case classNormalizedQualityDelta:
    return 2*(this->quality - classObjectSimilarities[this->id][objectId])     / (this->nbObjects-2) +  // Delta for leaving this
           2*(classObjectSimilarities[target->id][objectId] - target->quality) / (target->nbObjects+1); // Delta for joining target

  case objectNormalizedQualityDelta:
    return   2 * (nbObjects-1)     * (this->quality - classObjectSimilarities[this->id][objectId])     / (this->nbObjects-2)   // Delta for leaving this
           + 2 * target->nbObjects * (classObjectSimilarities[target->id][objectId] - target->quality) / (target->nbObjects+1) // Delta for joining target
           + classObjectSimilarities[target->id][objectId] - classObjectSimilarities[this->id][objectId];
  }
}

void Class::printObjectiveFunctionValues (Class **classes, int nbClasses, FILE *fout) {
    flt oObj = 0, cObj = 0;
    int totalNObj = 0;
    for (int i=0; i<nbClasses; i++) {
      cObj += classes[i]->quality;
      oObj += classes[i]->nbObjects*classes[i]->quality;
      totalNObj += classes[i]->nbObjects;
    }
    cObj /= nbClasses;
    oObj /= totalNObj;
    fprintf(fout, "Class-normalized objective function: %f\nObject-normalized objective function:%f\n", cObj, oObj);
  }
