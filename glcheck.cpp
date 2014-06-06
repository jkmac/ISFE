#include "mex.h"
#include <matrix.h>
#include <string.h>
#include <assert.h>
#include <math.h>

// nx is r, nxq is xdata, strlN is atom_lst length respectively, nyf is atomff population
static mwSize nx, nxq, strlN, nxf, nyf;

void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[])
{
    //check input parameters
    if (nrhs !=2) {
        mexErrMsgIdAndTxt( "MATLAB:myfit:minrhs",
                "2 input arguments required.");
    }
    if(nlhs != 1){
        mexErrMsgIdAndTxt( "MATLAB:myfit:maxrhs",
                "Requires 1 output argument.");
    }
    
    //load all required global parameters
    //---------------------------------------------------------------------------------
	mxArray *array_r;
    mxArray *matx_formf;
    const char *rname = "r";
    const char *ffname = "formf";
    const char *atype = "atom_type";
    const char *affindex = "atomff_index";
    const char *pname1 = "pinfo1";
    const char *pname2 = "pinfo2";

    //2D char matrix hold global variable
    int status;
    char **atom_lst, **atomff_idx;
    char **plst1, **plst2;

    //---------------------------------------------------------------------------------
    // load global r
	array_r = mexGetVariable("global", rname);
    if (array_r == NULL ) {
        mexPrintf("Variable %s\n", rname);
        mexErrMsgIdAndTxt( "MATLAB:myfit:invalidGlobalVarState",
                    "Global variable was cleared from the MATLAB global workspace.\n");
        //array_r=mxCreateDoubleMatrix(1,1,mxREAL);
    }
    nx = mxGetM(array_r);   //r length
    if(mxGetN(array_r) != 1 || nx < 1) {
    mexErrMsgIdAndTxt("MyToolbox:myfit:notRowVector",
                      "Global r must be a column vector.");
	}     
    if (status==1){
        mexPrintf("Variable %s\n", rname);
        mexErrMsgIdAndTxt( "MATLAB:myfit:errorSettingGlobal",
                "Could not put variable in global workspace.\n");
    }
    const double *r = mxGetPr(array_r);

    // load global formf matrix
    matx_formf = mexGetVariable("global", ffname);  //should be 11x10 matrix, after reading should be 10x11(original size)
    if (matx_formf == NULL ) {
        mexPrintf("Variable %s\n", ffname);
        mexErrMsgIdAndTxt( "MATLAB:myfit:invalidGlobalVarState",
                    "Global variable was cleared from the MATLAB global workspace.\n");
    }
    
    nxf = mxGetM(matx_formf);     //x is col order, vertical
    nyf = mxGetN(matx_formf);     //y is row order, horizontal
    mxAssert(nyf == 10, "mxAssert:form factor atoms should be 10");
    mxAssert(nxf == 11, "mxAssert:form factor parameter shoud 11 for each atom");
    //mexPrintf("Original formf matrix's transpose is %ix%i\n", nxf, nyf);
    const double *formf = mxGetPr(matx_formf);      //formf is row-major order now
    // for (int i=0; i<nxf*nyf; ++i) {
    //     mexPrintf("%6.4f ", *(formf+i));
    //     if (fmod(i+1,11) == 0)
    //         mexPrintf("\n");
    // }

    //---------------------------------------------------------------------------------
    // load atom_lst
    mxArray *atom_idx;
    char *buf;

    atom_idx = mexGetVariable("global", atype);
    buf = mxArrayToString(atom_idx);
    strlN = mxGetN(atom_idx);   //atom list length, atom population
    mwSize strsN = mxGetM(atom_idx);
    /*
    for (int k=0; k<strlN; ++k) {
	int j = 2*k;
	mexPrintf("buf[%i], buf[%i] is %c %c\n", j, j+1, buf[j], buf[j+1]);
    }
    */
    
    //mexPrintf("mxArray length is %i, width is %i\n", strsN, strlN);

    atom_lst = (char**)mxMalloc(strlN*sizeof(char*));
    for (int i=0; i<strlN; ++i) {
	atom_lst[i] = (char *)mxMalloc((strsN+1)*sizeof(char));
    }
    for (int i=0; i<strlN; ++i) {
        int j=2*i;
        strncpy(atom_lst[i], buf+j, 2);
        atom_lst[i][strsN] = '\0';
        //mexPrintf("%s", atom_lst[i]);
    }
    //mexPrintf("\n");
    
    // load atomff_index
    mxArray *atom_idx1;
    char *buf1;

    atom_idx1 = mexGetVariable("global", affindex);
    buf1 = mxArrayToString(atom_idx1);
    mwSize strlN1 = mxGetN(atom_idx1);
    mwSize strsN1 = mxGetM(atom_idx1);
    //mexPrintf("mxArray length is %i, width is %i\n", strsN1, strlN1);
    // mexPrintf("%s\n", buf);
    atomff_idx = (char**)mxMalloc(strlN1*sizeof(char*));
    for (int i=0; i<strlN1; ++i) {
	atomff_idx[i] = (char *)mxMalloc((strsN1+1)*sizeof(char));
    }
    for (int i=0; i<strlN1; ++i) {
        int j=2*i;
        strncpy(atomff_idx[i], buf1+j, 2);
        atomff_idx[i][strsN1] = '\0';
        //mexPrintf("%s", atomff_idx[i]);
    }
    //mexPrintf("\n");
    
    // load pinfo1
    mxArray *atom_idx2;
    char *buf2;

    atom_idx2 = mexGetVariable("global", pname1);
    buf2 = mxArrayToString(atom_idx2);
    mwSize strlN2 = mxGetN(atom_idx2);
    mwSize strsN2 = mxGetM(atom_idx2);
    //mexPrintf("mxArray length is %i, width is %i\n", strsN2, strlN2);
    // mexPrintf("%s\n", buf);
    plst1 = (char**)mxMalloc(strlN2*sizeof(char*));
    for (int i=0; i<strlN2; ++i) {
        plst1[i] = (char *)mxMalloc((strsN2+1)*sizeof(char));
    }
    for (int i=0; i<strlN2; ++i) {
        int j=2*i;
        strncpy(plst1[i], buf2+j, 2);
        plst1[i][strsN2] = '\0';
        //mexPrintf("%s", plst1[i]);
    }
    //mexPrintf("\n");
    
    // load pinfo2, use the same buffer parameters, since they are same size
    atom_idx2 = mexGetVariable("global", pname2);
    buf2 = mxArrayToString(atom_idx2);
    strlN2 = mxGetN(atom_idx2);
    strsN2 = mxGetM(atom_idx2);
    //mexPrintf("mxArray length is %i, width is %i\n", strsN2, strlN2);
    // mexPrintf("%s\n", buf);
    plst2 = (char**)mxMalloc(strlN2*sizeof(char*));
    for (int i=0; i<strlN2; ++i) {
        plst2[i] = (char *)mxMalloc((strsN2+1)*sizeof(char));
    }
    for (int i=0; i<strlN2; ++i) {
        int j=2*i;
        strncpy(plst2[i], buf2+j, 2);
        plst2[i][strsN2] = '\0';
        //mexPrintf("%s", plst2[i]);
    }
    //mexPrintf("\n");
    
    // simple test
    // test string array length consistancy
    const mwSize sz = sizeof(atomff_idx[0]);
    for (int k=0; k<strlN; ++k) {
	if(sz != sizeof(atom_lst[k]) )
	    mexErrMsgIdAndTxt( "MATLAB:myfit:invalidAtomListName:length", "Name length is not consistant with form factor atom name, check formating of the file.");
    }
    
    mxAssert(!strcmp(atom_lst[0], atomff_idx[0]), "mxAssert:strcmp of atom_lst[0] and atomff[0] failed");
    //mxAssert(!strcmp(plst1[0], plst2[0]), "mxAssert:strcmp of plst1[0] and plst2[0] failed");
    mxAssert(nx == strlN2, "mxAssert:r and pinfo length test failed");
    
    //load all required local input parameters
    //---------------------------------------------------------------------------------
    double *x;
    double *xdata;
    double *res;
    nxq = mxGetM(prhs[1]);      //xdata length;

    if(mxGetM(prhs[0]) < 1 || mxGetN(prhs[0]) != 1) {
    mexErrMsgIdAndTxt("MyToolbox:myfit:notRowVector",
                      "Input x0 must be a column vector.");
    }
    if(mxGetM(prhs[1]) < 1 || mxGetN(prhs[1]) != 1) {
    mexErrMsgIdAndTxt("MyToolbox:myfit:notRowVector",
                      "Input xdata must be a column vector.");
    }
    x = mxGetPr(prhs[0]);
    xdata = mxGetPr(prhs[1]);

    plhs[0] = mxCreateDoubleMatrix(nxq, 1, mxREAL);
    if (plhs[0] == NULL ) {
        mexErrMsgIdAndTxt( "MATLAB:myfit:invalidAllocationResult",
                    "Failed to allocate memory for plhs[0] in myfit.cpp\n");
    }
    res = mxGetPr(plhs[0]);
    *res = 0;
    
    // clean mxArray
    mxDestroyArray(array_r);
    mxDestroyArray(atom_idx);
    mxDestroyArray(atom_idx1);
    mxDestroyArray(atom_idx2);
    mxDestroyArray(matx_formf);

    // free dynamically allocated memory
    for (int i=0; i< strlN; ++i) {
        mxFree(atom_lst[i]);
    }
    mxFree(atom_lst);

    for (int i=0; i< strlN1; ++i) {
        mxFree(atomff_idx[i]);
    }
    mxFree(atomff_idx);
    
    for (int i=0; i< strlN2; ++i) {
        mxFree(plst1[i]);
    }
    mxFree(plst1);
    
    for (int i=0; i< strlN2; ++i) {
        mxFree(plst2[i]);
    }
    mxFree(plst2);
}