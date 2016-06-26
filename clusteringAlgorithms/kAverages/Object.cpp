#include <stdio.h>
#include "Object.h"
#include "Class.h"

Object::Object (int id, int initClass, Class **classes, int nbClasses) {
  this->id = id;
  this->classes = classes;
  nextClass = currentClass = initClass;
  classes[initClass]->enterNotify(id);

  this->nbClasses = nbClasses;
}

flt Object::findNextClass (int *justLooking) {
  int best = 0;
  flt delta = 0;
  flt bestDelta = 0;
  for (int i=0; i<nbClasses; i++) {
    if ((delta = classes[currentClass]->objectMoveQualityDelta(id, classes[i])) > bestDelta) {
      bestDelta = delta;
      best = i;
    }
  }
  if (bestDelta > 0) {
    if (justLooking) *justLooking = best;
    else nextClass = best;
  }

  return bestDelta;
}

void Object::moveTo (int classId) {
  nextClass = classId;
}

void Object::step (bool instantUpdate) {
  if (currentClass != nextClass) {
    classes[currentClass]->leaveNotify(id, instantUpdate);
    classes[nextClass]->enterNotify(id, instantUpdate);
    currentClass = nextClass;
  }
}

