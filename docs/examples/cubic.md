
# Cubic Lattice Example

Directory

```
examples/cubic/
```

This example demonstrates how to run **QS³-ED2** for a three-dimensional
**cubic-lattice quantum spin system** with periodic boundary conditions.

The system contains

$$
N = 216
$$

spin-1/2 sites arranged on a

$$
6 \times 6 \times 6
$$

simple cubic lattice.

The ground state is computed using the **Lanczos method**, and the program evaluates

- ground-state energy
- local magnetization
- two-point spin correlations.

---

# 1. Introduction

This example illustrates calculations on a **three-dimensional lattice**
using QS³-ED2.

The cubic lattice has coordination number

$$
z = 6.
$$

The example demonstrates

- Hamiltonian construction on a 3D lattice
- translational symmetry in three directions
- momentum-sector selection
- Lanczos diagonalization
- evaluation of physical observables.

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
NOS = 216
L1 = 6
L2 = 6
L3 = 6
```

For a cubic lattice

$$
N = L_1 L_2 L_3.
$$

For this example

$$
N = 6 \times 6 \times 6 = 216.
$$

Each site has six nearest neighbors.

Total number of bonds

```
NO_TWO = 648
```

This matches

$$
\frac{Nz}{2} =
\frac{216 \times 6}{2}
= 648.
$$

---

# 5. Symmetry Operations

Translational symmetry is defined by

```
FILE_S1 = list_p1.dat
FILE_S2 = list_p2.dat
FILE_S3 = list_p3.dat
```

These correspond to lattice translations

$$
T_x : (x,y,z) \rightarrow (x+1,y,z)
$$

$$
T_y : (x,y,z) \rightarrow (x,y+1,z)
$$

$$
T_z : (x,y,z) \rightarrow (x,y,z+1)
$$

Periodic boundary conditions are applied in all three directions.

---

# 6. Momentum (Wavevector) Sector

Wavevector parameters

```
L1 = 6
L2 = 6
L3 = 6
M1 = 0
M2 = 0
M3 = 0
```

Allowed wavevectors

$$
k_x = \frac{2\pi m_1}{L_1},\quad
k_y = \frac{2\pi m_2}{L_2},\quad
k_z = \frac{2\pi m_3}{L_3}
$$

with

$$
m_1,m_2,m_3 = 0,\dots,5.
$$

The calculation selects

```
M1 = 0
M2 = 0
M3 = 0
```

which corresponds to

$$
(k_x,k_y,k_z) = (0,0,0).
$$

Thus the Lanczos diagonalization is performed in the **zero-momentum sector**

$$
T_x|\psi\rangle = |\psi\rangle,
\quad
T_y|\psi\rangle = |\psi\rangle,
\quad
T_z|\psi\rangle = |\psi\rangle.
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
THS   = 1679797
THS(k)= 7790
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
total lanczos step: 40
```

---

# 11. Ground-state Energy

The converged ground-state energy is

$$
E_0 = 3.291959953219396 \times 10^{1}.
$$

---

# 12. Eigenvector Accuracy

Verification

$$
\langle GS|H|GS\rangle =
3.291959953219396 \times 10^{1}
$$

Residual

$$
|1-(\langle GS|H|GS\rangle)^2 / \langle GS|H^2|GS\rangle|
=0.
$$

This indicates convergence to machine precision.

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
Time: 2.265 sec
```

---

# 15. Summary

This example demonstrates a **three-dimensional cubic-lattice quantum spin model**
calculation with QS³-ED2.

Key features illustrated include

- 3D lattice geometry
- translational symmetry reduction in three directions
- momentum-sector diagonalization
- Lanczos ground-state computation
- evaluation of correlation functions.
