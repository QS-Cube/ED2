#!/bin/sh
##################################################
#export OMP_NUM_THREADS=4
##################################################
    wkdir="examples/honeycomb"
       L1=10     # Number of Sites along a1 direction
       L2=10     # Number of Sites along a2 direction
   NODmax=3      # Upper limit value for the number of down spins
   NODmin=0      # Lower limit value for the number of down spins
     SPIN=0.5d0  # Spin
       JX=1.0d0  # NN SX SX interaction
       JY=0.8d0  # NN SY SY interaction
       JZ=0.7d0  # NN SZ SZ interaction
       DX=0.2d0  # X component of NN DM interaction
       DY=0.1d0  # Y component of NN DM interaction
       DZ=5.0d0  # Z component of NN DM interaction
       GX=0.1d0  # X component of NN Gamma interaction
       GY=0.3d0  # Y component of NN Gamma interaction
       GZ=-0.2d0 # Z component of NN Gamma interaction
       HX=-0.1d0 # Magnetic field along X direction
       HY=-0.1d0 # Magnetic field along Y direction
       HZ=-0.3d0 # Magnetic field along Z direction
       M1=0      # Wavenum. for trans. symm. along a1 direction.
       M2=0      # Wavenum. for trans. symm. along a2 direction.
      ALG=1      # 1:Lanczos, 2:TR Lanczos, 3: Full diag.
      NOE=10     # Number of eigenvalues : Active only when ALG=2.
NO_two_cf=9      # Number of expectation values of <S_i S_j>
                 # Your set of (i j) is stored in "list_ij_cf.dat".
   wk_dim=-1     # Number of columns in the work array
                 # if wk_dim < 0 then wk_dim = total Hilbert space specified by quantum #s.
                 # Required mem.: (8+16)*(wk_dim)*(MNTE+1) [Byte]
     MNTE=-1     # Maximum number of transitional elements for a representative state
                 # if MNTE < 0 then MNTE = 2*NO_one + 8*NO_two
##################################################

cd ../
hdir=`pwd`
cd - 1> /dev/null 2>&1

mkdir -p $hdir/$wkdir 1> /dev/null 2>&1

NOS=$(( 2 * L1 * L2 ))

NO_one=$(( NOS ))
NO_two=$(( 3*L1*L2 ))

NOK=$(( NOE * 2 ))
NOM=$(( NOK + 20 ))

sed -e "s|NWKDIR|$hdir/$wkdir|g" input_param.dat | \
sed -e "s/NNOS/$NOS/g" | \
sed -e "s/NL1/$L1/g" | \
sed -e "s/NL2/$L2/g" | \
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
sed -e "s/NL1/$L1/g" | \
sed -e "s/NL2/$L2/g" | \
sed -e "s/NL3/1/g" | \
sed -e "s/NL4/1/g" | \
sed -e "s/NL5/1/g" | \
sed -e "s/NL6/1/g" | \
sed -e "s/NM1/$M1/g" | \
sed -e "s/NM2/$M2/g" | \
sed -e "s/NM3/0/g" | \
sed -e "s/NM4/0/g" | \
sed -e "s/NM5/0/g" | \
sed -e "s/NM6/0/g" | \
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
