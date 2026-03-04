# Honeycomb Lattice Example

This example demonstrates how to run **QS³ ED2** for a **two-dimensional honeycomb lattice** (periodic boundary conditions).
The example is located in

```
examples/honeycomb/
```

and contains all input and output files required to reproduce the calculation.

The ground state is computed using the **Lanczos method**, and the program evaluates

- ground-state energy
- local magnetization
- two-point spin correlation functions

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

This dataset uses a **uniform spin-1/2** model.

---

## Couplings used in this dataset

### Magnetic field

`list_hvec.dat` provides the on-site field \(\mathbf{h}_i\).
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

In the `honeycomb` dataset, the file contains **nearest-neighbor bonds** on a periodic honeycomb lattice:

- `NOS = 200` sites
- `NO_TWO = 300` bonds (as echoed in `output.dat`)
- `wc -l list_xyz_dm_gamma.dat` is also 300, consistent with `NO_TWO`.

This is also consistent with the honeycomb coordination number \(z=3\):

$$
N_{\mathrm{bonds}} = \frac{zN}{2} = \frac{3\times 200}{2} = 300.
$$

---

# Input files

## `input_param.dat`

Main runtime parameters (system size, basis truncation, algorithm switches).

For this example:

- `NOS = 200`: number of sites
- `L1 = 10`, `L2 = 10`: lattice parameters (2D)
- `SPIN = 0.5`: uniform spin-1/2
- `NODmin = 0`, `NODmax = 3`: restrict the calculation to a near-fully-polarized sector
- uniform coupling constants (`HX/HY/HZ`, `JX/JY/JZ`, `DX/DY/DZ`, `GX/GY/GZ`)

The program prints an expanded parameter block in `output.dat` (see below).

## Translation mappings (`list_p1.dat`, `list_p2.dat`)

This example uses translational symmetry reduction in two lattice directions.

From `output.dat`:

```
FILE_S1 = list_p1.dat
FILE_S2 = list_p2.dat
```

These mappings define the permutation \(T(i)\) applied to site indices \(i=1,\dots,NOS\).

### x-direction translation (`list_p1.dat`)

`list_p1.dat` starts as

```
3
4
5
...
20
1
2
23
24
...
```

This means

- \(T_x(1)=3\), \(T_x(2)=4\), ..., \(T_x(18)=20\), and \((T_x(19),T_x(20))=(1,2)\).

So, within the first block of 20 sites (corresponding to one "row" in the chosen site ordering), the mapping is a **shift by +2 sites with wrap-around**:

- \(T_x(i)=i+2\) for \(i=1,\dots,18\),
- \(T_x(19)=1\), \(T_x(20)=2\).

The same pattern repeats for the next block (sites 21–40), then 41–60, etc.
This is consistent with the usual honeycomb convention that one unit-cell translation along \(x\) shifts indices by two
(because each unit cell contains two sublattice sites).

### y-direction translation (`list_p2.dat`)

`list_p2.dat` starts as

```
21
22
23
...
40
41
42
...
```

which corresponds to a shift by **+20 sites**:

- \(T_y(i)=i+20\) for \(i=1,\dots,180\),
- \(T_y(i)=i-180\) for \(i=181,\dots,200\).

Thus, in this indexing convention, a translation by one step along the second lattice direction moves to the next block of 20 sites.

## `list_hvec.dat`

On-site magnetic fields \(\mathbf{h}_i\) (uniform in this dataset).

## `list_ij_cf.dat`

Pairs \((i,j)\) for which two-point correlators are evaluated (when enabled via `CAL_CF = 1`).
From `output.dat`:

- `NO_TWO_CF = 9`
- `FILE_TWO_CF = ./list_ij_cf.dat`

## Other list files

`output.dat` also echoes

- `FILE_NODMAX = list_NODmax.dat`
- `FILE_SPIN   = list_spin.dat`

For a uniform spin-1/2 model these lists are redundant, but they may be included for compatibility with a common I/O path
used across different examples (e.g., mixed-spin cases).

---

# Running the Example

Inside the example directory run

```
../../source/QS3ED2 < input.dat
```

When running the provided scripts, the terminal output is redirected to

```
output.dat
```

---

# Reading `output.dat`

The file `output.dat` contains the main diagnostic information for the run.

## Lattice size

From the input echo:

```
NOS = 200
L1  = 10
L2  = 10
L3 = L4 = L5 = L6 = 1
```

This corresponds to a **two-dimensional honeycomb dataset with 200 sites** under periodic boundary conditions.

## Bond count

`output.dat` reports

```
NO_TWO  = 300
FILE_XYZ_DM_GAMMA = list_xyz_dm_gamma.dat
```

so the dataset uses 300 two-body (bond) terms.

## Hilbert-space size

`output.dat` reports

```
THS   = 1333501
THS(k)= 13339
```

- `THS` is the number of states **before symmetry reduction**
- `THS(k)` is the number of **representative states** after translational symmetry reduction

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
itr, ene, conv:     5    3.753668104583582E+00    1.0E+00
itr, ene, conv:    10   -1.071837964394154E-01    3.6E+01
...
itr, ene, conv:    90   -1.047035063952752E+00    6.4E-15
```

The run finished at

```
total lanczos step: 90
E_0 = -1.047035063952752E+00
```

---

## Eigenvector quality

The accuracy of the Lanczos eigenvector is checked using

```
<GS| H |GS>  = -1.047035063952752E+00
|1 - (<GS|H|GS>)^2/<GS|H^2|GS>| = 2.245665906196738E-15
```

The final quantity should be close to machine precision for a well-converged ground state.

---

# Observables and output files

After the Lanczos run, `output.dat` indicates which post-processing steps were executed:

- local magnetizations → `local_mag.dat`
- two-point correlators → `two_body_cf_z+-.dat`, `two_body_cf_xyz.dat`

(When enabled, the file names and meanings follow the same conventions as in the standard examples such as `chain`.)

---

# Summary

This example shows how to run QS³-ED2 on a **2D honeycomb dataset (200 sites)** with:

- translational symmetry mappings (`list_p1.dat`, `list_p2.dat`) for 2D translational symmetry reduction,
- uniform on-site field (`list_hvec.dat`),
- nearest-neighbor couplings (`list_xyz_dm_gamma.dat`, `NO_TWO = 300`),
- two-point correlators evaluated for `NO_TWO_CF = 9` pairs (`list_ij_cf.dat`),
- Lanczos ground state energy \(E_0 = -1.047035063952752\).

All other parts of the workflow (run method, Lanczos solver, and observable outputs) match the standard examples.
