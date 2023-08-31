#!/bin/sh
##################################################
#export OMP_NUM_THREADS=4
##################################################
for wk_dim in 0 1482 2965 5930 11860 23719; do
sed -e "s|Nwk_dim|$wk_dim|g" input.dat > input_${wk_dim}.dat
../../QS3ED2.exe < input_${wk_dim}.dat > output_${wk_dim}.dat
done
##################################################
