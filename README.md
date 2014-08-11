#XISF -Separation of intra- and inter-molecular interactions from total x-ray scattering data

#### What is XISF
The program takes experimental total scattering SQ data as input and performs intra-molecule SQ extraction basing on optimization algorithm.

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
The 'form_factors' stores the atomic form factors for various common atoms. You can change or update the list with recent data but should follow the general formating. Each row corresponds to one atom, starts with the atom name, followed by 11 float numbers in the order of a[i] b[i] for i = 1:5 (10 total) plus one shifting constant c.


#### How to generate coordinate input file
The general work flow is:
Find PDB data file -> Open it in CrystalMaker -> Check the correctness -> Export Coordinate -> Delete extra lines and leave only the coordinates lines
The file looks like:
```
C        C1      1.21500     0.19840     0.07980
C        C2     -1.21130     0.19250     0.07670
C        C3      1.51180    -1.08760    -0.41210
```

