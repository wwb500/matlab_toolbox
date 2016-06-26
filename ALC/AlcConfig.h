#ifndef _ALC_CONFIG_H_
#define _ALC_CONFIG_H_

#include "global.h"

class AlcLevelConfig {

public:

  struct {
    double continuity;
    double similarity;
    double structure;
  } weights;

  int nbVerticalClasses;

  // 'd' for DTW, 'a' for average
  char verticalDistanceType; 
  char horizontalDistanceType; 

  // If C is the segmentation curve, then the probability that a new
  // object starts at this point is proportional to a*(C[i+1]-C[i])-(1-a)*(C[i]-C[i-1])
  // double segmentationLookAheadWeight;


  // Should we cut at min points of the seg curve, at max points, before max points, or all?
  bool cutAtMin;
  bool cutAtMax;
  bool cutBeforeMax;

  // All the following values are in frames
  // Target object size at this level. If zero, then no size criterion will be applied
  // double targetObjectSize;
  // Sigma of the Gaussian function for object probability to the left of target time
  // (object shorter than target)
  // double leftSigma;
  // Sigma of the Gaussian function for object probability to the right of target time
  // (object longer than target)
  // double rightSigma;

  // Note: set "rightSigma" to 0 to enforce a strict maximum size;
  //       set "leftSigma" to 0 to enforce a strict minimum size;
  //       set "rightSigma" to a very large value (e.g. 1e6) to impose no maximum limit
  //       set "leftSigma" to a very large value (e.g. 1e6) to impose no minimum limit

  // "helps" segmentation get closer to the expected object length by increasing the base cutting probability
  // double segmentationCutShift;

  //AlcLevelConfig (int nbVC, double contw, double simw, double strw, char dType);

  AlcLevelConfig (FILE *fin);

  void printDetails(FILE *fout);
};



class AlcConfig {

 public:

  int nbLevels;

  bool normalizeData;

  int kaveragesRepeat;

  AlcLevelConfig **levels;

  AlcConfig(const char *fileName);

};

#endif
