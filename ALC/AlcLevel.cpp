#include "ALC.h"
#include "AlcLevel.h"


AlcLevel::AlcLevel (AlcLevelConfig *config, AlcLevel *lowerLevel, double *segCurve) {
  this->config = config;
  nbObjects = 0;
  labels = NULL;
  curve = NULL;
  kaveQual = 0;
  if (lowerLevel) {
    level = lowerLevel->level+1;
    relativeOnsets = new long[lowerLevel->nbObjects+1];
    absoluteOnsets = new long[lowerLevel->nbObjects+1];
    objectsFromSegCurve(segCurve, lowerLevel->nbObjects, lowerLevel->absoluteOnsets);
  } else {
    level = 0;
    relativeOnsets = new long[ALC::nbFrames+1];
    absoluteOnsets = new long[ALC::nbFrames+1];
    objectsFromSegCurve(segCurve, ALC::nbFrames, NULL);
  }
}

void AlcLevel::objectsFromSegCurve (double *curve, long maxIndex, long *absolute) {
  absoluteOnsets[0] = relativeOnsets[0] = 0;
  nbObjects = 1;
  double *rawNewObjectProbability = new double[maxIndex];
  rawNewObjectProbability[0] = 1;
  for (long i=1; i<maxIndex; i++) {
    rawNewObjectProbability[i] = 0;
    if (config->cutAtMin && curve[i]<=curve[i-1] && curve[i]<curve[i+1])
      rawNewObjectProbability[i] = 1;
    if (config->cutAtMax && curve[i]>curve[i-1] && curve[i]>=curve[i+1])
      rawNewObjectProbability[i] = 1;
    if (config->cutBeforeMax && i<maxIndex-1 && curve[i+1]>=curve[i] && curve[i+1]>curve[i+2])
      rawNewObjectProbability[i] = 1;
  }

  for (long i=1; i<maxIndex; i++)
    if (rawNewObjectProbability[i] > 0)
      relativeOnsets[nbObjects++] = i;

  if (absolute)
    for (long i=1; i<nbObjects; i++)
      absoluteOnsets[i] = absolute[relativeOnsets[i]];
  else
    for (long i=1; i<nbObjects; i++)
      absoluteOnsets[i] = relativeOnsets[i];

  double globalPower = 0;
  power = new double[nbObjects];
  for (long i=0; i<nbObjects; i++) {
    power[i]=0;
    long min = absoluteOnsets[i];
    long max = ((i<nbObjects-1) ? absoluteOnsets[i+1] : ALC::nbFrames);
    for (long j=min; j<max; j++) {
      double tmp = ALC::data[j][0]*ALC::data[j][0];
      power[i] += tmp;
      globalPower += tmp;
    }
    power[i] /= (double)(max-min);
  }
  globalPower /= (double)ALC::nbFrames;
  for (long i=0; i<nbObjects; i++)
    power[i] /= globalPower;
}


double *AlcLevel::getSegmentationCurve () {

  if (!curve) curve = new double[nbObjects+1];

  double *continuity = new double[nbObjects+1];
  double *similarity = new double[nbObjects+1];
  double *structure = new double[nbObjects+1];

  bool normalize = true;

  // Continuity
  if (config && config->weights.continuity<=0) {
    memset(continuity, 0, (nbObjects+1)*sizeof(double));
  } else {
    double *last = ALC::zero;
    for (long i=0; i<nbObjects-1; i++) {
      continuity[i] = ALC::sqDistance(ALC::data[absoluteOnsets[i]], last);
      last = ALC::data[absoluteOnsets[i+1]-1];
    }
    continuity[nbObjects-1] = ALC::sqDistance(ALC::data[absoluteOnsets[nbObjects-1]], last);
    continuity[nbObjects] = ALC::sqDistance(ALC::data[ALC::nbFrames-1], ALC::zero);

    if (normalize) {
      double contMin = 1e9, contMax = -1e9;
      for (long i=1; i<nbObjects; i++) {
	if (continuity[i] < contMin) contMin = continuity[i];
	if (continuity[i] > contMax) contMax = continuity[i];
      }
      if (contMax>contMin) {
	for (long i=0; i<=nbObjects; i++)
	  continuity[i] = (continuity[i]-contMin)/(contMax-contMin);
	if (continuity[0] > 1) continuity[0] = 1;
	if (continuity[nbObjects] > 1) continuity[nbObjects] = 1;
      }
    }

  }

  // Similarity
  if (!config || config->weights.similarity<=0) {
    memset(similarity, 0, (nbObjects+1)*sizeof(double));
  } else {
    if (config->horizontalDistanceType == 'd') {
      long maxObjectSize = 0;
      for (long i=0; i<nbObjects-1; i++)
	if (absoluteOnsets[i+1]-absoluteOnsets[i] > maxObjectSize) maxObjectSize = absoluteOnsets[i+1]-absoluteOnsets[i];
      if (ALC::nbFrames-absoluteOnsets[nbObjects-1] > maxObjectSize) maxObjectSize = ALC::nbFrames-absoluteOnsets[nbObjects-1];
      fprintf(stderr, "NbObjects; %li, Max object size: %li\n", nbObjects, maxObjectSize);

      double **dtwComputeMatrix = newMatrix(maxObjectSize+1, maxObjectSize+1);
      double **lastO = &(ALC::zero);
      long lastL = 1;
      for (long i=0; i<nbObjects; i++) {
	double **o = &(ALC::data[absoluteOnsets[i]]);
	long l = ((i<nbObjects-1) ? absoluteOnsets[i+1] : ALC::nbFrames) - absoluteOnsets[i];
	similarity[i] = 1. / (1. + dtwDistance(lastO, lastL, o, l, dtwComputeMatrix));
	lastO = o;
	lastL = l;
      }
      similarity[nbObjects] = 1. / (1. + dtwDistance(lastO, lastL, &(ALC::zero), 1, dtwComputeMatrix));
      freeMatrix(dtwComputeMatrix);
    } else {
      double **lastO = &(ALC::zero);
      long lastL = 1;
      for (long i=0; i<nbObjects; i++) {
	double **o = &(ALC::data[absoluteOnsets[i]]);
	long l = ((i<nbObjects-1) ? absoluteOnsets[i+1] : ALC::nbFrames) - absoluteOnsets[i];
	similarity[i] = 1. / (1. + averageDistance(lastO, lastL, o, l));
	lastO = o;
	lastL = l;
      }
      similarity[nbObjects] = 1. / (1. + averageDistance(lastO, lastL, &(ALC::zero), 1));
    }

    if (normalize) {
      double simMin = 1e9, simMax = -1e9;
      for (long i=1; i<nbObjects; i++) {
	if (similarity[i] < simMin) simMin = continuity[i];
	if (similarity[i] > simMax) simMax = continuity[i];
      }
      if (simMax > simMin) {
	for (long i=0; i<=nbObjects; i++)
	  similarity[i] = (similarity[i]-simMin)/(simMax-simMin);
	if (similarity[0] > 1) similarity[0] = 1;
	if (similarity[nbObjects] > 1) similarity[nbObjects] = 1;
      }
    }

  }
  // Structure 
  if (!config || config->weights.structure<=0) {
    memset(structure, 0, (nbObjects+1)*sizeof(double));
  } else {
    doVerticalClustering();

    // Compute sequence mutual information between classes
    double *classCount = new double[config->nbVerticalClasses+1];
    memset(classCount, 0, (config->nbVerticalClasses+1)*sizeof(double));
    double **seqCount = newMatrix(config->nbVerticalClasses+1, config->nbVerticalClasses+1);

    // 0 is Silence Class
    classCount[0] = 1; // "Silence" pseudo-object added at beginning and end of sequence
    seqCount[labels[nbObjects]][0] = 1;
    classCount[labels[nbObjects]] = 1;

    for (long i=0; i<nbObjects; i++) {
      classCount[labels[i]]++;
      seqCount[labels[i]][labels[i+1]]++;
    }

    for (long i=0; i<nbObjects; i++)
      structure [i] = seqCount[labels[i]][labels[i+1]]/(classCount[labels[i]]*classCount[labels[i+1]]);
    structure[nbObjects] = seqCount[labels[nbObjects]][0]/(classCount[labels[nbObjects]]*classCount[0]);
    delete[] classCount;
    freeMatrix(seqCount);

    if (normalize) {
      double structMin = 1e9, structMax = -1e9;
      for (long i=1; i<nbObjects; i++) {
	if (structure[i] < structMin) structMin = structure[i];
	if (structure[i] > structMax) structMax = structure[i];
      }
      if (structMax > structMin) {
	for (long i=0; i<=nbObjects; i++)
	  structure[i] = (structure[i]-structMin)/(structMax-structMin);
	if (structure[0]>1) structure[0] = 1;
	if (structure[nbObjects]>1) structure[nbObjects] = 1;
      }
    }
  }

  // Mix the three curves
  if (config)
    for (long i=0; i<=nbObjects; i++)
      curve[i] = config->weights.continuity*continuity[i] + config->weights.similarity*similarity[i] + config->weights.structure*structure[i];
  else
    for (long i=0; i<=nbObjects; i++)
      curve[i] = continuity[i];

  return curve;
}


void AlcLevel::doVerticalClustering () {
  if (labels) return;
  long maxObjectSize = 0;
  for (long i=0; i<nbObjects-1; i++)
    if (absoluteOnsets[i+1]-absoluteOnsets[i] > maxObjectSize) maxObjectSize = absoluteOnsets[i+1]-absoluteOnsets[i];

  fprintf(stderr, "Max object size: %li, relativeOnsets[last] = %li, absoluteOnsets[last] = %li\n", maxObjectSize, relativeOnsets[nbObjects-1], absoluteOnsets[nbObjects-1]);

  if (ALC::nbFrames-absoluteOnsets[nbObjects-1] > maxObjectSize) maxObjectSize = ALC::nbFrames-absoluteOnsets[nbObjects-1];

  fprintf(stderr, "NbObjects; %li, Max object size: %li\n", nbObjects, maxObjectSize);

  double **simil = newMatrix(nbObjects+1, nbObjects+1);
  if (config->verticalDistanceType == 'd') {
    double **dtwComputeMatrix = newMatrix(maxObjectSize+1, maxObjectSize+1);
    for (long i=1; i<=nbObjects; i++) {
      double **object = &(ALC::data[absoluteOnsets[i-1]]);
      long l = ((i<nbObjects) ? absoluteOnsets[i] : ALC::nbFrames) - absoluteOnsets[i-1];
      simil[0][i] = simil[i][0] = 1. / (1. + dtwDistance(&(ALC::zero), 1, object, l, dtwComputeMatrix));
      for (long j=1; j<i; j++)
	simil[j][i] = simil[i][j] = 1. / (1. + dtwDistance(&(ALC::data[absoluteOnsets[j-1]]), absoluteOnsets[j] - absoluteOnsets[j-1], object, l, dtwComputeMatrix));
    }
    freeMatrix(dtwComputeMatrix);
  } else {
    for (long i=1; i<=nbObjects; i++) {
      double **object = &(ALC::data[absoluteOnsets[i-1]]);
      long l = ((i<nbObjects) ? absoluteOnsets[i] : ALC::nbFrames) - absoluteOnsets[i-1];
      simil[0][i] = simil[i][0] = 1. / (1. + averageDistance(&(ALC::zero), 1, object, l));
      for (long j=1; j<i; j++)
	simil[j][i] = simil[i][j] = 1. / (1. + averageDistance(&(ALC::data[absoluteOnsets[j-1]]), absoluteOnsets[j+1] - absoluteOnsets[j], object, l));
    }
  }
  labels = new int [nbObjects+1];
  kaveQual = kaverages(config->nbVerticalClasses, nbObjects+1, simil, labels);
  if (ALC::config->kaveragesRepeat > 1) {
    int *l = new int [nbObjects+1];
    for (int i=1; i<ALC::config->kaveragesRepeat; i++) {
      double q = kaverages(config->nbVerticalClasses, nbObjects+1, simil, l);
      if (q>kaveQual) {
	kaveQual = q;
	int *tmp = labels;
	labels = l;
	l = tmp;
      }
    }
  }

  // Object 0 is silence, let's give class 0 to all "silence" objects
  if (labels[0] != 0) {
    long silLabel = labels[0];
    for (long i=0; i<=nbObjects; i++) {
      if (labels[i] == 0) labels[i] = silLabel;
      else if (labels[i] == silLabel) labels[i] = 0;
    }
  }

  freeMatrix(simil);
}

double AlcLevel::averageDistance (double **o1, long l1, double **o2, long l2) {
  double *a1 = new double [ALC::featDim];
  double *a2 = new double [ALC::featDim];
  for (int i=0; i<ALC::featDim; i++)
    a1[i] = a2[i] = 0;
  for (long i=0; i<l1; i++)
    for (int j=0; j<ALC::featDim; j++)
      a1[j] += o1[i][j];
  for (long i=0; i<l2; i++)
    for (int j=0; j<ALC::featDim; j++)
      a2[j] += o2[i][j];
  for (int j=0; j<ALC::featDim; j++) {
    a1[j] /= (double)l1;
    a2[j] /= (double)l2;
  }
  double res = ALC::distance(a1, a2);
  delete[] a1;
  delete[] a2;
  return res;
}

double AlcLevel::dtwDistance (double **o1, long l1, double **o2, long l2, double **matrix) {
  matrix[0][0] = 0;
  for (long i=1; i<=l1; i++)
    matrix[i][0] = matrix[i-1][0] + ALC::sqDistance(o1[i-1], ALC::zero);
  for (long j=1; j<=l2; j++) {
    matrix[0][j] = matrix[0][j-1] + ALC::sqDistance(o2[j-1], ALC::zero);
    long min = (j-1)*l1/l2 - l1/5;
    if (min < 1)  min = 1;
    for (long i=1; i<min; i++)
      matrix[i][j] = 1e9;
    long max = (j+1)*l1/l2 + l1/5;
    if (max > l1) max = l1;
    for (long i=max+1; i<=l1; i++)
      matrix[i][j] = 1e9;
    for (long i=min; i<=max; i++) {
      matrix[i][j] = matrix[i-1][j-1] + ALC::sqDistance(o1[i-1], o2[j-1]);
      double tmp;
      if (i<l1) {
	tmp = matrix[i][j-1] + ALC::sqDistance(o1[i], o2[j-1]);
	if (tmp < matrix[i][j]) matrix[i][j] = tmp;
      }
      if (j<l2) {
	tmp = matrix[i-1][j] + ALC::sqDistance(o1[i-1], o2[j]);
	if (tmp < matrix[i][j]) matrix[i][j] = tmp;
      }
    }
  }
  return sqrt(matrix[l1][l2]/(double)((l1>l2)?l1:l2));
}

void AlcLevel::print (FILE *fout) {
  for (long i=0; i<nbObjects; i++)
    fprintf(fout, "%li%s", absoluteOnsets[i], ((i<nbObjects-1) ? ", " : "\n"));
  // Debug
  for (long i=0; i<nbObjects; i++)
    fprintf(fout, "%li%s", relativeOnsets[i], ((i<nbObjects-1) ? ", " : "\n"));
  //
  if (labels)
    for (long i=1; i<=nbObjects; i++)
      fprintf(fout, "%i%s", labels[i], ((i<nbObjects) ? ", " : "\n"));
  else
    for (long i=1; i<=nbObjects; i++)
      fprintf(fout, "%i%s", 0, ((i<nbObjects) ? ", " : "\n"));
}

void AlcLevel::printJSon (FILE *fout) {
  fprintf (fout, "  { \"nbObjects\":%li, \"nbClasses\":%i,\n    \"clusteringQuality\":%lf,\n    \"absoluteOnsets\" : [", nbObjects, (config ? config->nbVerticalClasses : 0), kaveQual);
  for (long i=0; i<nbObjects; i++)
    fprintf(fout, "%li%s", absoluteOnsets[i], ((i<nbObjects-1) ? ", " : "],\n"));

  fprintf (fout, "    \"relativeOnsets\" : [");
  for (long i=0; i<nbObjects; i++)
    fprintf(fout, "%li%s", relativeOnsets[i], ((i<nbObjects-1) ? ", " : "],\n"));

  fprintf (fout, "    \"powerToSceneAverage\" : [");
  for (long i=0; i<nbObjects; i++)
    fprintf(fout, "%lf%s", power[i], ((i<nbObjects-1) ? ", " : "],\n"));

  fprintf (fout, "    \"labels\" : [");
  if (labels)
    for (long i=1; i<=nbObjects; i++)
      fprintf(fout, "%i%s", labels[i], ((i<nbObjects) ? ", " : "],\n"));
  else
    for (long i=1; i<=nbObjects; i++)
      fprintf(fout, "%i%s", 0, ((i<nbObjects) ? ", " : "],\n"));

  fprintf (fout, "    \"curve\" : [");
  if (curve)
    for (long i=0; i<nbObjects; i++)
      fprintf(fout, "%lf%s", curve[i], ((i<nbObjects-1) ? ", " : "]}"));
  else
    for (long i=0; i<nbObjects; i++)
      fprintf(fout, "%lf%s", 1., ((i<nbObjects-1) ? ", " : "]}"));
}
