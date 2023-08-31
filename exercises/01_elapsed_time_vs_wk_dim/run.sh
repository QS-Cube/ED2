#!/bin/sh
##################################################
# The results are obtained by using dual cpu of 
# Intel(R) Xeon(R) Platinum 9242 CPU @ 2.30GHz
#export OMP_NUM_THREADS=96
##################################################
#for wk_dim in 0 1482 2965 5930 11860 15000 17000 19000 21000 23000 23700 23719; do
#sed -e "s|Nwk_dim|$wk_dim|g" input.dat > input_${wk_dim}.dat
#../../QS3ED2.exe < input_${wk_dim}.dat > output_${wk_dim}.dat
#echo $wk_dim `grep Time output_${wk_dim}.dat` >> time_vs_wk_dim.dat
#done
#gnuplot fig_01.gp
evince fig_01.eps &
##################################################
