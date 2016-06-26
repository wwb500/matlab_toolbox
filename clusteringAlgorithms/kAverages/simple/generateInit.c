#include "utils.h"

int main (int argc, const char **argv) {
  int p = 1;
  int nbObjects = 0;
  int nbClasses = 0;
  const char *outBaseName = NULL;
  unsigned int randSeed = (unsigned int) time(NULL);
  while (p<argc) {
    if (!strcmp(argv[p], "-n")) sscanf(argv[++p], "%i", &nbObjects);
    else if (!strcmp(argv[p], "-c")) sscanf(argv[++p], "%i", &nbClasses);
    else if (!strcmp(argv[p], "-rs")) sscanf(argv[++p], "%u", &randSeed);
    else if (!strcmp(argv[p], "-o")) outBaseName = argv[++p];
    else errorAndQuit("\nUsage: %s -n numberOfObjects -c numberOfClasses [-s sigma] -o outfilePrefix)\n\n", argv[0]);
    p++;
  }
  if (!nbClasses || !nbObjects || !outBaseName)
    errorAndQuit("\nUsage: %s -n numberOfObjects -c numberOfClasses -o outfilePrefix)\n\n", argv[0]);

  srand(randSeed);

  // OPEN RESULT FILES

  FILE *outLabels;
  if (strlen(outBaseName)>7
      && !strcmp(outBaseName+strlen(outBaseName)-7, ".labels")) {
    outLabels = openOutFile(outBaseName);
  } else {
    char *outLabelsFileName = (char*) malloc(strlen(outBaseName)+10);
    sprintf(outLabelsFileName, "%s.labels", outBaseName);
    outLabels = openOutFile(outLabelsFileName);
  }
  fprintf(outLabels, "%i %i\n", nbObjects, nbClasses);

  // LABELS
  // Simply drawn at random, which means for large numbers of objects all classes
  // should have similar sizes. That's not guaranteed, though.
  // Let's write that file right now, too.

  int *labels = (int*) malloc (nbObjects*sizeof(int));
  for (int i=0; i<nbObjects; i++) {
    labels[i] = rand() % nbClasses;
    fprintf (outLabels, "%i ", labels[i]+1);
  }
  fprintf(outLabels, "\n");
  fclose(outLabels);

}
