#ifndef _GLOBAL_H_
#define _GLOBAL_H_

#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include <assert.h>
#include <stdint.h>
#include <time.h>
#include <string.h>



void errorAndQuit (const char *format, ...);

double normalRandom(double mean, double sigma);

FILE *openInFile (const char *inFileName);

FILE *openOutFile (const char *outFileName);

int64_t intSquareRoot (int64_t x);

double **newMatrix (long size1, long size2);

void freeMatrix (double **matrix);

void skipBlank (FILE *fin);

double kaverages(int nbClasses, long nbObjects, double **simil, int *labels);

#endif
