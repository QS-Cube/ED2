# Kagome Lattice Example

This example demonstrates how to run **QS³ ED2** for a **two‑dimensional kagome lattice** (periodic boundary conditions).
The example is located in

```
examples/kagome/
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

In the `kagome` dataset, the file contains **nearest‑neighbor bonds of a 6×6 periodic kagome lattice** with **108 sites**:

- \(L_1=L_2=6\) unit cells,
- kagome has **3 sites per unit cell**, so \(N=3L_1L_2 = 3\times 6\times 6 = 108\).

The input echo reports `NO_TWO = 216`, and the bond list has 216 lines, i.e. 216 undirected bonds.

A useful consistency check is the coordination number of the kagome lattice, \(z=4\).
Counting each undirected bond once,

$$
N_{\mathrm{bonds}} = \frac{zN}{2} = \frac{4\times 108}{2} = 216,
$$

which matches `NO_TWO` and `wc -l list_xyz_dm_gamma.dat`.

---

# Input files

## `input_param.dat`

Main runtime parameters (system size, basis truncation, algorithm switches).

For this example:

- `NOS = 108`: number of sites
- `L1 = 6`, `L2 = 6`: lattice size in unit cells (6×6)
- `SPIN = 0.5`: uniform spin‑1/2
- `NODmin = 0`, `NODmax = 3`: restrict the calculation to a near‑fully‑polarized sector (see notes in `chain.md`)
- uniform coupling constants (`HX/HY/HZ`, `JX/JY/JZ`, `DX/DY/DZ`, `GX/GY/GZ`)

The program prints an expanded parameter block in `output.dat` (see below).

## Translation mappings (`list_p1.dat`, `list_p2.dat`, ...)

This example uses translational symmetry reduction on the 2D torus.

- `list_p1.dat`: translation by one **unit cell in x**
- `list_p2.dat`: translation by one **unit cell in y**

(Additional mapping files `list_p3.dat`–`list_p6.dat` are listed in `output.dat`. In typical 2D examples, only two independent translations are needed; the remaining mappings are often set to identity or used for optional extra symmetries depending on the build and example setup.)

These mappings define the permutation \(T(i)\) applied to site indices \(i=1,\dots,NOS\).

## `list_ij_cf.dat`

Pairs \((i,j)\) for which two‑point correlators are evaluated (when enabled via `CAL_CF = 1`).
This dataset contains 9 pairs (as echoed by `NO_TWO_CF = 9`).

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
NOS = 108
L1  = 6
L2  = 6
L3 = L4 = L5 = L6 = 1
```

This corresponds to a **two‑dimensional 6×6 kagome lattice** with **3 sites per unit cell** (108 sites total).

## Translation operators (`FILE_S1`, `FILE_S2`)

The translational symmetry is defined by

```
FILE_S1 = list_p1.dat
FILE_S2 = list_p2.dat
```

### x‑direction translation (`list_p1.dat`)

`list_p1.dat` starts as

```
4
5
6
...
16
1
2
3
...
```

This is consistent with a shift by **+3** in site index within the flattened ordering.
Interpreting the ordering as unit cells laid out on a 6×6 grid with 3 sublattice sites per unit cell:

- a translation by **one unit cell in x** shifts indices by **+3** within a row,
- with periodic wrapping at the row boundary.

### y‑direction translation (`list_p2.dat`)

`list_p2.dat` starts as

```
19
20
21
...
```

which corresponds to a shift by **+18** in site index.
Since each row contains \(6\) unit cells \(\times\,3\) sites = \(18\) sites, this is consistent with a translation by **one unit cell row in y** (with periodic wrapping).

Together, these two translations generate the 2D lattice translations on a 6×6 torus.

---

## Hilbert‑space size

`output.dat` reports

```
THS   = 210043
THS(k)= 5848
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
itr, ene, conv:     5   -5.575472603407842E-01    1.0E+00
...
itr, ene, conv:    65   -5.909297683810852E+00    5.3E-16
```

and then reports

```
total lanczos step: 65
E_0 = -5.909297683810852E+00
```

---

## Eigenvector quality

The accuracy of the Lanczos eigenvector is checked using

```
<GS| H |GS>  = -5.909297683810852E+00
|1 - (<GS|H|GS>)^2/<GS|H^2|GS>| = 3.037357706737535E-17
```

The final quantity should be close to machine precision for a well‑converged ground state.

---

# Observables and output files

After the Lanczos run, `output.dat` indicates which post‑processing steps were executed:

- local magnetizations → `local_mag.dat`
- two‑point correlators → `two_body_cf_z+-.dat`, `two_body_cf_xyz.dat`

(When enabled, the file names and meanings follow the same conventions as in `chain.md`.)

---

# Summary

This example shows how to run QS³‑ED2 on a **6×6 kagome lattice (spin‑1/2, 108 sites)** with:

- translational symmetry reduction using two mappings (`list_p1.dat`, `list_p2.dat`),
- uniform on‑site field (`list_hvec.dat`),
- nearest‑neighbor couplings on a kagome lattice (`list_xyz_dm_gamma.dat`, 216 bonds),
- two‑point correlators evaluated for selected pairs (`list_ij_cf.dat`).

All other parts of the workflow (run method, Lanczos solver, and observable outputs) match the standard `chain` example.
