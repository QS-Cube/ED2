set terminal postscript eps enhanced color
#
set font "Times-Roman, 16"
set output "fig_01.eps"
set key bottom left
set size 0.6, 0.6
#
set xlabel "wk\\_dim/D" font "Times-Roman,24"
set format x "%2.1f"
set xtics
set mxtics
set xrange [0:1]
#
set ylabel "elapsed time [sec]" font "Times-Roman,24"
set format y "%2.0f"
set ytics nomirror
set mytics
set yrange [0:100]

set y2label "Mem. [MB]" font "Times-Roman,24"
#set format y2 "%2.1f"                         
set y2tics                                    
set my2tics                                   
set yrange [:]

D=23719

set label 1 left at first 0.1,graph 0.9 "Calc. conditions: ex.9) cubic\\_sp\\_HB, D=23719" font "Times-Roman,10"
set label 2 left at first 0.1,graph 0.80 "CPU: Intel(R) Xeon(R) Platinum 9242 x 2" font "Times-Roman,10"


set style arrow 1 size character 1.5,10 filled linewidth 2
set arrow 2 from 0.3,55 to 0.2,55 arrowstyle 1 lc 1
set arrow 1 from 0.6,55 to 0.7,55 arrowstyle 1 lc 2


f(x) = a*x + b
fit f(x) "time_vs_wk_dim.dat" u ($1/23719):3 via a,b

#MEM: (16*3*D + 4*D + 16*(x*19) + 4*(x*19))/2^20 [MB]

g(x) = ( 16*3*D + 4*D + 16*(x*D*19) + 4*(x*D*19) ) / (2**20)

dt1  = "dt (1,4)"
dt2  = "dt (5,5)"

plot \
"time_vs_wk_dim.dat" u ($1/D):3 w p pt 6 ps 1 lc 1 notitle "", \
f(x) w l @dt1 lc 1 notitle "", \
g(x) axis x1y2 w l @dt2 lc 2 notitle ""
