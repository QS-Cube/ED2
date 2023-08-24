#!/bin/sh
#################################
# ARG1 = ifort / gfortran
# ARG2 = lapack / mkl
#################################
ARG1=gfortran 
ARG2=mkl
#################################
echo "./configure FC=${ARG1} --with-lapak=${ARG2}"
./configure FC=${ARG1} --with-lapack=${ARG2}
echo "make"
make
echo "mv source/QS3ED2 QS3ED2.exe"
mv source/QS3ED2 ./QS3ED2.exe 1> /dev/null 2>&1
#
echo "**************"
echo  "  ex 1) S=1/2 XYZ+DM+Gamma+H model on the periodic chain"
echo  "       See run.sh for details on parameters."
echo "**************"
echo "cd script_chain; ./run.sh; cd -"
cd script_chain; ./run.sh; cd -
#
echo "**************"
echo  "  ex 2) S=1/2 XYZ+DM+Gamma+H J1-J2 model on the periodic chain"
echo  "        See run.sh for details on parameters."
echo "**************"
echo "cd script_j1j2_chain; ./run.sh; cd -"
cd script_j1j2_chain; ./run.sh; cd -
#
echo "**************"
echo  "  ex 3) S=(1/2,3/2) XYZ+DM+Gamma+H mixed-spin model on the periodic chain"
echo  "        See run.sh for details on parameters."
echo "**************"
echo "cd script_mixed_spin_chain; ./run.sh; cd -"
cd script_mixed_spin_chain; ./run.sh; cd -
#
echo "**************"
echo  "  ex 4) S=1/2 XYZ+DM+Gamma+H model on the square lattice"
echo  "        See run.sh for details on parameters."
echo "**************"
echo "cd script_square; ./run.sh; cd -"
cd script_square; ./run.sh; cd -
#
echo "**************"
echo  "  ex 5) S=1/2 XYZ+DM+Gamma+H model on the triangular lattice"
echo  "        See run.sh for details on parameters."
echo "**************"
echo "cd script_triangular; ./run.sh; cd -"
cd script_triangular; ./run.sh; cd -
#
echo "**************"
echo  "  ex 6) S=1/2 XYZ+DM+Gamma+H model on the honeycomb lattice"
echo  "        See run.sh for details on parameters."
echo "**************"
echo "cd script_honeycomb; ./run.sh; cd -"
cd script_honeycomb; ./run.sh; cd -
#
echo "**************"
echo  "  ex 7) S=1/2 XYZ+DM+Gamma+H model on the kagome lattice"
echo  "        See run.sh for details on parameters."
echo "**************"
echo "cd script_kagome; ./run.sh; cd -"
cd script_kagome; ./run.sh; cd -
#
echo "**************"
echo  "  ex 8) S=1/2 XYZ+DM+Gamma+H model on the cubic lattice"
echo  "        See run.sh for details on parameters."
echo "**************"
echo "cd script_cubic; ./run.sh; cd -"
cd script_cubic; ./run.sh; cd -
#
echo "**************"
echo  "  ex 9) S=1/2 Heisenberg model on the cubic lattice"
echo  "        Translational Symm. and Bond-inversion Symm."
echo  "        See run.sh for details on parameters."
echo "**************"
echo "cd script_cubic_sp_HB; ./run.sh; cd -"
cd script_cubic_sp_HB; ./run.sh; cd -
#
echo "**************"
echo "Each result are stored in each directry at ./examples"
echo "**************"
