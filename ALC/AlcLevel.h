#ifndef _ALC_LEVEL_H_
#define _ALC_LEVEL_H_

#include "global.h"
#include "AlcConfig.h"

class AlcLevel {

 public:

  int level;

  long nbObjects;

  long *relativeOnsets;
  long *absoluteOnsets;

  double *power;

  // Warning: in "labels", object 0 is an added silent object. Actual object labels start at index 1
  int *labels;
  
  AlcLevelConfig *config;

  // Constructor for level 0
  AlcLevel (long nbFrames, double *segCurve);

  // Constructor for levels 1+
  AlcLevel (AlcLevelConfig *config, AlcLevel *lowerLevel, double *segCurve);

  void doVerticalClustering ();

  double *getSegmentationCurve ();

  void print(FILE *fout);

  void printJSon (FILE *fout);

 private:

  double *curve;

  double kaveQual;

  void objectsFromSegCurve (double *curve, long maxIndex, long *absolute);
  
  double averageDistance (double **o1, long l1, double **o2, long l2);  
  double dtwDistance (double **o1, long l1, double **o2, long l2, double **matrix);

};



#endif
