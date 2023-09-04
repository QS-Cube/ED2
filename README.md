# QS<sup>3</sup> for ED2

This solver handles systems with XYZ-type exchange terms, Dzyaloshinskii-Moriya terms, Gamma terms, and Zeeman terms between quantum spins of arbitrary spin length (which can be different for each spin). By treating only state spaces where the number of descending operators acting on the fully polarized states is in the range [<i>N</i><sub>↓min</sub>,<i>N</i><sub>↓max</sub>], and by not using bit-string representations of the states, we are able to perform large-scale calculations containing more than 1000 sites in the case of dilute particle systems.

# arXiv

Work in progress.

# License

MIT License.

# External routines/libraries 

BLAS, LAPACK

# Nature of problems

Physical properties (such as the total energy, the magnetic moment, the two-point spin correlation function)

# Solution method

Application software based on the full diagonalization method, and the exact diagonalization using the Lanczos and thick-restart Lanczos methods for quantum spin <i>S</i> models including XYZ-type exchange terms, Dzyaloshinskii-Moriya terms, Gamma terms, and Zeeman terms in the truncated space specified by the number of descending operators.

# Restrictions

Capable of handling first-order (one-body) interaction terms and bi-linear (two-body) interaction terms (not adapted to higher-order many-body interactions)

# Requirements

This package, containing the Fortran source codes and samples, is available. For the building, a Fortran compiler with BLAS/LAPACK library is a prerequisite. 

# Compile

For those who have their own Git accounts, you can clone the repository to your local computer. 

Using SSH:<br>
$ git clone git@github.com:QS-Cube/ED2.git

If you do not have a Git account, navigate to the repository webpage, click on the "Code" button, and select "Download ZIP" to download "ED2-main.zip". The zip file can be unpacked with:

$ unzip main.zip<br>
$ cd ED2-main

A simple Makefile is provided to build the executable file "QS3ED2.exe". The following commands will build the executable file and execute sample programs:

$ ./setup.sh 

Before running setup.sh, open the file and select the compiler (ARG1=gfortran/ifort) and the linear algebra library (ARG2=lapack/mkl). After executing the samples, all results are stored in the examples directories.

# Developers
Hiroshi Ueda, Daisuke Yamamoto and Tokuro Shimokawa
