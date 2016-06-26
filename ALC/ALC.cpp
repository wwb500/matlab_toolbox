#include "ALC.h"

AlcConfig *ALC::config;
long ALC::nbFrames;
double **ALC::data;
int ALC::featDim;
double *ALC::zero;

ALC::ALC(const char *configFile, const char *dataFile) {
  this->configFile = configFile;
  fprintf(stderr, "Reading config...\n");
  config = new AlcConfig(configFile);
  assert(config->nbLevels > 0);
  levels = new AlcLevel* [config->nbLevels];

  this->dataFile = dataFile;
  fprintf(stderr, "Reading data...\n");
  FILE *dataIn = openInFile(dataFile);
  double tmp;
  fread(&tmp, sizeof(double), 1, dataIn);
  nbFrames = (long) tmp;
  fread(&tmp, sizeof(double), 1, dataIn);
  featDim = (int) tmp;
  fprintf(stderr, "  %li frames, vector dimension %i\n", nbFrames, featDim);
  zero = new double[featDim];
  memset (zero, 0, featDim*sizeof(double));
  data = newMatrix(nbFrames, featDim);
  fread(data[0], sizeof(double), nbFrames*featDim, dataIn);

  if (config->normalizeData) {
    fprintf(stderr, "Normalizing read data...\n");
    for (int dim=0; dim<featDim; dim++) {
      double min=1E9, max=-1E9;
      for (long i=0; i<nbFrames; i++) {
	if (data[i][dim] > max) max = data[i][dim];
	if (data[i][dim] < min) min = data[i][dim];
      }
      if (max>min)
	for (long i=0; i<nbFrames; i++)
	  data[i][dim] = (data[i][dim]-min)/(max-min);
      else
	for (long i=0; i<nbFrames; i++) data[i][dim] = 0;
    }
  }
  fprintf(stderr, "Done.\nNow analyzing data.\n");
}

void ALC::run () {

  // "trivial" clustering to generate first level objects
  fprintf(stderr, "Level 0 clustering...\n");

  double *curve = new double [nbFrames+1];
  double *last = zero;
  for (long i=0; i<nbFrames; i++) {
    curve[i] = 1/(1+sqDistance(data[i], last));
    last = data[i];
  }
  curve[nbFrames] = sqDistance(last, zero); 
  levels[0] = new AlcLevel(config->levels[0], NULL, curve);

  delete[] curve;

  // Then build each level on top of the previous one

  for (int l=1; l<config->nbLevels; l++) {
    fprintf(stderr, "Level %i clustering...\n", l);
    curve = levels[l-1]->getSegmentationCurve();
    levels[l] = new AlcLevel(config->levels[l], levels[l-1], curve);
  }
  fprintf(stderr, "Final clustering.\n");
  levels[config->nbLevels-1]->doVerticalClustering();
}


double ALC::distance (double *v1, double *v2) {
  return sqrt(sqDistance(v1, v2));
}

double ALC::sqDistance (double *v1, double *v2) {
  double accu = 0;
  for (int i=0; i<featDim; i++)
    accu += (v2[i]-v1[i])*(v2[i]-v1[i]);
  return accu;
}

void ALC::printAll(const char *fileName) {
  FILE *fout = openOutFile(fileName);
  for (int l=0; l<config->nbLevels; l++)
    levels[l]->print(fout);
  fclose(fout);
}

void ALC::printLevel(int l, const char *fileName) {
  FILE *fout = openOutFile(fileName);
  levels[l]->print(fout);
  fclose(fout);
}

void ALC::printJSon(const char *fileName) {
  FILE *fout = openOutFile(fileName);
  fprintf(fout, "{\n  \"nbLevels\":%i,\n  \"nbFrames\":%li,\n  \"dataFile\":\"%s\",\n  \"configFile\":\"%s\",\n  \"levels\":[\n", config->nbLevels, nbFrames, dataFile, configFile);
  for (int l=0; l<config->nbLevels; l++) {
    levels[l]->printJSon(fout);
    if (l<config->nbLevels-1) fprintf(fout, ",");
    fprintf(fout, "\n");
  }
  fprintf(fout, "  ]\n}\n");
  fclose(fout);
}
