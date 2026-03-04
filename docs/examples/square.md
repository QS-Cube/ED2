# Square‑Lattice Example

This example demonstrates how to run **QS³ ED2** for a **two‑dimensional square lattice** (periodic boundary conditions).
The example is located in

```
examples/square/
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

In the `square` dataset, the file contains **two sets of nearest‑neighbor bonds**:

- bonds along the **x direction** (within each row, with periodic wrap‑around),
- bonds along the **y direction** (between rows, with periodic wrap‑around).

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

This corresponds to a **two‑dimensional 10×10 square lattice** (100 sites total).

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
itr, ene, conv:     5   -6.109622213259696E+00    1.0E+00
itr, ene, conv:    10   -9.515210222694508E+00    3.6E-01
itr, ene, conv:    15   -9.991802727569164E+00    4.8E-02
itr, ene, conv:    20   -1.033373611967474E+01    3.3E-02
itr, ene, conv:    25   -1.042782461125804E+01    9.0E-03
itr, ene, conv:    30   -1.043043347954608E+01    2.5E-04
itr, ene, conv:    35   -1.043049405686575E+01    5.8E-06
itr, ene, conv:    40   -1.043049542086834E+01    1.3E-07
itr, ene, conv:    45   -1.043049543845607E+01    1.7E-09
itr, ene, conv:    50   -1.043049543852458E+01    6.6E-12
itr, ene, conv:    55   -1.043049543852545E+01    8.3E-14
itr, ene, conv:    60   -1.043049543852545E+01    6.2E-16
```

The solver finishes with

```
total lanczos step: 60
E_0 = -1.043049543852545E+01
```

---

## Eigenvector quality

The accuracy of the Lanczos eigenvector is checked using

```
<GS| H |GS>  = -1.043049543852545E+01
|1 - (<GS|H|GS>)^2/<GS|H^2|GS>| = 6.619684386711490E-17
```

The final quantity should be close to machine precision for a well‑converged ground state.

---

# Observables and output files

After the Lanczos run, `output.dat` indicates which post‑processing steps were executed, e.g.

- local magnetizations → `output/local_mag.dat`
- two‑point correlators → `output/two_body_cf_z+-.dat`, `output/two_body_cf_xyz.dat`

(When enabled, the file names and meanings follow the same conventions as in `chain.md`.)

---

# Summary

This example shows how to run QS³‑ED2 on a **10×10 square lattice (spin‑1/2)** with:

- two translation mappings (`list_p1.dat`, `list_p2.dat`) for 2D translational symmetry reduction,
- uniform on‑site field (`list_hvec.dat`),
- nearest‑neighbor couplings in both x and y directions (`list_xyz_dm_gamma.dat`),
- two‑point correlators evaluated for selected pairs (`list_ij_cf.dat`).

All other parts of the workflow (run method, Lanczos solver, and observable outputs) match the standard `chain` example.
