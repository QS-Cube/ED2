#!/bin/sh
##################################################
#export OMP_NUM_THREADS=4
##################################################
    wkdir="examples/cubic_sp_HB"
       LX=10      # Number of Sites along x direction
       LY=10      # Number of Sites along y direction
       LZ=10      # Number of Sites along z direction
   NODmax=3      # Upper limit value for the number of down spins
   NODmin=3      # Lower limit value for the number of down spins
     SPIN=0.5d0  # Spin
       JX=1.0d0  # NN SX SX interaction
       JY=1.0d0  # NN SY SY interaction
       JZ=1.0d0  # NN SZ SZ interaction
       DX=0.0d0  # X component of NN DM interaction
       DY=0.0d0  # Y component of NN DM interaction
       DZ=0.0d0  # Z component of NN DM interaction
       GX=0.0d0  # X component of NN Gamma interaction
       GY=0.0d0  # Y component of NN Gamma interaction
       GZ=0.0d0  # Z component of NN Gamma interaction
       HX=0.0d0  # Magnetic field along X direction
       HY=0.0d0  # Magnetic field along Y direction
       HZ=0.0d0  # Magnetic field along Z direction
       M1=0      # Wavenum. for trans. symm. along x direction.
       M2=0      # Wavenum. for trans. symm. along y direction.
       M3=0      # Wavenum. for trans. symm. along z direction.
       M4=0      # Wavenum. for bond-inv. symm. w.r.t. YZ plane
       M5=0      # Wavenum. for bond-inv. symm. w.r.t. ZX plane
       M6=0      # Wavenum. for bond-inv. symm. w.r.r. XY plane
      ALG=1      # 1:Lanczos, 2:TR Lanczos, 3: Full diag.
      NOE=10     # Number of eigenvalues : Active only when ALG=2.
NO_two_cf=9      # Number of expectation values of <S_i S_j>
                 # Your set of (i j) is stored in "list_ij_cf.dat".
   wk_dim=-1     # Number of columns in the work array
                 # if wk_dim < 0 then wk_dim = total Hilbert space specified by quantum #s.
                 # Required mem.: (8+16)*(wk_dim)*(MNTE+1) [Byte]
     MNTE=19     # Maximum number of transitional elements for a representative state
                 # if MNTE < 0 then MNTE = 2*NO_one + 8*NO_two
##################################################

cd ../
hdir=`pwd`
cd - 1> /dev/null 2>&1

mkdir -p $hdir/$wkdir 1> /dev/null 2>&1

NOS=$(( LX * LY * LZ ))

NO_one=$(( NOS ))
NO_two=$(( 3*NOS ))

NOK=$(( NOE * 2 ))
NOM=$(( NOK + 20 ))

sed -e "s|NWKDIR|$hdir/$wkdir|g" input_param.dat | \
sed -e "s/NNOS/$NOS/g" | \
sed -e "s/NLX/$LX/g" | \
sed -e "s/NLY/$LY/g" | \
sed -e "s/NLZ/$LZ/g" | \
sed -e "s/NNODmin/$NODmin/g" | \
sed -e "s/NNODmax/$NODmax/g" | \
sed -e "s/NSPIN/$SPIN/g" | \
sed -e "s/NHX/$HX/g" | \
sed -e "s/NHY/$HY/g" | \
sed -e "s/NHZ/$HZ/g" | \
sed -e "s/NJX/$JX/g" | \
sed -e "s/NJY/$JY/g" | \
sed -e "s/NJZ/$JZ/g" | \
sed -e "s/NDX/$DX/g" | \
sed -e "s/NDY/$DY/g" | \
sed -e "s/NDZ/$DZ/g" | \
sed -e "s/NGX/$GX/g" | \
sed -e "s/NGY/$GY/g" | \
sed -e "s/NGZ/$GZ/g" > fort.30

gfortran mk_input.f90 1> /dev/null 2>&1
./a.out
mv fort.30 $hdir/$wkdir/input_param.dat

sed -e "s/NNOS/$NOS/g" ../input/input.dat | \
sed -e "s/NNODmin/$NODmin/g" | \
sed -e "s/NNODmax/$NODmax/g" | \
sed -e "s/NL1/$LX/g" | \
sed -e "s/NL2/$LY/g" | \
sed -e "s/NL3/$LZ/g" | \
sed -e "s/NL4/2/g" | \
sed -e "s/NL5/2/g" | \
sed -e "s/NL6/2/g" | \
sed -e "s/NM1/$M1/g" | \
sed -e "s/NM2/$M2/g" | \
sed -e "s/NM3/$M3/g" | \
sed -e "s/NM4/$M4/g" | \
sed -e "s/NM5/$M5/g" | \
sed -e "s/NM6/$M6/g" | \
sed -e "s/NNO_two_cf/$NO_two_cf/g" | \
sed -e "s/NNO_one/$NO_one/g" | \
sed -e "s/NNO_two/$NO_two/g" | \
sed -e "s/NALG/$ALG/g" | \
sed -e "s/NNOE/$NOE/g" | \
sed -e "s/NNOK/$NOK/g" | \
sed -e "s/NNOM/$NOM/g" | \
sed -e "s/NMNTE/$MNTE/g" | \
sed -e "s/Nwk_dim/$wk_dim/g" > $hdir/$wkdir/input.dat

cp list_ij_cf.dat $hdir/$wkdir/list_ij_cf.dat

cd ../source
make 1> /dev/null 2>&1
#
echo "cd $hdir/$wkdir"
cd $hdir/$wkdir
rm eigenvalues.dat 1> /dev/null 2>&1

echo "$hdir/QS3ED2.exe < input.dat > output.dat"
$hdir/QS3ED2.exe < input.dat > output.dat

echo "********************"
echo "cat output.dat"
echo "********************"
cat output.dat
echo "********************"
echo "cat eigenvalues.dat"
echo "********************"
cat eigenvalues.dat
echo "********************"
echo "cat local_mag.dat: i, <S^x_i>, <S^y_i>, <S^z_i>"
echo "********************"
cat local_mag.dat
echo "********************"
echo "cat two_body_cf_xyz.dat: i, j, <S^x_i S^x_j>, <S^y_i S^x_j>, <S^z_i S^x_j>, <S^x_i S^y_j>, <S^y_i S^y_j>, <S^z_i S^y_j>, <S^x_i S^z_j>, <S^y_i S^z_j>, <S^z_i S^z_j>"
echo "********************"
cat two_body_cf_xyz.dat
#################################################
