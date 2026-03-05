
# Cubic Lattice (Sparse Hilbert Space, Fixed NOD) Example

Directory

```
examples/cubic_sp_HB/
```

This example demonstrates how to run **QS³-ED2** for a three-dimensional
**cubic lattice** with periodic boundary conditions in a **fixed NOD sector**
and with a **sparse Hilbert-space representation**.

The system contains

$$
N = 1000
$$

spin-1/2 sites arranged on a

$$
10 \times 10 \times 10
$$

lattice, with additional decomposition parameters

$$
(L_4,L_5,L_6)=(2,2,2).
$$

The ground state is computed using the **Lanczos method**, and the program evaluates

- ground-state energy
- local magnetization
- two-point spin correlations.

---

# 1. Introduction

This example illustrates a large-scale 3D lattice calculation using QS³-ED2,
where the computation is restricted to a **single NOD sector** and uses the
internal sparse representation to reduce memory usage.

Key features include

- cubic lattice geometry in three dimensions
- translational symmetry in three directions
- momentum-sector selection
- fixed-$\mathrm{NOD}$ restriction ($\mathrm{NODmin}=\mathrm{NODmax}$)
- Lanczos diagonalization in a reduced Hilbert space.

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
NOS = 1000
L1 = 10
L2 = 10
L3 = 10
L4 = 2
L5 = 2
L6 = 2
```

The physical lattice contains

$$
N = L_1 L_2 L_3 = 10 \times 10 \times 10 = 1000
$$

sites with periodic boundary conditions.

Each site has coordination number

$$
z = 6
$$

and the total number of nearest-neighbor bonds is

```
NO_TWO = 3000
```

This matches

$$
\frac{Nz}{2} = \frac{1000 \times 6}{2} = 3000.
$$

The parameters $L_4,L_5,L_6$ control an internal decomposition used by QS³-ED2
for this sparse-Hilbert-space workflow.

---

# 5. Symmetry Operations

Translational symmetry is defined by

```
FILE_S1 = list_p1.dat
FILE_S2 = list_p2.dat
FILE_S3 = list_p3.dat
```

These correspond to translations

$$
T_x : (x,y,z) \rightarrow (x+1,y,z)
$$

$$
T_y : (x,y,z) \rightarrow (x,y+1,z)
$$

$$
T_z : (x,y,z) \rightarrow (x,y,z+1).
$$

Periodic boundary conditions are applied in all three directions.

---

# 6. Momentum (Wavevector) Sector

Wavevector parameters

```
L1 = 10
L2 = 10
L3 = 10
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
m_1,m_2,m_3 = 0,\dots,9.
$$

The calculation selects

$$
(k_x,k_y,k_z) = (0,0,0).
$$

---

# 7. Local Hilbert Space

Each site hosts

$$
S=\frac12
$$

so the local Hilbert-space dimension is

$$
2S+1=2.
$$

---

# 8. NOD Sector Restriction

In this example the NOD restriction is fixed:

```
NODmin = 3
NODmax = 3
```

Thus the calculation is carried out in a single sector

$$
\mathrm{NOD} = 3.
$$

For spin-1/2 systems this corresponds to a fixed number of down spins

$$
N_\downarrow = 3.
$$

This fixed-sector restriction is essential for reducing the Hilbert-space size
in large lattices.

---

# 9. Hilbert-space Dimension

From `output.dat`

```
THS   = 166167000
THS(k)= 23719
```

- `THS` : Hilbert-space dimension in the selected NOD sector before symmetry reduction
- `THS(k)` : representative states after symmetry and momentum reduction

---

# 10. Lanczos Solver

In this run, the Lanczos work-space parameter is set explicitly:

```
MNTE = 19
```

The output confirms

```
Current MNTE = 19
Optimal MNTE = 19
```

Solver parameters

```
LNC_ENE_CONV = 1.0E-14
MAXITR = 10000
MINITR = 5
ITRINT = 5
```

Total Lanczos iterations

```
total lanczos step: 140
```

---

# 11. Ground-state Energy

The converged ground-state energy is

$$
E_0 = 7.367224213680655 \times 10^{2}.
$$

---

# 12. Eigenvector Accuracy

Verification

$$
\langle GS|H|GS\rangle =
7.367224213680651 \times 10^{2}
$$

Residual

$$
|1-(\langle GS|H|GS\rangle)^2/\langle GS|H^2|GS\rangle|
=1.110223024625157\times10^{-15}.
$$

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
Time: 121.074 sec
```

---

# 15. Summary

This example demonstrates a large-scale **$10\times10\times10$ cubic-lattice**
calculation with QS³-ED2 in a fixed-$\mathrm{NOD}$ sector.

Key features illustrated include

- fixed-$\mathrm{NOD}$ restriction ($\mathrm{NOD}=3$)
- translational symmetry and $(k_x,k_y,k_z)=(0,0,0)$ momentum sector
- Lanczos ground-state computation in a reduced Hilbert space
- evaluation of magnetization and correlation functions.
