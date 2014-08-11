##XISF - Separation of intra- and inter-molecular interactions from total x-ray scattering data

#### What is XISF
The program takes experimental total X-ray scattering structure factor data S(Q) as input and performs intermolecule S(Q) extraction using trust-region optimization.

#### Environment
The program is developed in Matlab environment with core cost function written in C. Various performance tuning have been applied to the C code, therefore the program runs efficiently even that it resides in Matlab environment. 

#### How to run 
To start the program, enter the program root directory in Matlab, and type
```matlab
gui
```
in Matlab console, and the GUI will pop up. Enter the sample name, desired intra-molecule SQ fitting range on experimental data (usually from ~5 to max of Q data). The fitting accuracy is a negative integer. For example, -3 means the algorithm will guarantee the residual to be smaller than 10e-3. One can also control the initialization of RMS value by adjusting the mean and variance of the Gaussian. 

After setting up proper input parameters, press "Start" to run the program. Upon finishing, the program will write RMS data and extracted SQ data to working directory. The file name starts with sample name you have entered. 

#### Form factor format
The file 'form_factors' stores the atomic form factors for various interested atoms. You can change or update the file with more recent data. The format of the data is as follow (first two lines):
```
C 2.657506 14.780758 1.078079 0.776775 1.490909 42.086843 -4.241070 -0.000294 0.713791 0.239535 4.297983
N 11.893780 0.000158 3.277479 10.232723 1.858092 30.344690 0.858927 0.656065 0.912985 0.217287 -11.804902
```
Each line corresponds to one atom type starting with the atom name, followed by 5 pairs of a[i] b[i] and one shifting constant c. There are totaly 11 numerical parameters for single atom type. Corrently, the data is taken from:
>Waasmaier D., Kirfel A. New analytical scattering-  factor functions for free atoms and ions. Acta Crystallogr. A  51(3):416–431 (1995). 

#### How to generate coordinate input file
The general work flow is:
Find PDB data file -> Open it in CrystalMaker -> Check the correctness -> Export Coordinate -> Delete extra lines and leave only the coordinates lines.

The file looks like:
```
C        C1      1.21500     0.19840     0.07980
C        C2     -1.21130     0.19250     0.07670
C        C3      1.51180    -1.08760    -0.41210
```
Alternatively, one could use any crystallography program to export the orthornomal basis coordinates and mannually edit the file following the format above.
