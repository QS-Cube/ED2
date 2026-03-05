
# Kagome Lattice Example

Directory

```
examples/kagome/
```

This example demonstrates how to run **QS³-ED2** for a two-dimensional
**kagome-lattice quantum spin system** with periodic boundary conditions.

The system contains

$$
N = 108
$$

spin-1/2 sites arranged on a kagome lattice with a

$$
6 \times 6
$$

Bravais lattice (three sites per unit cell).

The ground state is computed using the **Lanczos method**, and the program evaluates

- ground-state energy
- local magnetization
- two-point spin correlations.

!!! note

    The numerical values shown in this document are taken from the
    reference output stored in

    `examples/ref_dat/kagome/output.dat`.

    These files are provided as reference data for documentation
    and regression testing. The exact numerical values may vary
    slightly depending on the compilation environment and hardware.

---

# 1. Introduction

This example illustrates calculations on a **geometrically frustrated lattice**
using QS³-ED2.

The kagome lattice has a **three-site unit cell** and coordination number

$$
z = 4.
$$

The example demonstrates

- Hamiltonian construction on a frustrated lattice
- translational symmetry in two directions
- momentum-sector selection
- Lanczos diagonalization
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
NOS = 108
L1 = 6
L2 = 6
```

The kagome lattice has **three sites per unit cell**, therefore

$$
N = 3 L_1 L_2.
$$

For this example

$$
N = 3 \times 6 \times 6 = 108.
$$

Each site has four nearest neighbors.

Total number of bonds

```
NO_TWO = 216
```

This matches

$$
\frac{Nz}{2} =
\frac{108 \times 4}{2}
= 216.
$$

---

# 5. Symmetry Operations

Translational symmetry is defined by

```
FILE_S1 = list_p1.dat
FILE_S2 = list_p2.dat
```

These correspond to lattice translations

$$
T_x : (x,y) \rightarrow (x+1,y)
$$

$$
T_y : (x,y) \rightarrow (x,y+1).
$$

Periodic boundary conditions are applied in both directions.

---

# 6. Momentum (Wavevector) Sector

Wavevector parameters

```
L1 = 6
L2 = 6
M1 = 0
M2 = 0
```

Allowed wavevectors

$$
k_x = \frac{2\pi m_1}{L_1}, \qquad
k_y = \frac{2\pi m_2}{L_2}
$$

with

$$
m_1 = 0,\dots,5,
\qquad
m_2 = 0,\dots,5.
$$

The calculation selects

```
M1 = 0
M2 = 0
```

which corresponds to

$$
(k_x,k_y) = (0,0).
$$

Thus the Lanczos diagonalization is performed in the **zero-momentum sector**

$$
T_x|\psi\rangle = |\psi\rangle,
\qquad
T_y|\psi\rangle = |\psi\rangle.
$$

---

# 7. Local Hilbert Space

Each lattice site hosts

$$
S = \frac12
$$

so the local Hilbert-space dimension is

$$
2S + 1 = 2.
$$

---

# 8. NOD Sector Restriction

QS³-ED2 labels basis states using

$$
n_i = S_i - m_i
$$

For spin-1/2

$$
n_i =
\begin{cases}
0 & (m_i = +1/2) \\
1 & (m_i = -1/2)
\end{cases}
$$

The global quantity

$$
\mathrm{NOD} = \sum_i n_i
$$

counts the number of down spins.

Input parameters

```
NODmin = 0
NODmax = 3
```

restrict

$$
N_\downarrow \in \{0,1,2,3\}.
$$

---

# 9. Hilbert-space Dimension

From `output.dat`

```
THS   = 210043
THS(k)= 5848
```

- `THS` : Hilbert-space dimension before symmetry reduction
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
total lanczos step: 65
```

---

# 11. Ground-state Energy

The converged ground-state energy is

$$
E_0 = -5.909297683810853.
$$

---

# 12. Eigenvector Accuracy

Verification

$$
\langle GS|H|GS\rangle =
-5.909297683810856
$$

Residual

$$
|1-(\langle GS|H|GS\rangle)^2 / \langle GS|H^2|GS\rangle|
=1.110223024625157 \times 10^{-15}.
$$

This indicates convergence close to machine precision.

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

Correlation pairs are defined in

```
list_ij_cf.dat
```

---

# 14. Runtime

Measured runtime

```
Time: 0.349 sec
```

---

# 15. Summary

This example demonstrates a **kagome-lattice quantum spin model**
calculation with QS³-ED2.

Key features illustrated include

- geometrical frustration and a three-site unit cell
- translational symmetry reduction
- momentum-sector diagonalization
- Lanczos ground-state computation
- evaluation of correlation functions.
