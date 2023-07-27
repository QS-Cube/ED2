#!/bin/sh
#################################
# ARG1 = ifort / gfortran
# ARG2 = lapack / mkl
#################################
ARG1=gfortran 
ARG2=mkl
#################################
echo "cd ../"
cd ../
echo "./configure FC=${ARG1} --with-lapak=${ARG2}"
./configure FC=${ARG1} --with-lapack=${ARG2}
echo "make"
make
echo "mv source/QS3ED2 QS3ED2.exe"
mv source/QS3ED2 ./QS3ED2.exe 1> /dev/null 2>&1
#
echo "**************"
echo  "  ex 1) S=1/2 XYZ+DM+H model on the periodic chain"
echo  "       See run.sh for details on parameters."
echo "**************"
echo "cd script; ./run.sh"
cd script; ./run.sh
