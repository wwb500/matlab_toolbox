#include "stuff.h"
#include "Object.h"
#include "Class.h"
#include "kaverages.h"

int main (int argc, char **argv) {
  int nbObjects = 5000;
  int nbClasses = 20;

  SparseMatrix *objectObjectSimilarities = new SparseMatrix(nbObjects, nbObjects);

  // START generating test data

  printf ("Generating random test data...\n");

  srandom(11);

  flt playFieldSize = 10;

  // Randomly positioning class prototypes, no variance for now: change
  // the playfield size to have classes more or less compactly packed
  // together
  flt *classCenters = new flt [2*nbClasses];
  for (int i=0; i<nbClasses; i++) {
    classCenters[2*i] = FRAND(2*playFieldSize)-playFieldSize;
    classCenters[2*i+1] = FRAND(2*playFieldSize)-playFieldSize;
  }

  // Affecting a class to each object
  int *groundTruth = new int [nbObjects];
  for (int i=0; i<nbObjects; i++)
    groundTruth[i] = random() % nbClasses;

  // Generating object coordinates ; they follow a normal gaussian
  // distribution around class centers
  flt *objectVectors = new flt [2*nbObjects];
  for (int i=0; i<nbObjects; i++)
    twoGaussianRandoms (&(objectVectors[2*i]), &(objectVectors[2*i+1]), classCenters[2*groundTruth[i]], 1, classCenters[2*groundTruth[i]+1], 1);

  printf ("Computing test data similarities...\n");

  // Computing similarities between objects
  flt *fullSimilarityMatrixLine = new flt[nbObjects];
  for (int i=0; i<nbObjects; i++) {
    if (!(i%100)) {
      fprintf(stderr, "\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b%i / %i", i, nbObjects);
    }
    for (int j=0; j<nbObjects; j++)
      fullSimilarityMatrixLine[j] = 1. / (1. + euclidDistance (objectVectors+2*i, objectVectors+2*j, 2));
    objectObjectSimilarities->setLine(i, fullSimilarityMatrixLine, .3);
  }

  printf ("\nSimilarity matrix density : %5.2f %%\n\n", 100*objectObjectSimilarities->getDensity());

  // END generating test data


  // Perform clustering test in all modes, writing out result and gnuplot commands

  const char* operationMode [] = {"br", "bc", "bo", "pr", "pc", "po", "Pr", "Pc", "Po", "mr", "mc", "mo", "Mr", "Mc", "Mo"};

  int *result = new int [nbObjects];
  int *init = new int [nbObjects];
  for (int i=0; i<nbObjects; i++)
    init[i] = rand() % nbClasses;

  char *filename1 = new char[128];
  char *filename2 = new char[128];

  for (int mode=0; mode<15; mode++) {

    sprintf(filename1, "kaverages_classes_%s.txt", operationMode[mode]);
    sprintf(filename2, "kaverages_classes_%s.gnuplot", operationMode[mode]);

    kAveragesClustering (nbObjects, nbClasses, objectObjectSimilarities, result, operationMode[mode], 500, init);

    // Create two files to allow visualizing results with gnuplot

    FILE *fout = fopen(filename1, "w");
    if (!fout) ERROR ("Could not open file '%s' for writing result.", filename1);
    for (int c=0; c<nbClasses; c++)
      fprintf(fout, "%f\t%f\n", classCenters[2*c], classCenters[2*c+1]);
    fprintf(fout, "\n\n");
    for (int c=0; c<nbClasses; c++) {
      for (int i=0; i<nbObjects; i++) {
	if (result[i] == c)
	  fprintf(fout, "%f\t%f\n", objectVectors[2*i], objectVectors[2*i+1]);
      }
      fprintf(fout, "\n\n");
    }
    fclose(fout);
    fout = fopen(filename2, "w");
    if (!fout) ERROR ("Could not open file '%s' for writing gnuplot commands.", filename2);
    fprintf(fout, "unset key;\nplot \"%s\" index 0 with points", filename1);
    for (int c=0; c<nbClasses; c++) {
      fprintf(fout, ", \"%s\" index %i with dots", filename1, c+1);
    }
    fprintf(fout, ";\n");
    fclose(fout);

    fprintf(stderr, "\n\n----------------------------------------------\n\n");
    
  }
  delete[] classCenters;
  delete[] groundTruth;
  delete[] objectVectors;
  delete[] fullSimilarityMatrixLine;
  delete[] result;
  delete objectObjectSimilarities;

}

