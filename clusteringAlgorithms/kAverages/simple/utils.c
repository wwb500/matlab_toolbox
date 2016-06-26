#include "utils.h"
#include <sys/timeb.h>
#include <stdarg.h>
#include <limits.h>

void errorAndQuit (const char *format, ...) {
    va_list args;
    va_start(args, format);
    vfprintf(stderr, format, args);
    va_end(args);
    exit(0);
}

double normalRandom(double mean, double sigma) {
  double v1,v2,s;
  do {
    v1 = 2.0 * ((double) rand()/RAND_MAX) - 1;
    v2 = 2.0 * ((double) rand()/RAND_MAX) - 1;
    s = v1*v1 + v2*v2;
  } while ( s >= 1.0 );

  if (s == 0.0)
    return mean;
  else
    return mean + sigma*(v1*sqrt(-2.0 * log(s) / s));
}

FILE *openInFile (const char *inFileName) {  
  FILE *fin = fopen(inFileName, "rb");
  if (!fin)  errorAndQuit ("\nCould not open file '%s' for reading.\n\n", inFileName);
  return fin;
}

FILE *openOutFile (const char *outFileName) {  
  FILE *fin = fopen(outFileName, "wb");
  if (!fin)  errorAndQuit ("\nCould not open file '%s' for writing.\n\n", outFileName);
  return fin;
}

int64_t intSquareRoot (int64_t x) {
  register int64_t res = 0;
  register int64_t one = ((int64_t)1) << 62;
  /* "one" starts at the highest power of four <= than the argument. */
  while (one > x) one >>= 2;
  while (one != 0) {
    if (x >= res + one) {
      x -= res + one;
      res += one << 1;
    }
    res >>= 1;
    one >>= 2;
  }
  return res;
}

double **newMatrix (long size1, long size2) {
  double ** mat = (double**) malloc (size1*sizeof(double*));
  mat[0] = (double*) malloc (size1*size2*sizeof(double));
  for (int i=1; i<size1; i++)
    mat[i] = mat[i-1] + size2;
  memset(mat[0], 0, size1*size2*sizeof(double));
  return mat;
}

void freeMatrix (double **matrix) {
  free(matrix[0]);
  free(matrix);
}

int loadLabels (const char *fileName, long nbObjects, int *labels) {
    FILE *inLabels = openInFile(fileName);
    long nbO, nbC;
    fscanf(inLabels, "%li %li", &nbO, &nbC);
    if (nbO != nbObjects)
      errorAndQuit("\nNumber of objects in label file (%li) does not match expected number of objects (%li).\n\n", nbO, nbObjects);
    int minClass = INT_MAX;
    int maxClass = INT_MIN;
    for (int i=0; i<nbObjects; i++) {
      if (!fscanf(inLabels, "%i", labels+i))
	errorAndQuit("\nUnexpected en of input while reading init label file '%s'.\n\n", fileName);
      if (labels[i] < minClass) minClass = labels[i];
      if (labels[i] > maxClass) maxClass = labels[i];
    }
    long nbClasses = maxClass - minClass + 1;
    if (nbClasses != nbC)
      errorAndQuit("\nObserved number of classes (%i), not equal to declared number of classes (%li)\nin labels file '%s'.\n\n", nbClasses, nbC, fileName);
    // Normalize to have labels in [0, nbClasses-1]
    for (int i=0; i<nbObjects; i++)
      labels[i] -= minClass;
    fclose(inLabels);
    return (int)nbClasses;
}

double *_utils_timeofday_timer = NULL;
int _utils_timeofday_timer_nb_piled = 0;
int _utils_timeofday_timer_stack_size = 0;

void timerStart () {
  struct timeb t;
  ftime(&t);
  if (_utils_timeofday_timer_nb_piled == _utils_timeofday_timer_stack_size) {
    if (_utils_timeofday_timer_stack_size) _utils_timeofday_timer_stack_size *= 2;
    else _utils_timeofday_timer_stack_size = 16;
    _utils_timeofday_timer = (double*) realloc (_utils_timeofday_timer, _utils_timeofday_timer_stack_size*sizeof(double));
  }
  _utils_timeofday_timer[_utils_timeofday_timer_nb_piled++] = (double)t.time + ((double)t.millitm)/1000;
}

double timerEnd () {
  if (_utils_timeofday_timer_nb_piled <= 0) return 0;
  struct timeb t;
  ftime(&t);
  double tmp = (double)t.time + ((double)t.millitm)/1000;
  return tmp - _utils_timeofday_timer[--_utils_timeofday_timer_nb_piled];
}
