
# Triangular Lattice Example

Directory

```
examples/triangular/
```

This example demonstrates how to run **QS³-ED2** for a two-dimensional
**triangular-lattice quantum spin system** with periodic boundary conditions.

The system contains

$$
N = 100
$$

spin-1/2 sites arranged on a

$$
10 \times 10
$$

triangular lattice.

The ground state is computed using the **Lanczos method**, and the program evaluates

- ground-state energy
- local magnetization
- two-point spin correlations.

---

# 1. Introduction

This example illustrates a **frustrated two-dimensional lattice model** using QS³-ED2.

The triangular lattice introduces geometric frustration because each site
interacts with six nearest neighbors.

The example demonstrates

- Hamiltonian construction on a frustrated lattice
- translational symmetry in two spatial directions
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
NOS = 100
L1 = 10
L2 = 10
```

The system forms a

$$
10 \times 10
$$

triangular lattice with periodic boundary conditions.

Each site has **six nearest neighbors**.

Total number of bonds

```
NO_TWO = 300
```

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
L1 = 10
L2 = 10
M1 = 0
M2 = 0
```

Allowed wavevectors are

$$
k_x = \frac{2\pi m_1}{L_1},
\qquad
k_y = \frac{2\pi m_2}{L_2}
$$

with

$$
m_1 = 0,\dots,9,
\qquad
m_2 = 0,\dots,9.
$$

The input selects

```
M1 = 0
M2 = 0
```

which corresponds to

$$
(k_x,k_y) = (0,0).
$$

Thus the calculation is performed in the **zero-momentum sector**

$$
T_x|\psi\rangle = |\psi\rangle,
\qquad
T_y|\psi\rangle = |\psi\rangle.
$$

---

# 7. Local Hilbert Space

Each lattice site hosts

$$
S=\frac12
$$

so the local Hilbert-space dimension is

$$
2S+1=2.
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
0 & (m_i=+1/2) \\
1 & (m_i=-1/2)
\end{cases}
$$

The global quantity

$$
\mathrm{NOD}=\sum_i n_i
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
THS   = 166751
THS(k)= 1670
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
total lanczos step: 110
```

---

# 11. Ground-state Energy

The converged ground-state energy is

$$
E_0 = 7.186891958806912.
$$

---

# 12. Eigenvector Accuracy

Verification

$$
\langle GS|H|GS\rangle =
7.186891958806907
$$

Residual

$$
|1-(\langle GS|H|GS\rangle)^2/\langle GS|H^2|GS\rangle|
=9.992007221626409\times10^{-16}.
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

Correlation pairs are specified in

```
list_ij_cf.dat
```

---

# 14. Runtime

Measured runtime

```
Time: 0.318 sec
```

---

# 15. Summary

This example demonstrates a **triangular-lattice quantum spin model**
calculation using QS³-ED2.

Key features illustrated include

- Hamiltonians on frustrated lattices
- two-dimensional translational symmetry
- momentum-sector diagonalization
- Lanczos ground-state computation
- calculation of magnetization and correlation functions.
