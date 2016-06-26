#include "stuff.h"
#include <stdarg.h>

void twoGaussianRandoms (flt *v1, flt *v2, flt mean1, flt stdDev1, flt mean2, flt stdDev2) {
  double w, x, y, r2;
  do {
    /* choose x,y in uniform square (-1,-1) to (+1,+1) */
    x = -1 + 2 * FRAND(1);
    y = -1 + 2 * FRAND(1);
    /* see if it is in the unit circle */
    r2 = x * x + y * y;
  } while (r2 > 1.0 || r2 == 0);
  /* Box-Muller transform */
  w = sqrt (-2.0 * log (r2) / r2);
  *v1 = mean1+stdDev1*(flt)(x * w);
  *v2 = mean2+stdDev2*(flt)(y * w);
}

flt euclidDistance (flt *v1, flt *v2, int dim) {
  flt tmp, dist = 0;
  for (int i=0; i<dim; i++) {
    tmp = v1[i]-v2[i];
    dist += tmp*tmp;
  }
  return SQRT(dist);
}


void kmerror (const char *fileName, int lineNum, const char *format, ...) {
  fprintf(stderr, "\nError in file '%s', line %d:\n", fileName, lineNum);

  va_list argp;
  va_start(argp, format);
  vfprintf(stderr, format, argp);
  va_end(argp);

  fprintf(stderr, "\n\nAborting now.\n\n");
  exit(EXIT_FAILURE);
}
