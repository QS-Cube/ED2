#!/bin/sh

# --- ED2 executable resolution (do not rely on PATH) -----------------
# Prefer ED2_EXE provided by caller (tests/users).
if [ -n "${ED2_EXE:-}" ]; then
  QS3ED2="${ED2_EXE}"
else
  # Fallback: assume repo layout <root>/script_j1j2_chain/run.sh
  QS3ED2="$(cd "$(dirname "$0")/../source" 2>/dev/null && pwd)/QS3ED2"
fi

if [ ! -x "$QS3ED2" ]; then
  echo "ERROR: ED2 executable not found/executable: $QS3ED2" >&2
  echo "Hint: build first (make) and/or set ED2_EXE=/path/to/QS3ED2" >&2
  exit 1
fi
# ---------------------------------------------------------------------

##################################################
#export OMP_NUM_THREADS=4
##################################################
    wkdir="examples/j1j2_chain"
      NOS=100    # Number of Sites
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
       JX2=0.5d0  # NNN SX SX interaction
       JY2=0.4d0  # NNN SY SY interaction
       JZ2=0.35d0 # NNN SZ SZ interaction
       DX2=0.1d0  # X component of NNN DM interaction
       DY2=0.05d0 # Y component of NNN DM interaction
       DZ2=2.5d0  # Z component of NNN DM interaction
       GX2=0.05d0 # X component of NNN Gamma interaction
       GY2=0.15d0 # Y component of NNN Gamma interaction
       GZ2=-0.1d0 # Z component of NNN Gamma interaction
       HX=-0.1d0 # Magnetic field along X direction
       HY=-0.1d0 # Magnetic field along Y direction
       HZ=-0.3d0 # Magnetic field along Z direction
       M1=0      # Wavenum. for trans. symm.
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

NO_one=$(( NOS ))
NO_two=$(( 2 * NOS ))

NOK=$(( NOE * 2 ))
NOM=$(( NOK + 20 ))

sed -e "s|NWKDIR|$hdir/$wkdir|g" input_param.dat | \
sed -e "s/NNOS/$NOS/g" | \
sed -e "s/NNODmin/$NODmin/g" | \
sed -e "s/NNODmax/$NODmax/g" | \
sed -e "s/NSPIN/$SPIN/g" | \
sed -e "s/NHX/$HX/g" | \
sed -e "s/NHY/$HY/g" | \
sed -e "s/NHZ/$HZ/g" | \
sed -e "s/NJX2/$JX2/g" | \
sed -e "s/NJY2/$JY2/g" | \
sed -e "s/NJZ2/$JZ2/g" | \
sed -e "s/NDX2/$DX2/g" | \
sed -e "s/NDY2/$DY2/g" | \
sed -e "s/NDZ2/$DZ2/g" | \
sed -e "s/NGX2/$GX2/g" | \
sed -e "s/NGY2/$GY2/g" | \
sed -e "s/NGZ2/$GZ2/g" | \
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
sed -e "s/NL1/$NOS/g" | \
sed -e "s/NL2/1/g" | \
sed -e "s/NL3/1/g" | \
sed -e "s/NL4/1/g" | \
sed -e "s/NL5/1/g" | \
sed -e "s/NL6/1/g" | \
sed -e "s/NM1/$M1/g" | \
sed -e "s/NM2/0/g" | \
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

#cd ../source
#make 1> /dev/null 2>&1
#
echo "cd $hdir/$wkdir"
cd $hdir/$wkdir
#rm eigenvalues.dat 1> /dev/null 2>&1
rm -f eigenvalues.dat

#echo "$hdir/QS3ED2.exe < input.dat > output.dat"
#$hdir/QS3ED2.exe < input.dat > output.dat
echo "$QS3ED2 < input.dat > output.dat"
"$QS3ED2" < input.dat > output.dat


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
