#include "stuff.h"
#include "SparseMatrix.h"
#include "Object.h"
#include "Class.h"
  
int kAveragesClustering (int nbObjects, int nbClasses, SparseMatrix *similarities, int *resultClasses, const char *operationMode, int nbIt = 500, int *initClasses = NULL);

int batchClustering (Object **objects, int nbObjects, Class **classes, int nbClasses, FILE *log, int maxLoops, int minObjectsMove, bool decreaseOnly);
int progressiveClustering (Object **objects, int nbObjects, FILE *log, int maxLoops);
int bestProgressiveClustering (Object **objects, int nbObjects, FILE *log);
