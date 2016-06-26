#include "utils.h"
#include <limits.h>

int main (int argc, const char **argv) {
  if (argc != 3) errorAndQuit("\nUsage: %s labelsFile1 labelsFile2\n\n", argv[0]);
  const char *labels1File = argv[1];
  const char *labels2File = argv[2];

  FILE *in1 = openInFile(labels1File);
  long nbObjects;
  int nbClasses;
  fscanf(in1, "%li %i", &nbObjects, &nbClasses);

  FILE *in2 = openInFile(labels2File);
  long nbO2;
  int nbC2;
  fscanf(in2, "%li %i", &nbO2, &nbC2);

  if (nbO2!= nbObjects) errorAndQuit ("Number of objects in given label files do not match\n\n");
  if (nbC2!= nbClasses) errorAndQuit ("Number of classes in given label files do not match\n\n");

  

  int *lab1 = (int*) malloc (nbObjects*sizeof(int));
  int minClass = INT_MAX;
  for (int i=0; i<nbObjects; i++) {
    if (!fscanf(in1, "%i", lab1+i))
      errorAndQuit("\nUnexpected en of input while reading init label file '%s'.\n\n", labels1File);
    if (lab1[i] < minClass) minClass = lab1[i];
  }
  for (long i=0; i<nbObjects; i++) lab1[i] -= minClass;

  fclose(in1);
				     
  int *lab2 = (int*) malloc (nbObjects*sizeof(int));
  minClass = INT_MAX;
  for (int i=0; i<nbObjects; i++) {
    if (!fscanf(in2, "%i", lab2+i))
      errorAndQuit("\nUnexpected en of input while reading init label file '%s'.\n\n", labels2File);
    if (lab2[i] < minClass) minClass = lab2[i];
  }
  for (long i=0; i<nbObjects; i++) lab2[i] -= minClass;

  fclose(in2);

  double **matches = newMatrix(nbClasses, nbClasses);
  for (long i=0; i<nbObjects; i++)
    matches[lab1[i]][lab2[i]] ++;

  double count = 0;

  for (int l=0; l<nbClasses; l++) {
    double best = 0;
    int bestC1 = 0;
    int bestC2 = 0;
    for (int c1 = 0; c1<nbClasses; c1++)
      for (int c2 = 0; c2<nbClasses; c2++)
	if (matches[c1][c2] > best) {
	  best = matches[c1][c2];
	  bestC1 = c1;
	  bestC2 = c2;
	}
    count += best;
    for (int c = 0; c<nbClasses; c++) {
      matches[bestC1][c] = -1;
      matches[c][bestC2] = -1;
    }
  }

  printf ("\n%.10g\n\n", count/(double)nbObjects);

}
