#include <stdio.h>
#include <string.h>

#include "kaverages.h"


/**
 * Entry point
 *
 * \param nbObjects the number of universe objects
 *
 * \param nbClasses the number of desired classes
 *
 * \param simil the similarity matrix, as a sparse matrix (note that
 * the SparseMatrix class has a constructor that takes a full matrix as
 * a parameter)
 * 
 * \param resultClasses a pre-allocated array of \c nbObjects
 * integers; will be filled with the class of each object. May be
 * NULL, in which case you case still get the classes and objects via
 * the static \c Object::objects and \c Class::classes.
 *
 * \param operationMode a string specifying in 2 letters the  objective function and clustering strategy.
 *    Objective function: r - "raw", re-assign objects based on max similarity, without normalization. Minimal calculation but convergence not guaranteed.
 *                        c - class-normalized average intra-class simlarity
 *                        o - object-normalized intra-class similarity -- 'c' and 'o' modes have comparable complexity, and both are guaranteed to converge. Try.
 *    Clustering Stategy: p - progressive: update class properties immediately as each decision to move an object is taken. Guaranteed convergence but relatively slow and result may depend on order in which objects are numbered.
 *                        P - "best progressive": like "progressive" but we always move the object that has the highest impact on the objective function. Guaranteed convergence, deterministic, but slow.
 *                        b - "batch": identify in one pass all objects that "want" to change class and make one big update. Faster, deterministic, but convergence not guaranteed.
 *                        m - "mixed": Start with 'batch' until the number of objects moving at each iteration falls below 10% of the total, or that number stops decreasing, then move to "progressive"
 *                        M - "best mixed": Start with 'batch' until the number of objects moving at each iteration alls below 10% of the total, or that number stops decreasing, then move to "best progressive"
 * The order of the two letters is irrelevant. "rP", "pr", "bo", "op", etc., are all valid. In case of missing or invalid argument, will default to "cP".
 * Add 's' in the 'mode' string to make it silent, add 'l' to redirect the output to "kaverages.log"
 *   
 *
 * \param initClasses optionallly, the initial class assignments
 */

int kAveragesClustering (int nbObjects, int nbClasses, SparseMatrix *simil, int *resultClasses, const char *operationMode, int maxIt, int *initClasses) {

  FILE *log = stderr;

  AllocationCriterion criterion = objectNormalizedQualityDelta;
  AlgoType algType = progressive;

  for (int i=0; i<strlen(operationMode); i++) {
    switch(operationMode[i]) {
    case 'r': criterion = rawSimilarity; break;
    case 'o': criterion = objectNormalizedQualityDelta; break;
    case 'c': criterion = classNormalizedQualityDelta; break;
    case 'b': algType = batch; break;
    case 'p': algType = progressive; break;
    case 'P': algType = bestProgressive; break;
    case 'm': algType = mixed; break;
    case 'M': algType = bestMixed; break;
    case 's': log = NULL; break;
    case 'l': log = fopen("kaverages.log", "w"); break;
    default: break;
    }
  }


  // Allocate memory to store class-object similarities
  flt **classObjectSimilarities = new flt*[nbClasses];
  classObjectSimilarities[0] = new flt[nbClasses*nbObjects];
  for (int i=1; i<nbClasses; i++)
    classObjectSimilarities[i] = classObjectSimilarities[i-1]+nbObjects;

  // Create classes

  Class **classes = new Class* [nbClasses];
  for (int i=0; i<nbClasses; i++)
    classes[i] = new Class(i, nbObjects, simil, classObjectSimilarities, criterion);

  // Create objects with either predefined init classes or random ones
  Object **objects = new Object* [nbObjects];
  for (int i=0; i<nbObjects; i++)
    objects[i] = new Object(i, ((initClasses) ? initClasses[i] : rand() % nbClasses), classes, nbClasses);

  // Initialize stuff
  for (int i=0; i<nbClasses; i++) classes[i]->step();
  
  if (log) {
    fprintf (log, "Clustering %i objects into %i classes.\n", nbObjects, nbClasses);
    if (initClasses) fprintf (log, "Following provided initial classes.\n");
    fprintf(log, "Objective function: %s\nClustering strategy: %s\n",
	    ((criterion == rawSimilarity) ? "raw similarity" : (criterion == objectNormalizedQualityDelta) ? "object normalized quality delta" : "class normalized quality delta"),
	    ((algType == batch) ? "batch" : (algType == progressive) ? "progressive" : (algType == mixed) ? "mixed" : (algType == bestMixed) ? "best mixed" : "best progressive"));
    Class::printObjectiveFunctionValues(classes, nbClasses, log);
  }

  // cluster

  if (log)
    fprintf (log, "\nStarting iteration...\n");

  int changes;
  int totalClassChanges = 0;
  int nbLoops = 0;
  int nbIt = 0;
  switch (algType) {
  case batch:
    nbIt = batchClustering (objects, nbObjects, classes, nbClasses, log, maxIt, 0, false);
    break;
    
  case progressive:
    nbIt = progressiveClustering (objects, nbObjects, log, maxIt);
    break;

  case bestProgressive:
    nbIt = bestProgressiveClustering (objects, nbObjects, log);
    break;

  case mixed:
    batchClustering (objects, nbObjects, classes, nbClasses, log, maxIt, nbObjects/10, true);
    nbIt = progressiveClustering (objects, nbObjects, log, maxIt);
    break;

  case bestMixed:
    batchClustering (objects, nbObjects, classes, nbClasses, log, maxIt, nbObjects/10, true);
    nbIt = bestProgressiveClustering (objects, nbObjects, log);
    break;
  }

  if (log) Class::printObjectiveFunctionValues(classes, nbClasses, log);

  // Put result in resultClasses, if non-null
  
  if (resultClasses)
    for (int i=0; i<nbObjects; i++)
      resultClasses[i] = objects[i]->getClass();
  
  for (int i=0; i<nbObjects; i++) delete objects[i];
  delete [] objects;
  for (int i=0; i<nbClasses; i++) delete classes[i];
  delete [] classes;
  
  delete [] classObjectSimilarities[0];
  delete [] classObjectSimilarities;
  
  if (log && log != stderr) fclose(log);

  return nbIt;
}


int batchClustering (Object **objects, int nbObjects, Class **classes, int nbClasses, FILE *log, int maxLoops, int minObjectsMove, bool decreaseOnly) {
  int nbLoops = 0, changes = nbObjects, prevChanges = 0, totalClassChanges = 0;
  clock_t t1 = clock();
  do {
    prevChanges = changes;
    changes = 0;
    for (int i=0; i<nbObjects; i++)
      if (objects[i]->findNextClass() > 0) changes++;
    if (changes) {
      for (int i=0; i<nbObjects; i++)
	objects[i]->step();
      for (int i=0; i<nbClasses; i++)
	classes[i]->step();
    }
    nbLoops++;
    if (log)
      fprintf(log, "Loop %i : %i class changes, %f ms\n", nbLoops, changes, 1000.*(flt)(clock()-t1)/CLOCKS_PER_SEC);
    totalClassChanges += changes;
  } while (changes>minObjectsMove && nbLoops<maxLoops && !(decreaseOnly && changes>=prevChanges));
  
  if (log)
    fprintf (log, "Done\n\nSummary of operation in batch mode:\nProcessor time : %f ms\nNumber of loops:%i\nNumber of class changes:%i\n\n", 1000.*(flt)(clock()-t1)/CLOCKS_PER_SEC, nbLoops, totalClassChanges);

  return nbLoops;
}


int progressiveClustering (Object **objects, int nbObjects, FILE *log, int maxLoops) {
  int nbLoops = 0, changes = 0, totalClassChanges = 0;
  clock_t t1 = clock();
  do {
    changes = 0;
    for (int i=0; i<nbObjects; i++) {
      if (objects[i]->findNextClass() > 0) {
	objects[i]->step(true);
	changes++;
      }
    }
    nbLoops++;
    if (log)
      fprintf(log, "Loop %i : %i class changes, %f ms\n", nbLoops, changes, 1000.*(flt)(clock()-t1)/CLOCKS_PER_SEC);
    totalClassChanges += changes;
  } while (changes && nbLoops<maxLoops);

  if (log)
    fprintf (log, "Done\n\nSummary of operation in progressive mode:\nProcessor time : %f ms\nNumber of loops:%i\nNumber of class changes:%i\n\n", 1000.*(flt)(clock()-t1)/CLOCKS_PER_SEC, nbLoops, totalClassChanges);

  return nbLoops;
}

int bestProgressiveClustering (Object **objects, int nbObjects, FILE *log) {
  // In this case there are no loops: after each object move
  // everything is updated and the best move is searched for in all
  // objects.
  int nbMoves = 0;
  flt delta, bestDelta;
  int bestObject=0, bestMove = 0;
  clock_t t1 = clock();
  do {
    bestDelta = 1E-6;
    for (int i=0; i<nbObjects; i++) {
      int move;
      if ((delta = objects[i]->findNextClass(&move)) > bestDelta) {
	bestObject = i;
	bestMove = move;
	bestDelta = delta;
      }
    }
    if (bestDelta>1E-6) {
      objects[bestObject]->moveTo(bestMove);
      objects[bestObject]->step(true);
      nbMoves++;
    }
    if (log && nbMoves%100==0) fprintf(log, "Move %i : delta %f\n", nbMoves, bestDelta);
  } while (bestDelta > 1E-6);
  if (log)
    fprintf (log, "Done\n\nSummary of operation in best progressive mode:\nProcessor time : %f ms\nNumber of class changes:%i\n\n", 1000.*(flt)(clock()-t1)/CLOCKS_PER_SEC, nbMoves);

  return nbMoves;
}
