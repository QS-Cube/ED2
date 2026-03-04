# Triangular Lattice Example

This example demonstrates how to run **QS³ ED2** for a **two‑dimensional triangular lattice** (periodic boundary conditions).
The example is located in

```
examples/triangular/
```

and contains all input and output files required to reproduce the calculation.

The ground state is computed using the **Lanczos method**, and the program evaluates

- ground‑state energy
- local magnetization
- two‑point spin correlation functions

---

# Model

## Hamiltonian

The Hamiltonian implemented in this example is

$$
H =
\sum_{\langle i,j\rangle}
\left(
J_x S_i^x S_j^x +
J_y S_i^y S_j^y +
J_z S_i^z S_j^z
+ \mathbf{D}\cdot(\mathbf{S}_i \times \mathbf{S}_j)
+ H_\Gamma(i,j)
\right)
+
\sum_i \mathbf{h}\cdot\mathbf{S}_i,
$$

where the symmetric anisotropic interaction is

$$
H_\Gamma(i,j)=
\Gamma_x\left(S_i^y S_j^z + S_i^z S_j^y\right)
+\Gamma_y\left(S_i^z S_j^x + S_i^x S_j^z\right)
+\Gamma_z\left(S_i^x S_j^y + S_i^y S_j^x\right).
$$

This dataset uses a **uniform spin‑1/2** model.

---

## Couplings used in this dataset

### Magnetic field

`list_hvec.dat` provides the on‑site field \(\mathbf{h}_i\).
Each line stores

$$
(i,\,h_x,\,h_y,\,h_z).
$$

In this dataset it is uniform across all sites:

$$
\mathbf{h} = (-0.1,\,-0.1,\,-0.3).
$$

### Bond interactions

`list_xyz_dm_gamma.dat` specifies the bond list and the couplings for each bond.

Each bond line stores

$$
(i,\,j,\,J_x,\,J_y,\,J_z,\,D_x,\,D_y,\,D_z,\,\Gamma_x,\,\Gamma_y,\,\Gamma_z).
$$

For reference, the first line corresponds to

- \(J_x=1,\,J_y=0.8,\,J_z=0.7\),
- \(\mathbf{D}=(0.2,0.1,5)\),
- \(\boldsymbol\Gamma=(0.1,0.3,-0.2)\).

In the `triangular` dataset, the file contains **nearest‑neighbor bonds of a 10×10 periodic triangular lattice**.

- Each site has **6** nearest neighbors (coordination number \(z=6\)).
- Counting each undirected bond once, the total number of bonds is

$$
N_{\mathrm{bonds}} = \frac{zN}{2} = \frac{6\times 100}{2} = 300.
$$

which matches the input echo `NO_TWO = 300`.

(Equivalently, you can view the bond list as three directional bond sets—two axial directions plus one diagonal—together with periodic boundary conditions.)

---

# Input files

## `input_param.dat`

Main runtime parameters (system size, basis truncation, algorithm switches).

For this example:

- `NOS = 100`: number of sites
- `LX = 10`, `LY = 10`: lattice size (10×10)
- `SPIN = 0.5`: uniform spin‑1/2
- `NODmin = 0`, `NODmax = 3`: restrict the calculation to a near‑fully‑polarized sector (see notes in `chain.md`)
- uniform coupling constants (`HX/HY/HZ`, `JX/JY/JZ`, `DX/DY/DZ`, `GX/GY/GZ`)

The program prints an expanded parameter block in `output.dat` (see below).

## Translation mappings (`list_p1.dat`, `list_p2.dat`)

This example uses translational symmetry reduction in both lattice directions.

- `list_p1.dat`: translation by **+1 in x** (within each row)
- `list_p2.dat`: translation by **+1 in y** (to the next row)

These mappings define the permutation \(T(i)\) applied to site indices \(i=1,\dots,NOS\).

## `list_hvec.dat`

On‑site magnetic fields \(\mathbf{h}_i\) (uniform in this dataset).

## `list_ij_cf.dat`

Pairs \((i,j)\) for which two‑point correlators are evaluated (when enabled via `CAL_CF = 1`).
This dataset contains 9 pairs:

```
(1,2), (1,3), ..., (1,10).
```

## Other list files

Depending on your build/options, `output.dat` may also echo file names such as `FILE_SPIN` and `FILE_NODMAX`.
For a uniform spin‑1/2 model these lists are redundant, but they may be included for compatibility with a common I/O path
used across different examples (e.g., mixed‑spin cases).

---

# Running the Example

Inside the example directory run

```
../../source/QS3ED2 < input.dat
```

The program prints a detailed execution log to the terminal.
When running the provided scripts, this output is redirected to

```
output.dat
```

---

# Reading `output.dat`

The file `output.dat` contains the main diagnostic information for the run.

## Lattice size

From the input echo:

```
NOS = 100
L1  = 10
L2  = 10
L3 = L4 = L5 = L6 = 1
```

This corresponds to a **two‑dimensional 10×10 triangular lattice** (100 sites total).

## Translation operators (`FILE_S1`, `FILE_S2`)

The translational symmetry is defined by

```
FILE_S1 = list_p1.dat
FILE_S2 = list_p2.dat
```

### x‑direction translation (`list_p1.dat`)

`list_p1.dat` starts as

```
2
3
4
...
10
1
12
13
...
20
11
...
```

This means that within each block of 10 sites (a row), the mapping is

- \(T_x(i)=i+1\) for \(i=1,\dots,9\), and \(T_x(10)=1\),
- \(T_x(i)=i+1\) for \(i=11,\dots,19\), and \(T_x(20)=11\),

and so on for all 10 rows.

### y‑direction translation (`list_p2.dat`)

`list_p2.dat` starts as

```
11
12
...
100
1
2
...
10
```

which corresponds to a shift by one row:

- \(T_y(i)=i+10\) for \(i=1,\dots,90\),
- \(T_y(i)=i-90\) for \(i=91,\dots,100\).

Together, these two translations generate the 2D lattice translations on a 10×10 torus.

---

## Hilbert‑space size

`output.dat` reports

```
THS   = 166751
THS(k)= 1670
```

- `THS` is the number of states **before symmetry reduction**
- `THS(k)` is the number of **representative states** after translational symmetry reduction

---

## Lanczos solver

The solver parameters appear as

```
&INPUT_LANCZ
LNC_ENE_CONV = 1.0E-14
MAXITR = 10000
MINITR = 5
ITRINT = 5
/
```

During the calculation the program prints iteration logs such as

```
itr, ene, conv:     5    1.073667247217730E+01    1.0E+00
itr, ene, conv:    10    8.132509850253756E+00    3.2E-01
itr, ene, conv:    15    7.481359872063639E+00    8.7E-02
itr, ene, conv:    20    7.267842183182092E+00    2.9E-02
itr, ene, conv:    25    7.222848631689769E+00    6.2E-03
itr, ene, conv:    30    7.207089109911225E+00    2.2E-03
itr, ene, conv:    35    7.197192954268062E+00    1.4E-03
itr, ene, conv:    40    7.190351733247415E+00    9.5E-04
itr, ene, conv:    45    7.187356000257709E+00    4.2E-04
itr, ene, conv:    50    7.186923742325487E+00    6.0E-05
itr, ene, conv:    55    7.186895352571869E+00    4.0E-06
itr, ene, conv:    60    7.186892648633182E+00    3.8E-07
itr, ene, conv:    65    7.186892050578778E+00    8.3E-08
itr, ene, conv:    70    7.186891965536971E+00    1.2E-08
itr, ene, conv:    75    7.186891959901488E+00    7.8E-10
itr, ene, conv:    80    7.186891959393351E+00    7.1E-11
itr, ene, conv:    85    7.186891959107370E+00    4.0E-11
itr, ene, conv:    90    7.186891958859724E+00    3.4E-11
itr, ene, conv:    95    7.186891958811414E+00    6.7E-12
itr, ene, conv:   100    7.186891958807258E+00    5.8E-13
itr, ene, conv:   105    7.186891958806920E+00    4.7E-14
itr, ene, conv:   110    7.186891958806910E+00    1.5E-15

total lanczos step: 110
E_0 = 7.186891958806910E+00
```

---

## Eigenvector quality

The accuracy of the Lanczos eigenvector is checked using

```
<GS| H |GS>  = 7.186891958806912E+00
|1 - (<GS|H|GS>)^2/<GS|H^2|GS>| = 3.213274727498563E-16
```

The final quantity should be close to machine precision for a well‑converged ground state.

---

# Observables and output files

After the Lanczos run, `output.dat` indicates which post‑processing steps were executed, e.g.

- local magnetizations → `local_mag.dat`
- two‑point correlators → `two_body_cf_z+-.dat`, `two_body_cf_xyz.dat`

(When enabled, the file names and meanings follow the same conventions as in `chain.md`.)

---

# Summary

This example shows how to run QS³‑ED2 on a **10×10 triangular lattice (spin‑1/2)** with:

- two translation mappings (`list_p1.dat`, `list_p2.dat`) for 2D translational symmetry reduction,
- uniform on‑site field (`list_hvec.dat`),
- nearest‑neighbor couplings on a triangular lattice (`list_xyz_dm_gamma.dat`),
- two‑point correlators evaluated for selected pairs (`list_ij_cf.dat`).

All other parts of the workflow (run method, Lanczos solver, and observable outputs) match the standard `chain` example.
