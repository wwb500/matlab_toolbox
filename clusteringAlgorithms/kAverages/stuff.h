#include <stdlib.h>
#include <math.h>
#include <stdio.h>
#include <string.h>
#include <time.h>
#include <assert.h>

#ifndef KAVERAGES_STUFF_H
#define KAVERAGES_STUFF_H

#define PRINT_RUNNING_INFO

//#define USE_FLOAT 1
#define USE_DOUBLE 1

#ifdef USE_FLOAT
  typedef float flt;
  #define SQRT sqrtf
  #define LOG logf
  #define NaN nanf("")
  #define NOPE -HUGE_VALF
#else
  typedef double flt;
  #define SQRT sqrt
  #define LOG log
  #define NaN nan("")
  #define NOPE -HUGE_VAL
#endif

typedef enum {rawSimilarity, objectNormalizedQualityDelta, classNormalizedQualityDelta} AllocationCriterion;

typedef enum {batch, progressive, bestProgressive, mixed, bestMixed} AlgoType;


#define ERROR(...) kmerror(__FILE__, __LINE__, __VA_ARGS__)

#define FRAND(scale)  (scale)*((flt)random())/((flt)RAND_MAX)

void kmerror (const char *fileName, int lineNum, const char *format, ...);

// Gives two gaussian-distributed values. The employed algorithm gives
// two at once whether you want them or not, so we might as well
// return both.
void twoGaussianRandoms (flt *x, flt *y, flt mean1, flt stdDev1, flt mean2, flt stdDev2);

flt euclidDistance (flt *v1, flt *v2, int dim);

#endif /* KAVERAGES_STUFF_H */
