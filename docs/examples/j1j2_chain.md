
# J1–J2 Chain Example

Directory

```
examples/j1j2_chain/
```

This example demonstrates how to run **QS³-ED2** for a frustrated one‑dimensional
spin chain with both **nearest‑neighbor ($J_1$)** and **next‑nearest‑neighbor ($J_2$)**
interactions.

The system consists of

$$
N = 100
$$

spin‑1/2 sites on a periodic chain.

The ground state is computed using the **Lanczos method**, and the program evaluates

- ground‑state energy
- local magnetization
- two‑point spin correlations

!!! note

    The numerical values shown in this document are taken from the
    reference output stored in

    `examples/ref_dat/j1j2_chain/output.dat`.

    These files are provided as reference data for documentation
    and regression testing. The exact numerical values may vary
    slightly depending on the compilation environment and hardware.
    
---

# 1. Introduction

This example extends the basic chain calculation by introducing
**next‑nearest‑neighbor interactions**, producing a frustrated spin system.

The example demonstrates

- construction of a Hamiltonian with multiple bond ranges
- symmetry reduction using lattice translations
- momentum‑sector selection
- Lanczos diagonalization
- evaluation of physical observables.

---

# 2. Model Hamiltonian

The Hamiltonian is

$$
H =
\sum_{\langle i,j\rangle_1} H^{(1)}_{ij}
+
\sum_{\langle i,j\rangle_2} H^{(2)}_{ij}
+
\sum_i \mathbf{h}\cdot\mathbf{S}_i
$$

where the bond Hamiltonian is

$$
H^{(n)}_{ij} =
\sum_{\alpha=x,y,z}
J_\alpha^{(n)} S_i^\alpha S_j^\alpha
+
\mathbf{D}^{(n)}\cdot(\mathbf{S}_i \times \mathbf{S}_j)
+
H_\Gamma^{(n)}(i,j).
$$

The symmetric anisotropic interaction is

$$
H_\Gamma^{(n)}(i,j)=
\Gamma_x^{(n)}(S_i^y S_j^z + S_i^z S_j^y)
+
\Gamma_y^{(n)}(S_i^z S_j^x + S_i^x S_j^z)
+
\Gamma_z^{(n)}(S_i^x S_j^y + S_i^y S_j^x).
$$

Here

- $n=1$ denotes **nearest‑neighbor ($J_1$)** interactions
- $n=2$ denotes **next‑nearest‑neighbor ($J_2$)** interactions.

---

# 3. Coupling Parameters

Magnetic field

$$
\mathbf{h}=(-0.1,-0.1,-0.3)
$$

Nearest‑neighbor ($J_1$) couplings

$$
(J_x^{(1)},J_y^{(1)},J_z^{(1)})=(1.0,0.8,0.7)
$$

$$
\mathbf{D}^{(1)}=(0.2,0.1,5.0)
$$

$$
(\Gamma_x^{(1)},\Gamma_y^{(1)},\Gamma_z^{(1)})=(0.1,0.3,-0.2)
$$

Next‑nearest‑neighbor ($J_2$) couplings

$$
(J_x^{(2)},J_y^{(2)},J_z^{(2)})=(0.5,0.4,0.35)
$$

$$
\mathbf{D}^{(2)}=(0.1,0.05,2.5)
$$

$$
(\Gamma_x^{(2)},\Gamma_y^{(2)},\Gamma_z^{(2)})=(0.05,0.15,-0.1)
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
(1,2),(2,3),\dots,(100,1)
$$

Next‑nearest‑neighbor bonds

$$
(1,3),(2,4),\dots,(100,2)
$$

Total number of bonds

```
NO_TWO = 200
```

---

# 5. Symmetry Operations

Translational symmetry

```
FILE_S1 = list_p1.dat
```

Translation operator

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

# 6. Momentum (Wavevector) Sector

Wavevector parameters from the input

```
L1 = 100
M1 = 0
```

The allowed momenta are

$$
k = \frac{2\pi m}{L_1}, \qquad m=0,1,\dots,L_1-1.
$$

The parameter

```
M1 = 0
```

selects

$$
k = 0.
$$

Thus the calculation is performed in the **zero‑momentum sector**

$$
T|\psi\rangle = |\psi\rangle .
$$

---

# 7. Local Hilbert Space

Each site hosts

$$
S=\frac12
$$

so the local Hilbert space dimension is

$$
2S+1=2.
$$

---

# 8. NOD Sector Restriction

QS³‑ED2 labels basis states using

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

From `output.dat`

```
THS   = 166751
THS(k)= 1669
```

- `THS` : dimension before symmetry reduction
- `THS(k)` : dimension after symmetry and momentum reduction

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

# 11. Ground‑state Energy

The converged ground‑state energy is

$$
E_0 = -3.656548006870278 \times 10^{0}.
$$

---

# 12. Eigenvector Accuracy

Verification

$$
\langle GS|H|GS\rangle =
-3.656548006870279
$$

Residual

$$
|1-(\langle GS|H|GS\rangle)^2/\langle GS|H^2|GS\rangle|
=7.771561172376096\times10^{-16}.
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
| `two_body_cf_xyz.dat` | spin correlation tensor |
| `two_body_cf_z+-.dat` | ladder correlations |

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
Time: 0.329 sec
```

---

# 15. Summary

This example demonstrates a **frustrated $J_1$–$J_2$ spin chain**
calculation using QS³‑ED2.

Key features illustrated include

- multi‑range spin interactions
- translational symmetry reduction
- momentum‑sector selection
- Lanczos ground‑state computation
- evaluation of correlation functions.

