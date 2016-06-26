#ifndef _ALC_H_
#define _ALC_H_

#include "global.h"

#include "AlcConfig.h"
#include "AlcLevel.h"

class ALC {

 private:

  AlcLevel **levels;

  const char *configFile;
  const char *dataFile;

 public:

  static AlcConfig *config;
  static long nbFrames;
  static double **data;
  static int featDim;
  static double *zero;

  static double distance (double *v1, double *v2);
  static double sqDistance (double *v1, double *v2);

  ALC (const char *configFile, const char *dataFile);

  void run ();

  void printAll (const char *outFile);
  void printLevel (int level, const char *outFile);
  void printJSon (const char *outFile);

};




#endif
