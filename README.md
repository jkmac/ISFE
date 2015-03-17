##XISF - Separation of intra- and inter-molecular interactions from total x-ray scattering data

#### What is XISF
The program takes experimental total X-ray scattering structure factor data S(Q) as input and performs intermolecule S(Q) extraction using trust-region optimization method.


#### System Requirement
For standalone Windows x64 app:

(1). Windows 7/8/8.1 64 bit (x64) operating system

(2). MATLAB Compiler Runtime (MCR) R2014b (8.4) 64 bit (x64), download link: http://www.mathworks.com/products/compiler/mcr/

(3). Visual C++ Redistributable Packages for Visual Studio 2013 64 bit (x64), download link: http://www.microsoft.com/en-us/download/details.aspx?id=40784

#### How to run
For standalone version, download the entire code repository and install the required runtime library, then double click win_x64.exe to start the standalone application.

If you have a copy of MATLAB, start the gui program in MATLAB command line enviroment: 

```matlab
cd path-to-XISF-directory
```
and start the GUI
```matlab
gui
```
 Enter the sample name, desired intra-molecule SQ fitting range on experimental data (usually from q=4 to the max of S(q) data). The fitting accuracy is a negative integer. For example, -3 means the target residual of fitted S(q) data is smaller than 10e-3. The initial root-mean-square (rms) value is sampled from Gaussian distribution. One can adjust the mean and standard deviation of the Gaussian according to their needs.

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
