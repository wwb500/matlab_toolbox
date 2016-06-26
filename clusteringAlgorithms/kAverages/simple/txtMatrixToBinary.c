#include <stdio.h>
#include <string.h>
#include "utils.h"

int main (int argc, const char **argv) {

  const char *inFile = NULL;
  const char *outFile = NULL;

  int p = 1;
  while (p<argc) {
    if (!strcmp(argv[p], "-i")) inFile = argv[++p];
    else if (!strcmp(argv[p], "-o")) outFile = argv[++p];
    else  errorAndQuit("\nUsage: %s -i inFile -o outFile\n\n", argv[0]);
    p++;
  }
  if (!inFile || !outFile) errorAndQuit("\nUsage: %s -i inFile -o outFilen\n\n", argv[0]);

  FILE *fin  = openInFile (inFile);
  FILE *fout = openOutFile(outFile);

  long count = 0;
  double val;
  while (fscanf(fin, "%lf", &val) != EOF) {
    count++;
    fwrite(&val, sizeof(double), 1, fout);
  }
  
  fprintf(stderr, "\nRead and wrote %li values.\n\n", count);

}
