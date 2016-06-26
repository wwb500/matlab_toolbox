#include "ALC.h"
#include <string.h>

int main (int argc, const char **argv) {
  const char *usageString = "\nUsage: %s -d dataFile -c configFile -o outfilePrefix [-rs randomSeed]\n\n";
  int p = 1;
  const char *dataFileName = NULL;
  const char *outBaseName = NULL;
  const char *configFileName = NULL;
  unsigned int randSeed = (unsigned int) time(NULL);
  while (p<argc) {
    if (!strcmp(argv[p], "-rs")) sscanf(argv[++p], "%u", &randSeed);
    else if (!strcmp(argv[p], "-d")) dataFileName = argv[++p];
    else if (!strcmp(argv[p], "-c")) configFileName = argv[++p];
    else if (!strcmp(argv[p], "-o")) outBaseName = argv[++p];
    else errorAndQuit(usageString, argv[0]);
    p++;
  }
  if (!configFileName || !dataFileName || !outBaseName)
    errorAndQuit(usageString, argv[0]);

  srand(randSeed);

  ALC *analyzer = new ALC(configFileName, dataFileName);
  analyzer->run();
  
  char *buffer = new char [strlen(outBaseName)+32];
  sprintf(buffer, "%s.all.txt", outBaseName);
  analyzer->printAll(buffer);
  sprintf(buffer, "%s.all.json", outBaseName);
  analyzer->printJSon(buffer);
  for (int i=0; i<analyzer->config->nbLevels; i++) {
    sprintf(buffer, "%s.%i.txt", outBaseName, i);
    analyzer->printLevel(i, buffer);
  }

}
