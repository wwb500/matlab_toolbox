#ifndef OBJECT_H
#define OBJECT_H

#include "stuff.h"

class Class;

class Object {

public:

  Object (int id, int initClass, Class **classes, int nbClasses);

  // Finds the best class for this object.
  // Return the quality delta brought by the change.
  // If return value <= 0, no change happens.
  // If "justLooking" is non-null, it will be set to the index of the
  // best class thus found and the object will NOT be modified.
  flt findNextClass (int *justLooking = NULL);

  // Forces this object to move to class classId. Still need to call "step" for actual update!
  void moveTo (int classId);

  // Apply change of class. If "instantUpdate", the classes affected by
  // the change will update their data immediately, otherwise it will
  // be delayed (batch mode).
  void step (bool instantUpdate = false);

  // Accessor methods
  int getClass () {return currentClass;}
  int getID () {return id;}

private:
  int id;

  int currentClass;
  int nextClass;

  // Context reference
  int nbClasses;
  Class **classes;
};

#endif
