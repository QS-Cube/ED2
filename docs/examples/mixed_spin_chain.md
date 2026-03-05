
# Mixed Spin Chain Example

Directory

```
examples/mixed_spin_chain/
```

This example demonstrates a **mixed-spin one-dimensional quantum spin system**
in which two different spin magnitudes alternate along the chain.

The system contains

$$
N = 100
$$

sites arranged on a periodic chain.

The calculation demonstrates how **QS³-ED2** handles

- heterogeneous local Hilbert spaces
- symmetry reduction
- momentum-sector selection
- Lanczos diagonalization.

---

# 1. Introduction

This example illustrates how QS³-ED2 can treat systems with **site-dependent
spin magnitudes**.

The local spin value at each site is defined in

```
FILE_SPIN = list_spin.dat
```

which allows different spins to be assigned to different lattice sites.

This example therefore demonstrates

- mixed local Hilbert spaces
- translation symmetry in enlarged unit cells
- Lanczos ground-state calculation
- evaluation of observables.

---

# 2. Model Hamiltonian

The Hamiltonian is

$$
H =
\sum_{\langle i,j\rangle}
H_{ij}
+
\sum_i \mathbf{h}\cdot\mathbf{S}_i
$$

with bond interaction

$$
H_{ij} =
\sum_{\alpha=x,y,z}
J_\alpha S_i^\alpha S_j^\alpha
+
\mathbf{D}\cdot(\mathbf{S}_i \times \mathbf{S}_j)
+
H_\Gamma(i,j).
$$

The symmetric anisotropic interaction is

$$
H_\Gamma(i,j)=
\Gamma_x(S_i^y S_j^z + S_i^z S_j^y)
+
\Gamma_y(S_i^z S_j^x + S_i^x S_j^z)
+
\Gamma_z(S_i^x S_j^y + S_i^y S_j^x).
$$

---

# 3. Coupling Parameters

Magnetic field

$$
\mathbf{h}=(-0.1,-0.1,-0.3)
$$

Exchange parameters

$$
(J_x,J_y,J_z)=(1.0,0.8,0.7)
$$

Dzyaloshinskii–Moriya interaction

$$
\mathbf{D}=(0.2,0.1,5.0)
$$

$\Gamma$ interaction

$$
(\Gamma_x,\Gamma_y,\Gamma_z)=(0.1,0.3,-0.2)
$$

---

# 4. Lattice Structure

System parameters from `output.dat`

```
NOS = 100
L1  = 50
```

Although the system contains 100 spins, the translation period is

$$
L_1 = 50
$$

because the **unit cell contains two sites**.

Thus the chain can be viewed as

$$
( A_1,B_1,A_2,B_2,\dots,A_{50},B_{50} )
$$

with periodic boundary conditions.

Nearest-neighbor bonds

```
NO_TWO = 100
```

---

# 5. Symmetry Operations

Translational symmetry is defined by

```
FILE_S1 = list_p1.dat
```

The translation operator shifts the system by **one unit cell**

$$
(A_i,B_i) \rightarrow (A_{i+1},B_{i+1}).
$$

---

# 6. Momentum (Wavevector) Sector

Wavevector parameters

```
L1 = 50
M1 = 0
```

Allowed momenta

$$
k = \frac{2\pi m}{L_1}, \qquad m=0,1,\dots,49.
$$

The calculation selects

```
M1 = 0
```

which corresponds to

$$
k = 0.
$$

Thus the ground state is computed in the **zero-momentum sector**

$$
T|\psi\rangle = |\psi\rangle.
$$

---

# 7. Local Hilbert Space

The local spin values are defined in

```
list_spin.dat
```

This file specifies the spin magnitude at each site, enabling
**mixed-spin systems**.

For example

```
S1 S2 S1 S2 ...
```

could represent an alternating

$$
S_1 = \frac12, \qquad S_2 = 1
$$

chain.

---

# 8. NOD Sector Restriction

QS³-ED2 uses

$$
n_i = S_i - m_i
$$

and defines

$$
\mathrm{NOD} = \sum_i n_i.
$$

Input parameters

```
NODmin = 0
NODmax = 3
```

restrict the allowed basis states.

The maximum allowed value depends on the spin magnitude at each site.

---

# 9. Hilbert-space Dimension

From the program output

```
THS   = 171801
THS(k)= 3438
```

- `THS` : total basis states before symmetry reduction
- `THS(k)` : representative states after symmetry and momentum reduction

---

# 10. Lanczos Solver

Solver parameters

```
LNC_ENE_CONV = 1.0E-14
MAXITR = 10000
MINITR = 5
ITRINT = 5
```

Total Lanczos iterations

```
total lanczos step: 160
```

---

# 11. Ground-state Energy

The converged ground-state energy is

$$
E_0 = -5.652675156567411.
$$

---

# 12. Eigenvector Accuracy

Verification

$$
\langle GS|H|GS\rangle =
-5.652675156567412
$$

Residual

$$
|1-(\langle GS|H|GS\rangle)^2/\langle GS|H^2|GS\rangle|
=5.551115123125783\times10^{-16}.
$$

The solution therefore reaches **machine precision**.

---

# 13. Observables

Enabled in the input

```
CAL_LM = 1
CAL_CF = 1
```

Generated files

| file | description |
|-----|-------------|
| `local_mag.dat` | local magnetization |
| `two_body_cf_xyz.dat` | spin correlations |
| `two_body_cf_z+-.dat` | ladder correlations |

---

# 14. Runtime

Measured runtime

```
Time: 0.276 sec
```

---

# 15. Summary

This example demonstrates a **mixed-spin quantum chain** calculation with QS³-ED2.

The example highlights

- heterogeneous local Hilbert spaces
- symmetry reduction with enlarged unit cells
- momentum-sector diagonalization
- Lanczos ground-state computation
- calculation of physical observables.
