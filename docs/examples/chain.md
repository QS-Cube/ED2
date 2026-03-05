
# 1D Chain Example

Directory

```
examples/chain/
```

This example demonstrates how to run **QS³‑ED2** for a periodic one‑dimensional spin system.

The system consists of

$$
N = 100
$$

spin‑1/2 sites arranged on a periodic chain.

The ground state is computed using the **Lanczos method**, and the program evaluates

- ground‑state energy
- local magnetization
- two‑point spin correlations

---

# 1. Introduction

This example illustrates a basic calculation with **QS³‑ED2** for a periodic
one‑dimensional quantum spin system.

The workflow demonstrates

- construction of the Hamiltonian
- symmetry reduction using lattice translations
- Lanczos diagonalization
- evaluation of physical observables.

The model includes

- anisotropic exchange (XYZ)
- Dzyaloshinskii–Moriya interaction
- symmetric anisotropic Γ interaction
- uniform magnetic field.

---

# 2. Model Hamiltonian

The Hamiltonian is

$$
H =
\sum_{\langle i,j \rangle}
H_{ij}
+
\sum_i \mathbf{h}\cdot\mathbf{S}_i
$$

where

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

In this example the couplings are uniform.

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

Γ interaction

$$
(\Gamma_x,\Gamma_y,\Gamma_z)=(0.1,0.3,-0.2)
$$

---

# 4. Lattice Structure

System parameters from `output.dat`

```
NOS = 100
L1  = 100
L2 = L3 = L4 = L5 = L6 = 1
```

Thus the system is a **periodic one‑dimensional chain**.

Nearest‑neighbor bonds

$$
(1,2),(2,3),\dots,(100,1).
$$

---

# 5. Symmetry Operations

Translational symmetry is defined by

```
FILE_S1 = list_p1.dat
```

The translation operator is

$$
T(i)=i+1 \quad (i=1,\dots,99), \qquad T(100)=1.
$$

This corresponds to the cyclic shift

$$
(S_1,S_2,\dots,S_{100})
\rightarrow
(S_2,S_3,\dots,S_{100},S_1).
$$

---

# 6. Local Hilbert Space

Each site hosts a spin

$$
S=\frac12
$$

so the local Hilbert‑space dimension is

$$
2S+1=2.
$$

---

# 7. NOD Sector Restriction

QS³‑ED2 uses the integer

$$
n_i = S_i - m_i
$$

For spin‑1/2

$$
n_i =
\begin{cases}
0 & (m_i=+1/2) \\
1 & (m_i=-1/2)
\end{cases}
$$

The global counter

$$
\mathrm{NOD}=\sum_i n_i
$$

equals the number of down spins.

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

# 8. Hilbert‑space Dimension

From the program output

```
THS   = 166751
THS(k)= 1669
```

- `THS` : dimension before symmetry reduction
- `THS(k)` : representative states after translation symmetry

---

# 9. Lanczos Solver

Solver parameters

```
LNC_ENE_CONV = 1.0E-14
MAXITR = 10000
MINITR = 5
ITRINT = 5
```

Total Lanczos iterations

```
total lanczos step: 150
```

---

# 10. Ground‑state Energy

The converged ground‑state energy is

$$
E_0 = -1.299620173300453 \times 10^{1}.
$$

---

# 11. Eigenvector Accuracy

Verification printed by the program

$$
\langle GS|H|GS\rangle =
-1.299620173300453 \times 10^{1}
$$

Residual

$$
|1-(\langle GS|H|GS\rangle)^2 / \langle GS|H^2|GS\rangle|
=4.440892098500626 \times 10^{-16}
$$

This indicates convergence close to machine precision.

---

# 12. Observables

Enabled in the input

```
CAL_LM = 1
CAL_CF = 1
```

Generated files

| file | description |
|-----|-------------|
| `local_mag.dat` | local magnetization |
| `two_body_cf_xyz.dat` | full spin correlations |
| `two_body_cf_z+-.dat` | ladder‑operator correlations |

Correlation pairs are defined in

```
list_ij_cf.dat
```

Example

$$
(1,2),(1,3),\dots,(1,10).
$$

---

# 13. Runtime

Measured runtime

```
Time: 0.221 sec
```

The runtime depends mainly on

- Hilbert‑space dimension
- number of Lanczos iterations
- BLAS performance.

---

# 14. Summary

This example demonstrates a basic QS³‑ED2 calculation for a periodic spin chain.

Key elements include

- definition of anisotropic spin Hamiltonians
- translational symmetry reduction
- Lanczos ground‑state calculation
- evaluation of physical observables.
