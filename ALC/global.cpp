#include "global.h"
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

void skipBlank (FILE *fin) {
  char c = ' ';
  while (c==' ' || c=='\n' || c=='\t') {
    if (feof(fin)) break;
    c = (char) fgetc(fin);
    if (c=='#') //Comment, skip to end of line
      while (c!='\n' && !feof(fin))
	c = (char) fgetc(fin);
  }
  fseek(fin, -1, SEEK_CUR);
}

double kaverages(int nbClasses, long nbObjects, double **simil, int *labels) {
  long i, j, c;
  for (i=0; i<nbObjects; i++) labels[i] = rand() % nbClasses;
  int *classSize = (int*)malloc(nbClasses*sizeof(int));
  memset(classSize, 0, nbClasses*sizeof(int));
  for (i=0; i<nbObjects; i++)
    classSize[labels[i]]++;

  // class-to-object similarities

  double **coSimil = newMatrix(nbClasses, nbObjects);
  double **coSimilAccu = newMatrix(nbClasses, nbObjects);

  for (i=0; i<nbObjects; i++)
    for (j=0; j<nbObjects; j++)
      if (i != j) coSimilAccu[labels[i]][j] += simil[i][j];

  for (c=0; c<nbClasses; c++)
    for (j=0; j<nbObjects; j++)
      if (labels[j]==c) coSimil[c][j] = coSimilAccu[c][j]/(double)(classSize[c]-1);
      else coSimil[c][j] = coSimilAccu[c][j]/(double)classSize[c];
  
  // Class qualities

  double *quality = (double*) malloc (nbClasses*sizeof(double));
  memset(quality, 0, nbClasses*sizeof(double));
  for (i=0; i<nbObjects; i++)
    quality[labels[i]] += coSimil[labels[i]][i];
  for (c = 0; c<nbClasses; c++) {
    quality[c] /= (double)classSize[c];
  }

  double epsilon = 0;
  long changed = nbObjects;
  int iteration = 0;
  while (changed && iteration < 1000) {
    changed = 0;
    for (i=0; i<nbObjects; i++) {
      // 's' -> source, 't' -> target
      int cs = labels[i];
      if (classSize[cs] <= 2) continue;
      double ns = (double)classSize[cs];
      int newC = cs;
      double bestDQ = 0;
      for (int ct = 0; ct < nbClasses; ct++) {
	if (ct != cs) {
	  double nt = (double)classSize[ct];
	  double deltaQ = 
	    2* nt   * (coSimil[ct][i] - quality[ct]) / (nt+1)
	    + 2*(ns-1)* (quality[cs] - coSimil[cs][i]) / (ns-2)
	    +((nt-1)*quality[ct]+2*coSimil[ct][i])/(nt+1) - quality[cs];
	  if (deltaQ > bestDQ) {
	    bestDQ = deltaQ;
	    newC = ct;
	  }
	}
      }
      if (bestDQ>epsilon && newC != cs) {
	changed ++;
	quality[cs] = (classSize[cs]*quality[cs]-2*coSimil[cs][i])/(classSize[cs]-2);
	quality[newC] = ((classSize[newC]-1)*quality[newC]+2*coSimil[newC][i])/(classSize[newC]+1);
	labels[i] = newC;
	classSize[cs]--;
	classSize[newC]++;
	for (j=0; j<nbObjects; j++) {
	  if (i != j) {
	    double s = simil[i][j];
	    coSimilAccu[cs][j] -= s;
	    coSimilAccu[newC][j] += s;
	  }
	}
	double size = (double) classSize[cs];
	if (classSize[cs]) {
	  for (j=0; j<nbObjects; j++) {
	    if (labels[j]==cs)
	      coSimil[cs][j] = coSimilAccu[cs][j]/(size-1);
	    else
	      coSimil[cs][j] = coSimilAccu[cs][j]/size;
	  }
	} else {
	  for (j=0; j<nbObjects; j++)
	    coSimil[cs][j] = 0;
	}
	size = (double) classSize[newC];
	for (j=0; j<nbObjects; j++) {
	  if (labels[j]==newC)
	    coSimil[newC][j] = coSimilAccu[newC][j]/(size-1);
	  else coSimil[newC][j] = coSimilAccu[newC][j]/size;
	}
      }
    }
    iteration++;
  }

  double globalQ = 0;
  for (long i=0; i<nbClasses; i++)
    globalQ += ((double)classSize[i])*quality[i];
  globalQ /= (double) nbObjects;


  free(classSize);
  free(quality);
  freeMatrix(coSimil);
  freeMatrix(coSimilAccu);

  return globalQ;
}
