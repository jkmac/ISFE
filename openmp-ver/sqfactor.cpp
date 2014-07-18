#include "mex.h"
#include <matrix.h>
#include <string.h>
#include <assert.h>
#include <math.h>
#include <omp.h>

// nx is r, nxq is xdata, strlN is atom_lst length respectively, nyf is atomff population
static mwSize nx, nxq, strlN, nxf, nyf;

__inline void clear(double *lst) {
    for (int i=0; i<nxq; i++) {
        lst[i] = 0;
    }
}

__inline void J(double *reslt, double r, double *xdata) {
#pragma omp parallel for
    for (int i=0; i<nxq; i++) {
        double t1;
        t1 = r*xdata[i];
        reslt[i] = sin(t1)/t1;
    }
}

__inline void addconst(double *reslt, double *x, const double y) {
    for (int i=0; i<nxq; i++) {
    reslt[i] = x[i]+y;
    }
}

__inline void dotp(double *reslt, double *x, double *y) {
    for (int i=0; i<nxq; i++) {
    reslt[i] = x[i]*y[i];
    }
}

__inline void add(double *reslt, double *x, double *y) {
    for (int i=0; i<nxq; i++) {
    reslt[i] = x[i]+y[i];
    }
}

__inline void expX(double *reslt, const double pre, const double x, double *xdata) {
    // calculate pre*exp(x*xdata.^2)
    dotp(reslt, xdata, xdata);  //reslt hold xdata.^2
#pragma omp parallel for
    for (int i=0; i<nxq; i++) {
        reslt[i] = pre*exp(x*reslt[i]);
    }
}

//nxf should be 11, formfactor elements for each atom, nyf should be 10, current atoms in the list
__inline void F(double *reslt, char *a, double *xdata, const double *formf, char**atomff_idx) {
    int flag = 0;
    int i, k;
    double *fct, *tmp, *tmp1;
    fct = (double *)mxMalloc(nxf*sizeof(double));

    tmp = (double *)mxMalloc(nxq*sizeof(double));   //hold tmp vector of xdata size
    tmp1 = (double *)mxMalloc(nxq*sizeof(double));

    clear(tmp);
    clear(tmp1);
    for (k=0; k<nyf; ++k) {
        if (strcmp(a, atomff_idx[k]) == 0) {
	    //mexPrintf("found atom %s\n", a);
            for (i=11; i--;) {          //subsitute 11 with nxf if nxf is not 11 anymore (list change)
                fct[i] = formf[k*11 + i];
            }
            flag = 1;
        }
    }
    //mxAssert(flag, "mxAssert:F atom not found in form factor list, please update the list manually.");
    expX(tmp, fct[0], -fct[1], xdata);
    add(tmp1, tmp1, tmp);
    expX(tmp, fct[2], -fct[3], xdata);
    add(tmp1, tmp1, tmp);
    expX(tmp, fct[4], -fct[5], xdata);
    add(tmp1, tmp1, tmp);
    expX(tmp, fct[6], -fct[7], xdata);
    add(tmp1, tmp1, tmp);
    expX(tmp, fct[8], -fct[9], xdata);
    add(tmp1, tmp1, tmp);
    clear(reslt);
    addconst(reslt, tmp1, fct[10]);
    mxFree(fct);
    mxFree(tmp);
    mxFree(tmp1);
}

void sqfactor(double *x, double *xdata, double *res, const double *r, const double *formf, char **atom_lst, char **atomff_idx, char **plst1, char **plst2) {
    double *f1, *f2, *ft, *tmp1, *norm;
    f1 = (double *)mxMalloc(nxq*sizeof(double));
    f2 = (double *)mxMalloc(nxq*sizeof(double));
    ft = (double *)mxMalloc(nxq*sizeof(double));
    //zero vectors
    tmp1 = (double *)mxMalloc(nxq*sizeof(double));
    norm = (double *)mxMalloc(nxq*sizeof(double));

    clear(tmp1);
    clear(norm);

    //extract string name of atom pair
    //fc = fc + f(a1,xdata).*f(a2,xdata).*J(r(k)*xdata).*exp(-0.5*x(k)^2*xdata.^2);
    for (int i=0; i<nx; i++) {
        F(f1, plst1[i], xdata, formf, atomff_idx);
        F(f2, plst2[i], xdata, formf, atomff_idx);
        dotp(ft, f1, f2);            //f hold f1*f2
        J(f1, r[i], xdata);         //f1 hold J(r.*xdata)
        expX(f2, 1.0, -0.5*x[i]*x[i], xdata);  //f2 hold exp(...)
        dotp(f1, f1, f2);       //f1 hold J()*exp()
        dotp(f2, ft, f1);            //f2 hold f1()*f2()*J()*exp()
        add(tmp1, tmp1, f2);
    }
    // fast version ?
    for (int i=0; i<strlN; i++) {
        F(f1, atom_lst[i], xdata, formf, atomff_idx);    //f1 hold f()                     //f2 hold f().^2
        add(norm, norm, f1);
    }
    dotp(ft, norm, norm);           //ft = norm.^2
    addconst(norm, ft, 0.01);    //prevent near zero element in ft vector
#pragma omp parallel for
    for (int i=0; i<nxq; i++) {
        double t = tmp1[i];
        tmp1[i] = t/norm[i];       //tmp1 hold f./normf the normalized
    }
#pragma omp parallel for
    for (int i=0; i<nxq; i++) {
        double m1, m2;
         res[i] = x[nx]*tmp1[i] + x[nx+1]/xdata[i];
    }

    mxFree(f1); 
    mxFree(f2);
    mxFree(ft);
    mxFree(tmp1);
    mxFree(norm);
}

void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[])
{
    
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
    nx = mxGetM(array_r);   //r length  
    const double *r = mxGetPr(array_r);

    // load global formf matrix
    matx_formf = mexGetVariable("global", ffname);  //should be 11x10 matrix, after reading should be 10x11(original size)
    
    nxf = mxGetM(matx_formf);     //x is col order, vertical
    nyf = mxGetN(matx_formf);     //y is row order, horizontal

    const double *formf = mxGetPr(matx_formf);      //formf is row-major order now
    //---------------------------------------------------------------------------------
    // load atom_lst
    mxArray *atom_idx;
    char *buf;

    atom_idx = mexGetVariable("global", atype);
    buf = mxArrayToString(atom_idx);
    strlN = mxGetN(atom_idx);   //atom list length, atom population
    mwSize strsN = mxGetM(atom_idx);
    

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
    
    // load atomff_index
    mxArray *atom_idx1;
    char *buf1;

    atom_idx1 = mexGetVariable("global", affindex);
    buf1 = mxArrayToString(atom_idx1);
    mwSize strlN1 = mxGetN(atom_idx1);
    mwSize strsN1 = mxGetM(atom_idx1);
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
    
    // load pinfo1
    mxArray *atom_idx2;
    char *buf2;

    atom_idx2 = mexGetVariable("global", pname1);
    buf2 = mxArrayToString(atom_idx2);
    mwSize strlN2 = mxGetN(atom_idx2);
    mwSize strsN2 = mxGetM(atom_idx2);
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
    
    // load pinfo2, use the same buffer parameters, since they are same size
    atom_idx2 = mexGetVariable("global", pname2);
    buf2 = mxArrayToString(atom_idx2);
    strlN2 = mxGetN(atom_idx2);
    strsN2 = mxGetM(atom_idx2);
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
    
    //load all required local input parameters
    //---------------------------------------------------------------------------------
    double *x;
    double *xdata;
    double *res;
    nxq = mxGetM(prhs[1]);      //xdata length;

    x = mxGetPr(prhs[0]);
    xdata = mxGetPr(prhs[1]);

    plhs[0] = mxCreateDoubleMatrix(nxq, 1, mxREAL);
    res = mxGetPr(plhs[0]);
    //call working function
    sqfactor(x, xdata, res, r, formf, atom_lst, atomff_idx, plst1, plst2);
    
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
