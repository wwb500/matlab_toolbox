#include "utils.h"

int main (int argc, const char **argv) {
  int p = 1;
  int nbObjects = 0;
  int nbClasses = 0;
  double sigma = 1;
  const char *outBaseName = NULL;
  unsigned int randSeed = (unsigned int) time(NULL);
  while (p<argc) {
    if (!strcmp(argv[p], "-n")) sscanf(argv[++p], "%i", &nbObjects);
    else if (!strcmp(argv[p], "-rs")) sscanf(argv[++p], "%u", &randSeed);
    else if (!strcmp(argv[p], "-c")) sscanf(argv[++p], "%i", &nbClasses);
    else if (!strcmp(argv[p], "-s")) sscanf(argv[++p], "%lf", &sigma);
    else if (!strcmp(argv[p], "-o")) outBaseName = argv[++p];
    else errorAndQuit("\nUsage: %s -n numberOfObjects -c numberOfClasses [-s sigma] -o outfilePrefix)\n\n", argv[0]);
    p++;
  }
  if (!nbClasses || !nbObjects || !outBaseName)
    errorAndQuit("\nUsage: %s -n numberOfObjects -c numberOfClasses [-s sigma] -o outfilePrefix)\n\n", argv[0]);

  srand(randSeed);

  // OPEN RESULT FILES

  char *outMatrixFileName = (char*) malloc(strlen(outBaseName)+10);
  sprintf(outMatrixFileName, "%s.matrix", outBaseName);
  FILE *outMatrix = openOutFile(outMatrixFileName);

  char *outLabelsFileName = (char*) malloc(strlen(outBaseName)+10);
  sprintf(outLabelsFileName, "%s.labels", outBaseName);
  FILE *outLabels = openOutFile(outLabelsFileName);
  fprintf(outLabels, "%i %i\n", nbObjects, nbClasses);

  char *outCoordsFileName = (char*) malloc(strlen(outBaseName)+10);
  sprintf(outCoordsFileName, "%s.coords", outBaseName);
  FILE *outCoords = openOutFile(outCoordsFileName);
  fprintf(outCoords, "%i %i\n", nbObjects, nbClasses);

  // CLASS CENTROIDS
  // If c is the number of classes, the "playfield" is a square from
  // coordinates (0,0) to (c/2+1,c/2+1)

  double size = ((double)nbClasses)/2+1;  
  double *cx = (double*) malloc (nbClasses*sizeof(double));
  double *cy = (double*) malloc (nbClasses*sizeof(double));
  for (int i=0; i<nbClasses; i++) {
    double bestDist = 0;
    for (int try = 0; try<10; try++) {
      //Trying to find a new centroid that's not too close to the others
      double candidateX = 1. + size*((double)rand())/RAND_MAX;
      double candidateY = 1. + size*((double)rand())/RAND_MAX;
      double minDist = 4*size*size;
      for (int j=0; j<i; j++) {
	double dist = (candidateX-cx[j])*(candidateX-cx[j])+(candidateY-cy[j])*(candidateY-cy[j]);
	if (dist<minDist) minDist = dist;
      }
      if (minDist>bestDist) {
	cx[i] = candidateX;
	cy[i] = candidateY;
	bestDist = minDist;
      }
    }
  }

  // LABELS
  // Simply drawn at random, which means for large numbers of objects all classes
  // should have similar sizes. That's not guaranteed, though.
  // Let's write that file right now, too.

  int *labels = (int*) malloc (nbObjects*sizeof(int));
  for (int i=0; i<nbObjects; i++) {
    labels[i] = rand() % nbClasses;
    fprintf (outLabels, "%i ", labels[i]);
  }
  fprintf(outLabels, "\n");
  fclose(outLabels);

  // COORDINATES
  // normally distributed around class centroids. All classes have sigma=1.
  // While we're at it, we write the coordinates file

  double *x = (double*) malloc (nbObjects*sizeof(double));
  double *y = (double*) malloc (nbObjects*sizeof(double));

  for (int i=0; i<nbObjects; i++) {
    x[i] = normalRandom(cx[labels[i]], sigma);
    y[i] = normalRandom(cy[labels[i]], sigma);
    fprintf(outCoords, "%f %f\n", x[i], y[i]);
  }

  fclose (outCoords);

  // SIMILARITIES
  // Inverse distances

  for (int i=0; i<nbObjects; i++) {
    for (int j=0; j<nbObjects; j++) {
      double dist = sqrt((x[i]-x[j])*(x[i]-x[j])+(y[i]-y[j])*(y[i]-y[j]));
      double simil = 1./(1.+dist);
      fwrite(&simil, sizeof(double), 1, outMatrix);
    }
  }
  fclose(outMatrix);

}
