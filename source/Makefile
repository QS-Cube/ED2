#program name
PROGS   = ../QS3.exe

#using source code
SRC     = \
input_param.f90 \
state_lists.f90 \
ham2vec.f90 \
lanczos.f90 \
eigen_solver.f90 \
get_expectation_values.f90 \
main.f90

#source name --> object name
OBJ      = $(SRC:.f90=.o)

#options for compiling
#######################################################
FC      = gfortran
FCFLAGS = -Ofast -fopenmp -Ofast
# -Wall -pedantic -fbounds-check -O -Wuninitialized -fbacktrace -fopenmp #-Ofast 
# (for debug options) 
MKLROOT = /opt/intel/oneapi/mkl/latest
INCLUDE = -m64  -I"${MKLROOT}/include"
LIB     = -Wl,--start-group ${MKLROOT}/lib/intel64/libmkl_gf_lp64.a ${MKLROOT}/lib/intel64/libmkl_gnu_thread.a ${MKLROOT}/lib/intel64/libmkl_core.a -Wl,--end-group -lgomp -lpthread -lm -ldl
LINK    =

# FC      = ifort
# #FCFLAGS = -check all -warn all -std -gen_interfaces -fpe0 -ftrapuv -traceback -qopenmp -parallel
# FCFLAGS = -O3 -ipo -no-prec-div -fp-model fast=2 -xHost -parallel -qopenmp
# INCLUDE = 
# LIB     = 
# LINK    = -mkl=parallel

#######################################################

LD      = $(FC)
LDFLAGS = $(FCFLAGS)

#suffixe
.SUFFIXES: .f90

all:$(PROGS)

$(PROGS):$(OBJ)
	$(LD) $(LDFLAGS) -o $@ $(OBJ) $(LIB) $(LINK)

.f90.o: 
	$(FC) $(FCFLAGS) -c $< $(INCLUDE)

clean: 
	rm -f $(OBJ) $(OBJ:.o=.mod) ./$(PROGS)
