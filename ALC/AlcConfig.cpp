#include "AlcConfig.h"


// AlcLevelConfig::AlcLevelConfig (int nbVC, double contw, double similw, double strw, char dType) {
//   nbVerticalClasses = nbVC;
//   distanceType = dType;
//   double sum = contw+strw+similw;
//   if (sum <= 0) {
//     weights.continuity = weights.similarity = weights.structure = 1./3.;
//   } else {
//     weights.continuity = contw/sum;
//     weights.structure  = strw/sum;
//     weights.similarity  = similw/sum;
//   }
// }




// EACH CONFIG LINE HAS, IN THIS ORDER:
// nbVerticalClasses        -- int
// structToSpectralBalance  -- float, 1 means all structure, 0 means all spectral
// contToSimilBalance       -- float, 1 means all continuity, 0 means all similarity
// vertDistanceType         -- char, type of distance to use for clustering ('a' for average, 'd' for dtw)
// horizDistanceType        -- char, type of distance to use for segmentation ('a' for average, 'd' for dtw)
// cutStrategy              -- String up to 3 characters: 'm' to cut at min, 'M' to cut at max, 'b' to cut before max

// ALL "TARGET SIZE" STUFF REMOVED FOR NOW
// targetSize               -- float, target object size at this level, in frames. 0 means don't consider size.
// sizeLeftSigma            -- float, sigma of the gaussian curve governing the probability of sizes < targetSize
// sizeRightSigma           -- float, sigma of the gaussian curve governing the probability of sizes > targetSize
// segmentationOffset       -- float, increases (>0) or decreases (<0) the base segmentation probability.
//                             if >0 , will help produce objects closer to 'targetSize'

AlcLevelConfig::AlcLevelConfig (FILE *fin) {
  double structureSpectralBalance;
  double continuitySimilarityBalance;
  char string[16];
  if (fscanf(fin, "%i %lf %lf %c %c %s", &nbVerticalClasses, &(structureSpectralBalance), &(continuitySimilarityBalance),
	     &verticalDistanceType, &horizontalDistanceType, string) != 6)
    errorAndQuit("Incorrect format or Unexpected end of file while reading configuration");
  cutAtMin = cutAtMax = cutBeforeMax = false;
  for (int i=0; string[i]; i++) { // null-terminated string
    if (string[i] == 'm') cutAtMin = true;
    else if (string[i] == 'M') cutAtMax = true;
    else if (string[i] == 'b') cutBeforeMax = true;
  }
  weights.structure = structureSpectralBalance;
  weights.continuity = (1-structureSpectralBalance)*continuitySimilarityBalance;
  weights.similarity = (1-structureSpectralBalance)*(1-continuitySimilarityBalance);
}


void AlcLevelConfig::printDetails (FILE *fout) {
  char strategy[8];
  int i = 0;
  if (cutAtMin) strategy[i++] = 'm';
  if (cutAtMax) strategy[i++] = 'M';
  if (cutBeforeMax) strategy[i++] = 'b';
  strategy[i] = '\0';
  fprintf(fout, "weights ( %lf, %lf, %lf ), %i classes, H distance '%c', V distance '%c', cut strategy '%s'\n",
	  weights.structure, weights.continuity, weights.similarity, nbVerticalClasses,
	  horizontalDistanceType, verticalDistanceType, strategy);
}


AlcConfig::AlcConfig (const char *fileName) {
  FILE *fin = openInFile(fileName);
  skipBlank(fin);
  int tmp;
  if (fscanf(fin, "%i %i %i", &nbLevels, &tmp, &kaveragesRepeat) != 3)
    errorAndQuit("Incorrect format or Unexpected end of file while reading configuration file '%s'.", fileName);
  normalizeData = (tmp>0);
  fprintf(stderr, "%i levels\n", nbLevels);
  levels = new AlcLevelConfig* [nbLevels];
  for (int i=0; i<nbLevels; i++) {
    skipBlank(fin);
    levels[i] = new AlcLevelConfig(fin);
    levels[i]->printDetails(stderr);
  }
}
