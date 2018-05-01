## XISF - Separation of intra- and inter-molecular interactions from total x-ray scattering data

#### What is XISF
XISF is a Matlab program that takes experimental total X-ray scattering structure factor S(Q) as input and extracts intermolecule structure factor S(Q) by using trust-region class optimization algorithm.


#### System Requirement
To run the program as standalone Windows app, following requirements must be met:

(1). Windows 7/8/8.1 64 bit (x64) operating system

(2). MATLAB Compiler Runtime (MCR) R2014b (8.4) 64 bit (x64), download link: http://www.mathworks.com/products/compiler/mcr/

(3). Visual C++ Redistributable Packages for Visual Studio 2013 64 bit (x64), download link: http://www.microsoft.com/en-us/download/details.aspx?id=40784

#### How to run the program
Download the latest release and install the required runtime library as mentioned in the requirements, then double click win_x64.exe to start the standalone app.

If you have a copy of MATLAB, then an alternative way is to start the GUI using Matlab command line: 

```matlab
cd path-to-XISF-directory
```
and start the GUI
```matlab
gui
```

Enter the sample name, desired intra-molecule SQ fitting range on experimental data (usually from q=4 to the max of S(q) data). The fitting accuracy is a negative integer. For example, -3 means the target residual of fitted S(q) data is smaller than 1e-3. The initial root-mean-square (rms) value is sampled from Gaussian distribution. One can adjust the mean and standard deviation of the Gaussian according to their needs.

After setting up proper input parameters, press "Start" to run the program. Upon finishing, the program will write RMS data and extracted SQ data to XISF root directory in ASCII format. The file name starts with text that was entered earlier. 

#### The input controls
The table gives a summary of the input parameters used in XISF:


| Parameter       | Detail                          | Range    | Default   |
|-----------------|---------------------------------|----------|-----------|
| min Q           | Lower bound of the fitting range| > 2      | 6         |
| max Q           | Upper bound of the fitting range| -        | 16        |
| accuracy        | Stopping threshhold             | < -1     | -3        |
|mean of Gaussian | The mean of random Gaussian sampling | > 0 | 0.07      |
|s.t.d of Gaussian| The standard devitaion of the Gaussian | > 0| 0.03 |

#### Optimization Algorithm
Right now XISF provide two algoritms: one local optimizer and one global optimizer. Both are based on trust-region-reflect none-linear optimization method. The trust region method belongs to line search method. It uses a easier to compute quadratic surface to approximate the objective function within an adjustable radius, within which is called the trust region. This algorithm is more efficient for large-scale problem, and hence we choose it to optimize the inter-molecular strcuture factor. 

The global optimizer is the Multi-Start method provided by MATLAB. The underlying optimizer is still trust-region-reflect routine. Multi-start will calculate from a set of different initial conditions and return the best solution based on the residual error. In XISF, the global optimizer is set to calculate 20 paths, therefore it will take significantly longer than local optimizer. We suggest the user to start with the default local optimizer for large molecules.

#### Form factor format
The file 'form_factors' stores the atomic form factors for various interested atoms. You can change or update the file with more recent data. The format of the data is as follow (first two lines):
```
C 2.657506 14.780758 1.078079 0.776775 1.490909 42.086843 -4.241070 -0.000294 0.713791 0.239535 4.297983
N 11.893780 0.000158 3.277479 10.232723 1.858092 30.344690 0.858927 0.656065 0.912985 0.217287 -11.804902
```
Each line corresponds to one atom type starting with the atom name, followed by 5 pairs of a[i] b[i] and one shifting constant c. There are totaly 11 numerical parameters for single atom type. Currently, the data is taken from:
>Waasmaier D., Kirfel A. New analytical scattering-  factor functions for free atoms and ions. Acta Crystallogr. A  51(3):416–431 (1995). 

#### How to generate coordinate input file
The general work flow is:
Find PDB data file -> Open it in CrystalMaker -> Check the correctness -> Export Coordinate -> Delete extra lines and leave only the coordinates lines.

The format is
```
Atom        identifier      x     y     z
```
The coordinates should be in angstrom unit.

The actual file looks like:
```
C        C1      1.21500     0.19840     0.07980
C        C2     -1.21130     0.19250     0.07670
C        C3      1.51180    -1.08760    -0.41210
```

Alternatively, one could use any crystallography program to export the orthornomal basis coordinates and mannually edit the file following the format above.

#### Citation
Please cite this work if you find it useful:
Mou, Q., Benmore, C. J., & Yarger, J. L. (2015). X-ray Intermolecular Structure Factor (XISF): Separation of intra- and intermolecular interactions from total X-ray scattering data. Journal of Applied Crystallography, 48, 950-952. DOI: 10.1107/S1600576715005518
