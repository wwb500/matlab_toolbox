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
  int raw = 0;
  while (p<argc) {
    if (!strcmp(argv[p], "-c")) sscanf(argv[++p], "%i", &nbClasses);
    else if (!strcmp(argv[p], "-rs")) sscanf(argv[++p], "%u", &randSeed);
    else if (!strcmp(argv[p], "-m")) matrixFileName = argv[++p];
    else if (!strcmp(argv[p], "-l")) initLabelsFileName = argv[++p];
    else if (!strcmp(argv[p], "-o")) outBaseName = argv[++p];
    else if (!strcmp(argv[p], "-r")) raw = 1;
    else errorAndQuit("\nUsage: %s -m similarityMatrix (-c numberOfClasses | -l initLabelsFile) -o outfilePrefix [-r]\n\n", argv[0]);
    p++;
  }
  if ((!nbClasses && !initLabelsFileName) || !matrixFileName || !outBaseName)
    errorAndQuit("\nUsage: %s -m similarityMatrix (-c numberOfClasses | -l initLabelsFile) -o outfilePrefix [-r]\n\n", argv[0]);

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

  if (initLabelsFileName)
    nbClasses = loadLabels(initLabelsFileName, nbObjects, labels);
  else
    for (i=0; i<nbObjects; i++) labels[i] = rand() % nbClasses;

  fprintf(outLog, "K-averages clustering of %li objects into %i classes, similarity matrix in '%s', metrics: %s\n", nbObjects, nbClasses, matrixFileName, (raw ? "raw" : "object normalized"));
  fprintf(outCsv, "%li, %i, %s, %s\n", nbObjects, nbClasses, matrixFileName, (raw ? "raw" : "object normalized"));
  fprintf(outLabels, "%li %i\n", nbObjects, nbClasses);

  // READ SIMILARITY MATRIX

  double **simil = newMatrix(nbObjects, nbObjects);
  fread(simil[0], sizeof(double), nbObjects*nbObjects, matrixFile);
  fclose(matrixFile);

  // INITIALIZE VALUES

  // class sizes

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


  deltaT = timerEnd();

  fprintf(outLog, "Loading data and computing initial values: %.10g s (all future times given in seconds)\n", deltaT);
  fprintf(outCsv, "%.10g\n", deltaT);

  // Go!

  double epsilon = 0;

  timerStart();

  long changed = nbObjects;
  long totalChanged = 0;
  int iteration = 0;
  double sumDelta = 0;
  while (changed && iteration < 1000) {
    timerStart();
    changed = 0;
    sumDelta = 0;
    if (raw) {
      for (i=0; i<nbObjects; i++) {
	int oldC = labels[i];
	int bestC = oldC;
	double best = coSimil[oldC][i];
	double bestDQ = 0;
	for (c=0; c<nbClasses; c++) {
	  if (coSimil[c][i] > best) {
	    bestDQ += coSimil[c][i]-best;
	    best = coSimil[c][i];
	    bestC = c;
	  }
	}
	if (bestDQ>epsilon && bestC != oldC) {
	  changed ++;
	  sumDelta += bestDQ;
	  labels[i] = bestC;
	  classSize[oldC]--;
	  classSize[bestC]++;
	  for (j=0; j<nbObjects; j++) {
	    if (i != j) {
	      double s = simil[i][j];
	      coSimilAccu[oldC][j] -= s;
	      coSimilAccu[bestC][j] += s;
	    }
	  }
	  double size = (double) classSize[oldC];
	  if (classSize[oldC]) {
	    for (j=0; j<nbObjects; j++)
	      if (labels[j]==oldC)
		coSimil[oldC][j] = coSimilAccu[oldC][j]/(size-1);
	      else
		coSimil[oldC][j] = coSimilAccu[oldC][j]/size;
	  } else {
	      for (j=0; j<nbObjects; j++)
		coSimil[oldC][j] = 0;
	  }
	  size = (double) classSize[bestC];
	  for (j=0; j<nbObjects; j++) {
	    if (labels[j]==bestC)
	      coSimil[bestC][j] = coSimilAccu[bestC][j]/(size-1);
	    else
	      coSimil[bestC][j] = coSimilAccu[bestC][j]/size;
	  }
	}
      }
    } else {
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
	      + coSimil[ct][i] - coSimil[cs][i];
	    if (deltaQ > bestDQ) {
	      bestDQ = deltaQ;
	      newC = ct;
	    }
	  }
	}
	if (bestDQ>epsilon && newC != cs) {
	  changed ++;
	  sumDelta += bestDQ;
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
    }
    raw = raw % 2;
    totalChanged += changed;
    deltaT = timerEnd();
    double globalQual = 0;
    for (int c=0; c<nbClasses; c++) globalQual += quality[c]*(double)classSize[c];
    globalQual /= (double)nbObjects;
    fprintf(outLog, "Iteration %i, %li moved object%s, sum delta = %.10g, deltaT = %.10g, globalQual = %.10g\n", iteration+1, changed, ((changed>1) ? "s":""), sumDelta, deltaT, globalQual);
    fprintf(outCsv, "%i, %li, %.10g, %.10g\n", iteration, changed, sumDelta, deltaT);
    iteration++;
  }

  deltaT = timerEnd();
  fprintf(outLog, "Total %i iterations, %li moved objects, clustering performed in %.10g s\n", iteration, totalChanged, deltaT);
  fprintf(outCsv, "%i, %li, %.10g\n", iteration, totalChanged, deltaT);

  deltaT = timerEnd();
  fprintf(outLog, "Total time with loading: %.10g s\n", deltaT);
  fprintf(outCsv, "%.10g\n", deltaT);

  for (i=0; i<nbObjects; i++)
    fprintf(outLabels, "%i ", labels[i]+1);
 
  fclose(outLabels);
  fclose(outLog);
  fclose(outCsv);
  freeMatrix(simil);
  freeMatrix(coSimil);
  freeMatrix(coSimilAccu);
}
