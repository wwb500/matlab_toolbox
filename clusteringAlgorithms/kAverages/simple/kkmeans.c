#include "utils.h"
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <limits.h>

int main (int argc, char **argv) {
  int c, p = 1;
  long i, j;
  const char *matrixFileName = NULL;
  const char *outBaseName = NULL;
  const char *initLabelsFileName = NULL;
  unsigned int randSeed = (unsigned int) time(NULL);
  int nbClasses = 0;
  
  while (p<argc) {
    if (!strcmp(argv[p], "-c")) sscanf(argv[++p], "%i", &nbClasses);
    else if (!strcmp(argv[p], "-rs")) sscanf(argv[++p], "%u", &randSeed);
    else if (!strcmp(argv[p], "-m")) matrixFileName = argv[++p];
    else if (!strcmp(argv[p], "-l")) initLabelsFileName = argv[++p];
    else if (!strcmp(argv[p], "-o")) outBaseName = argv[++p];
    else errorAndQuit("\nUsage: %s -m kernelMatrix (-c numberOfClasses | -l initLabelsFile) -o outfilePrefix\n\n", argv[0]);
    p++;
  }
  if ((!nbClasses && !initLabelsFileName) || !matrixFileName || !outBaseName)
    errorAndQuit("\nUsage: %s -m kernelMatrix (-c numberOfClasses | -l initLabelsFile) -o outfilePrefix\n\n", argv[0]);

  srand(randSeed);

  // OPEN MATRIX FILE
  // (not loading now, just testing file existence, readability and size)

  struct stat buf;
  if (stat(matrixFileName, &buf))
    errorAndQuit("\nAn error occurred when trying to check properties of file '%s'\n\n", matrixFileName);
  int64_t matrixFileSize = buf.st_size;
  long nbObjects = (long) intSquareRoot(matrixFileSize/8);
  if ((int64_t)nbObjects * (int64_t)nbObjects != matrixFileSize/8)
    errorAndQuit ("\nFile '%s' does not seem to contain a square matrix of 'double' values.\n(size: %li, nbValues: %li, closest square root: %li)\n\n",
		  matrixFileName, matrixFileSize, matrixFileSize/8, nbObjects);
  FILE *matrixFile = openInFile(matrixFileName);

  // OPEN RESULT FILES

  char *outLogFileName = (char*) malloc(strlen(outBaseName)+10);
  sprintf(outLogFileName, "%s.log", outBaseName);
  FILE *outLog = openOutFile(outLogFileName);

  char *outCsvFileName = (char*) malloc(strlen(outBaseName)+10);
  sprintf(outCsvFileName, "%s.csv", outBaseName);
  FILE *outCsv = openOutFile(outCsvFileName);

  char *outLabelsFileName = (char*) malloc(strlen(outBaseName)+10);
  sprintf(outLabelsFileName, "%s.labels", outBaseName);
  FILE *outLabels = openOutFile(outLabelsFileName);
  
  // READ INIT LABELS, IF SPECIFIED, OR PERFORM RANDOM INIT

  double deltaT = 0;
  timerStart();
  timerStart();

  int *labels = (int*)malloc(nbObjects*sizeof(int));
  int *newLabels = (int*)malloc(nbObjects*sizeof(int));

  if (initLabelsFileName)
    nbClasses = loadLabels(initLabelsFileName, nbObjects, labels);
  else
    for (i=0; i<nbObjects; i++) labels[i] = rand() % nbClasses;

  fprintf(outLog, "K-averages clustering of %li objects into %i classes, kernel matrix in '%s'\n", nbObjects, nbClasses, matrixFileName);
  fprintf(outCsv, "%li, %i, %s\n", nbObjects, nbClasses, matrixFileName);
  fprintf(outLabels, "%li %i\n", nbObjects, nbClasses);

  // READ KERNEL MATRIX

  double **kernel = newMatrix(nbObjects, nbObjects);
  fread(kernel[0], sizeof(double), nbObjects*nbObjects, matrixFile);
  fclose(matrixFile);

  // INITIALIZE VALUES

  // class sizes

  int *classSize = (int*)malloc(nbClasses*sizeof(int));
  memset(classSize, 0, nbClasses*sizeof(int));
  for (i=0; i<nbObjects; i++)
    classSize[labels[i]]++;

  // Mc values

  double *mc = (double*) malloc (nbClasses*sizeof(double));
  memset(mc, 0, nbClasses*sizeof(double));
  for (i=0; i<nbObjects; i++)
    for (j=0; j<nbObjects; j++)
      if (labels[i] == labels[j]) mc[labels[i]] += kernel[i][j];
  for (int c=0; c<nbClasses; c++)
    mc[c] /= classSize[c]*classSize[c];


  deltaT = timerEnd();

  fprintf(outLog, "Loading data and computing initial values: %.10g s (all future times given in seconds)\n", deltaT);
  fprintf(outCsv, "%.10g\n", deltaT);

  // Go!

  timerStart();

  long changed = nbObjects;
  long totalChanged = 0;
  int iteration = 0;
  double maxDelta = 0;
  double *ycn = (double*) malloc (nbClasses*sizeof(double));
  while (changed) {
    timerStart();
    changed = 0;
    maxDelta = 0;
    for (i=0; i<nbObjects; i++) {
      for (c=0; c<nbClasses; c++)
	ycn[c] = 0;
      for (j=0; j<nbObjects; j++)
	ycn[labels[j]] += kernel[i][j];
      for (c=0; c<nbClasses; c++)
	ycn[c] = kernel[i][i]+mc[c]-2*ycn[c]/(double)classSize[c];
      newLabels[i] = labels[i];
      for (c=0; c<nbClasses; c++) {
	if (ycn[c] < ycn[newLabels[i]])
	  newLabels[i] = c;
      }
      if (newLabels[i] != labels[i]) {
	changed ++;
	if (ycn[labels[i]] - ycn[newLabels[i]] > maxDelta)
	  maxDelta = ycn[labels[i]] - ycn[newLabels[i]];
      }
    }
    int *tmp = labels;
    labels = newLabels;
    newLabels = tmp;
    // class sizes
    memset(classSize, 0, nbClasses*sizeof(int));
    for (i=0; i<nbObjects; i++)
      classSize[labels[i]]++;

    // Mc values
    memset(mc, 0, nbClasses*sizeof(double));
    for (i=0; i<nbObjects; i++)
      for (j=0; j<nbObjects; j++)
	if (labels[i] == labels[j]) mc[labels[i]] += kernel[i][j];
    for (int c=0; c<nbClasses; c++)
      mc[c] /= classSize[c]*classSize[c];

    totalChanged += changed;
    deltaT = timerEnd();
    fprintf(outLog, "Iteration %i, %li moved object%s, max delta = %.10g, deltaT = %.10g\n", iteration+1, changed, ((changed>1) ? "s":""), maxDelta, deltaT);
    fprintf(outCsv, "%i, %li, %.10g, %.10g\n", iteration, changed, maxDelta, deltaT);
    iteration++;
  }

  deltaT = timerEnd();
  fprintf(outLog, "Total %i iterations, %li moved objects, clustering performed in %.10g s\n", iteration, totalChanged, deltaT);
  fprintf(outCsv, "%i, %li, %.10g\n", iteration, totalChanged, deltaT);

  deltaT = timerEnd();
  fprintf(outLog, "Total time with loading: %.10g s\n", deltaT);
  fprintf(outCsv, "%.10g\n", deltaT);

  for (i=0; i<nbObjects; i++)
    fprintf(outLabels, "%i ", labels[i]);

  fclose(outLabels);
  fclose(outLog);
  fclose(outCsv);
  freeMatrix(kernel);
}
