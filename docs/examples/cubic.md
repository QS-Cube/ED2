# Cubic Lattice Example

This example demonstrates how to run **QS³ ED2** for a **three‑dimensional simple cubic lattice** (periodic boundary conditions).
The example is located in

```
examples/cubic/
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

In the `cubic` dataset, the file contains **nearest‑neighbor bonds of a 6×6×6 periodic simple‑cubic lattice**.

- Each site has **6** nearest neighbors (coordination number \(z=6\)).
- Counting each undirected bond once, the total number of bonds is

$$
N_{\mathrm{bonds}} = \frac{zN}{2} = \frac{6\times 216}{2} = 648,
$$

which matches the input echo `NO_TWO = 648`.

---

# Input files

## `input_param.dat`

Main runtime parameters (system size, basis truncation, algorithm switches).

For this example:

- `NOS = 216`: number of sites
- `LX = 6`, `LY = 6`, `LZ = 6`: lattice size (6×6×6)
- `SPIN = 0.5`: uniform spin‑1/2
- `NODmin = 0`, `NODmax = 3`: restrict the calculation to a near‑fully‑polarized sector (see notes in `chain.md`)
- uniform coupling constants (`HX/HY/HZ`, `JX/JY/JZ`, `DX/DY/DZ`, `GX/GY/GZ`)

The program prints an expanded parameter block in `output.dat` (see below).

## Translation mappings (`list_p1.dat`, `list_p2.dat`, `list_p3.dat`)

This example uses translational symmetry reduction in **three** lattice directions.

- `list_p1.dat`: translation by **+1 in x**
- `list_p2.dat`: translation by **+1 in y**
- `list_p3.dat`: translation by **+1 in z**

These mappings define the permutation \(T(i)\) applied to site indices \(i=1,\dots,NOS\).

## `list_hvec.dat`

On‑site magnetic fields \(\mathbf{h}_i\) (uniform in this dataset).

## `list_ij_cf.dat`

Pairs \((i,j)\) for which two‑point correlators are evaluated (when enabled via `CAL_CF = 1`).
This dataset contains 9 pairs (echoed as `NO_TWO_CF = 9`).

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
NOS = 216
L1  = 6
L2  = 6
L3  = 6
L4 = L5 = L6 = 1
```

This corresponds to a **three‑dimensional 6×6×6 simple‑cubic lattice** (216 sites total).

## Translation operators (`FILE_S1`, `FILE_S2`, `FILE_S3`)

The translational symmetry is defined by

```
FILE_S1 = list_p1.dat
FILE_S2 = list_p2.dat
FILE_S3 = list_p3.dat
```

Assuming the standard site ordering where **x changes fastest**, then y, then z:

### x‑direction translation (`list_p1.dat`)

`list_p1.dat` begins as

```
2
3
4
5
6
1
8
9
...
12
7
...
```

This indicates a shift by one along x within each contiguous block of 6 sites, with periodic wrap‑around
(e.g., \(1\to2\to3\to4\to5\to6\to1\)).

### y‑direction translation (`list_p2.dat`)

`list_p2.dat` begins as

```
7
8
...
12
13
...
18
...
31
32
...
36
1
2
...
6
43
44
...
```

This corresponds to a shift by one along y (i.e., by \(+6\) in the site index inside each z‑slice),
with periodic wrap‑around after each 6×6 layer.

### z‑direction translation (`list_p3.dat`)

`list_p3.dat` begins as

```
37
38
...
72
73
74
...
```

This corresponds to a shift by one along z (i.e., by \(+36 = L1\times L2\) in the site index),
with periodic wrap‑around after the last layer.

Together, these three translations generate the 3D lattice translations on a 6×6×6 torus.

---

## Hilbert‑space size

`output.dat` reports

```
THS   = 1679797
THS(k)= 7790
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
itr, ene, conv:     5    4.462267627161076E+01    1.0E+00
...
itr, ene, conv:    40    3.291959953219395E+01    3.8E-16
```

and finally

```
total lanczos step: 40
E_0 = 3.291959953219395E+01
```

---

## Eigenvector quality

The accuracy of the Lanczos eigenvector is checked using

```
<GS| H |GS>  = 3.291959953219396E+01
|1 - (<GS|H|GS>)^2/<GS|H^2|GS>| = 2.263595547998526E-16
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

This example shows how to run QS³‑ED2 on a **6×6×6 simple‑cubic lattice (spin‑1/2)** with:

- three translation mappings (`list_p1.dat`, `list_p2.dat`, `list_p3.dat`) for 3D translational symmetry reduction,
- uniform on‑site field (`list_hvec.dat`),
- nearest‑neighbor couplings on a simple‑cubic lattice (`list_xyz_dm_gamma.dat`, `NO_TWO = 648`),
- two‑point correlators evaluated for selected pairs (`list_ij_cf.dat`).

All other parts of the workflow (run method, Lanczos solver, and observable outputs) match the standard `chain` example.
