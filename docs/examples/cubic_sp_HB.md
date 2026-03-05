
# Cubic (spin‑1/2 Heisenberg) Example

This example demonstrates how to run **QS³‑ED2** for a **three‑dimensional simple‑cubic lattice** (periodic boundary conditions) in a **spin‑1/2 Heisenberg** model.

Directory:

```
examples/cubic_sp_HB/
```

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
\sum_i \mathbf{h}\cdot\mathbf{S}_i.
$$

where

$$
H_\Gamma(i,j)=
\Gamma_x(S_i^y S_j^z + S_i^z S_j^y)
+\Gamma_y(S_i^z S_j^x + S_i^x S_j^z)
+\Gamma_z(S_i^x S_j^y + S_i^y S_j^x).
$$

---

# Couplings

From `input_param.dat`:

- magnetic field  

$$\mathbf{h}=(0,0,0)$$

- exchange couplings  

$$
J_x = J_y = J_z = 1
$$

- DM interaction  

$$
\mathbf{D}=(0,0,0)
$$

- symmetric anisotropy  

$$
\Gamma_x = \Gamma_y = \Gamma_z = 0
$$

Thus this example corresponds to an **isotropic Heisenberg model**.

---

# Lattice

System size:

```
LX = 10
LY = 10
LZ = 10
NOS = 1000
```

This corresponds to a

$$
10 \times 10 \times 10
$$

periodic simple‑cubic lattice.

Coordination number:

$$
z = 6
$$

Total bonds:

$$
N_{bonds} = \frac{zN}{2} = \frac{6 \times 1000}{2} = 3000
$$

which matches

```
NO_TWO = 3000
```

reported in `output.dat`.

---

# Bond list

File:

```
list_xyz_dm_gamma.dat
```

Format of each line:

```
i  j  Jx  Jy  Jz  Dx  Dy  Dz  Gx  Gy  Gz
```

Example:

```
1 2   1 1 1   0 0 0   0 0 0
```

Number of bonds:

```
wc -l list_xyz_dm_gamma.dat
→ 3000
```

---

# Symmetry operations

The following permutation mappings are used.

## Translations

```
list_p1.dat   (x translation)
list_p2.dat   (y translation)
list_p3.dat   (z translation)
```

Examples:

```
1 → 2 → 3 → ... → 10 → 1
```

for x‑direction periodic translation.

```
1 → 11
```

for y translation.

```
1 → 101
```

for z translation.

These generate the full translation group of the 3D torus.

---

## Reflections / inversions

Additional symmetry operations:

```
list_p4.dat
list_p5.dat
list_p6.dat
```

Examples:

```
1 ↔ 10
2 ↔ 9
```

x‑axis reflection.

```
1 → 91
```

y‑axis inversion.

```
1 → 901
```

z‑axis inversion.

These discrete symmetries further reduce the Hilbert space.

---

# Local Hilbert space

Defined by

```
list_NODmax.dat
list_spin.dat
```

Example entries:

```
list_NODmax.dat
1
1
1
...
```

```
list_spin.dat
0.5
0.5
0.5
...
```

Therefore

- each site has **two local states**
- spin quantum number

$$
S = \frac{1}{2}
$$

for all sites.

---

# Lanczos solver

Parameters printed in `output.dat`:

```
LNC_ENE_CONV = 1.0E-14
MAXITR = 10000
MINITR = 5
ITRINT = 5
```

Lanczos iterations:

```
total lanczos step = 135
```

Ground‑state energy:

```
E_0 = 7.367224213680654E+02
```

---

# Eigenvector quality

Verification:

```
<GS|H|GS> = 7.367224213680655E+02
|1-(<GS|H|GS>)^2/<GS|H^2|GS>| = 4.93E-17
```

The residual is close to machine precision, indicating a well‑converged ground state.

---

# Correlation functions

Pairs are specified in

```
list_ij_cf.dat
```

Example:

```
1 2
1 3
1 4
...
1 10
```

Total pairs:

```
NO_TWO_CF = 9
```

Output files:

```
two_body_cf_z+-.dat
two_body_cf_xyz.dat
```

---

# Summary

This example demonstrates a QS³‑ED2 calculation for

- lattice: **10×10×10 cubic**
- sites: **1000**
- model: **spin‑1/2 Heisenberg**
- bonds: **3000**
- symmetry: **translations + reflections**
- solver: **Lanczos**
- ground‑state energy

$$
E_0 = 7.367224213680654 \times 10^2
$$
