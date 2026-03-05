
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

!!! note

    The numerical values shown in this document are taken from the
    reference output stored in

    `examples/ref_dat/chain/output.dat`.

    These files are provided as reference data for documentation
    and regression testing. The exact numerical values may vary
    slightly depending on the compilation environment and hardware.

---

# 1. Introduction

This example illustrates a basic calculation with **QS³‑ED2** for a periodic
one‑dimensional quantum spin system.

The workflow demonstrates

- construction of the Hamiltonian
- symmetry reduction using lattice translations
- momentum‑sector selection
- Lanczos diagonalization
- evaluation of physical observables.

The model includes

- anisotropic exchange (XYZ)
- Dzyaloshinskii–Moriya interaction
- symmetric anisotropic $\Gamma$ interaction
- uniform magnetic field.

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

$\Gamma$ interaction

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

This translation generates the cyclic symmetry group of the periodic chain.

---

# 6. Momentum (Wavevector) Sector

QS³‑ED2 allows diagonalization within a fixed **crystal momentum sector** defined
with respect to the translation symmetry.

The input parameters

```
M1 = 0
```

select the momentum sector corresponding to the eigenvalue

$$
T |\psi\rangle =
e^{i k} |\psi\rangle .
$$

For a chain of length

$$
L_1 = 100
$$

the allowed wavevectors are

$$
k =
\frac{2\pi m}{L_1},
\qquad
m = 0,1,\dots,L_1-1.
$$

The parameter

```
M1 = 0
```

therefore selects

$$
k = 0.
$$

Thus the calculation is performed in the **zero‑momentum sector**, i.e.

$$
T|\psi\rangle = |\psi\rangle .
$$

This sector contains the translationally invariant states and typically hosts
the ground state for many spin models.

---

# 7. Local Hilbert Space

Each site hosts a spin

$$
S=\frac12
$$

so the local Hilbert‑space dimension is

$$
2S+1=2.
$$

---

# 8. NOD Sector Restriction

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
\mathrm{NOD}=
\sum_i n_i
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

# 9. Hilbert‑space Dimension

From the program output

```
THS   = 166751
THS(k)= 1669
```

- `THS` : dimension before symmetry reduction
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
total lanczos step: 150
```

---

# 11. Ground‑state Energy

The converged ground‑state energy is

$$
E_0 = -1.299620173300453 \times 10^{1}.
$$

---

# 12. Eigenvector Accuracy

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

# 14. Runtime

Measured runtime

```
Time: 0.221 sec
```

The runtime depends mainly on

- Hilbert‑space dimension
- number of Lanczos iterations
- BLAS performance.

---

# 15. Summary

This example demonstrates a QS³‑ED2 calculation for a periodic spin chain.

Key features illustrated here include

- construction of anisotropic spin Hamiltonians
- translational symmetry reduction
- momentum‑sector selection
- Lanczos ground‑state computation
- evaluation of magnetization and correlation functions.

