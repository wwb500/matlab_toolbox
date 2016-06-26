#include <stdio.h>
#include <string.h>

#include "stuff.h"
#include "Object.h"
#include "Class.h"
#include "kaverages.h"

#include <assert.h>
#include <math.h>

#include "mex.h"


// kaverages(similsMatrix, (nbClasses or initClasses), operationMode, maxIt, randSeed);
// operationMode is optional and defaults to "bo" (see "kaverages.cpp" for details)
// randSeed is optional and defaults to 1. 

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
    
    if (nrhs <2 || nrhs > 5)
        mexErrMsgTxt("2 to 5 input arguments required.");
    else if (nlhs < 1 || nlhs > 2)
        mexErrMsgTxt("1 to 2 output argument expected.");
    
    int d = mxGetM(prhs[0]);
    int n = mxGetN(prhs[0]);
    long seed = 0L;
    
//     if(mxGetClassID(prhs[0])!=mxSINGLE_CLASS)
//         mexErrMsgTxt("need single precision array.");
//     
    
    int k;
    flt *initFloat;

    //fprintf(stderr, "Copying init...\n");

    char *mode = new char [5];
    mode[0]='b'; mode[1]='o'; mode[2]=0; // the best in my first tests
    if (nrhs>=3) mxGetString(prhs[2], mode, 4);

    int maxIt = 500;
    if (nrhs>=4) maxIt = (int)mxGetScalar(prhs[3]);

    flt randSeed = 1;
    if (nrhs==5) randSeed = mxGetScalar(prhs[4]);
    srand(randSeed);
      
    
#ifdef USE_DOUBLE
    if (!mxIsDouble(prhs[1]))
      mexErrMsgTxt("As compiled, k-medoids requires a double precision matrix. Modify your matlab code, or change the k-medoids configuration in 'stuff.h'.");
    initFloat = (flt*) mxGetPr(prhs[1]);
#else
    if (mxIsDouble(prhs[1]))
      mexErrMsgTxt("As compiled, k-medoids requires a single precision matrix. Modify your matlab code, or change the k-medoids configuration in 'stuff.h'.");
    initFloat = (flt*) mxGetData(prhs[1]);
#endif

    int *init = new int[n];
    if (mxGetN(prhs[1])==1) {
      k= (int) mxGetScalar(prhs[1]);
      init=NULL;
    } else {
      int min= n, max=0;
      for (int i=0; i<n; i++) {
	init[i]=(int) initFloat[i];
	if (init[i]<min) min=init[i];
	if (init[i]>max) max=init[i]; 
      }
      k=max-min+1;
      for (int i=0; i<n; i++)
	init[i] -= min;
    }

    //fprintf(stderr, "Init copied.\n");
    
    int niter = 50, redo = 1, nt = 1, verbose = 0;
//     
//     {
//         int i;
//         for(i = 2 ; i < nrhs ; i += 2) {
//             char varname[256];
//             if (mxGetClassID(prhs[i]) != mxCHAR_CLASS)
//                 mexErrMsgTxt("variable name required");
//             
//             if (mxGetString(prhs[i], varname, 256) != 0)
//                 mexErrMsgTxt("Could not convert string data");
//             
//             if (!strcmp(varname, "niter"))
//                 niter = (int) mxGetScalar(prhs[i+1]);
//             
//             else if (!strcmp(varname, "redo"))
//                 redo = (int) mxGetScalar(prhs[i+1]);
//             
//             else if (!strcmp(varname, "seed"))
//                 seed = (int) mxGetScalar(prhs[i+1]);
//             
//             else if (!strcmp(varname, "verbose"))
//                 verbose = (int) mxGetScalar(prhs[i+1]);
//             
//             else if (!strcmp(varname, "init")) {
//                 int init_type = (int) mxGetScalar(prhs[i+1]);
//                 
//             }
//             
//             else
//                 mexErrMsgTxt("unknown variable name");
//         }
//     }

    if(n < k) {
        mexErrMsgTxt("fewer points than classes");
    }

    /* ouput: assignment */
    
    int * assign = NULL;
    
    plhs[0] = mxCreateNumericMatrix(n, 1, mxINT32_CLASS, mxREAL);
    assign = (int*) mxGetPr(plhs[0]);

    int *nbIt = NULL;

    
    if (nlhs==2) {
      plhs[1] = mxCreateNumericMatrix(1, 1, mxINT32_CLASS, mxREAL);
      nbIt = (int*) mxGetPr(plhs[1]);
    }    

    const mxArray *inSimils = prhs[0];
    flt *v;

#ifdef USE_DOUBLE
    if (!mxIsDouble(inSimils))
      mexErrMsgTxt("As compiled, k-medoids requires a double precision matrix. Modify your matlab code, or change the k-medoids configuration in 'stuff.h'.");
    v = (flt*) mxGetPr(prhs[0]);
#else
    if (mxIsDouble(inSimils))
      mexErrMsgTxt("As compiled, k-medoids requires a single precision matrix. Modify your matlab code, or change the k-medoids configuration in 'stuff.h'.");
    v = (flt*) mxGetData(prhs[0]);
#endif
    SparseMatrix *sm;

    if (mxIsSparse(inSimils)) {
      size_t *ir = (size_t*) mxGetIr(inSimils);
      size_t *jc = (size_t*) mxGetJc(inSimils);
      // for (int j=0; j<n; j++) fprintf(stderr, "%i\n", jc[j]);
      sm = new SparseMatrix(n, n, ir, jc, v);
    } else {
      sm = new SparseMatrix(n, n);
      for (int k=0; k<n; k++)
          sm->setLine(k, &(v[k*n]));
    }

    if (verbose)
      printf("Input: similarity matrix of dimension %d\nk=%d niter=%d "
	     "redo=%d verbose=%d seed=%d v1=[%g %g ...], v2=[%g %g... ]\n",
	     n, d, k, niter, redo, verbose, seed, v[0], v[1], v[d], v[d+1]);



    // for (int k=0; k<n; k++) {
    //     for (int l=0; l<n; l++) {
    //         fprintf(stderr, "%f ", sm->getValue(k, l));
    //     }
    //     fprintf(stderr, "\n");
    // }
  
    //fprintf(stderr, "kAveragesClustering...\n");
    *nbIt = kAveragesClustering(n, k, sm, assign, mode, maxIt, init);
    
    delete sm;
    delete[] init;
    
    /* post-processing: Matlab starts from 1 */
    if (assign)
      for (int i = 0 ; i < n ; i++)
        assign[i]++;
}
