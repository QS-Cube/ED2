
# Cubic Lattice (Sparse Hilbert Space, Fixed NOD) Example

Directory

```
examples/cubic_sp_HB/
```

This example demonstrates how to run **QS³‑ED2** for a three‑dimensional
**cubic lattice** with periodic boundary conditions in a **fixed NOD sector**
and using additional **reflection symmetries**.

The system contains

$$
N = 1000
$$

spin‑1/2 sites arranged on a

$$
10 \times 10 \times 10
$$

cubic lattice.

The ground state is computed using the **Lanczos method**, and the program evaluates

- ground‑state energy
- local magnetization
- two‑point spin correlations.

!!! note

    The numerical values shown in this document are taken from the
    reference output stored in

    `examples/ref_data/cubic_sp_HB/output.dat`.

    These are archived reference data, not a measurement on your current
    build. The original compiler, flags, and hardware are not recorded
    alongside every fixture. Numerical values and iteration counts can vary.
    The bundled example smoke tests check output production; a successful
    smoke test alone does not establish agreement with these energies.
    `python3 tests/verify_ex9.py` checks only the archived reference file
    shapes, finite values, sum rules and paired-output consistency. After
    completing a fresh full ex9 calculation, use
    `python3 tests/verify_ex9.py --actual examples/cubic_sp_HB` to compare
    all generated energies and observables with the archived files. This is
    not a substitute for independent solver convergence and model checks.

## Running this example

After completing the [installation](../getting-started/installation.md),
run the following from the repository root:

```sh
(cd script_cubic_sp_HB && ./run.sh)
```

The script generates `examples/cubic_sp_HB/input.dat` and its companion
files, then runs the already built solver. Copy the generated input and
output files before rerunning: some observable files append new records.

!!! warning "Large example"

    This is the 1000-site, fixed-three-magnon example. Its unreduced sector
    has 166,167,000 configurations. Assess representative-state setup time
    and memory before running it; the archived 121-second timing is not a
    resource guarantee. For an initial installation check use the chain
    smoke test described in the installation guide.

!!! note "Sector ground state"

    For the isotropic, zero-field Hamiltonian used here, total $S^z$ is
    conserved. `NODmin=NODmax=3` is an exact magnetization sector. The
    quoted energy is the lowest energy within this sector and the selected
    zero-momentum, even-reflection representation; it is not the global
    zero-field antiferromagnetic ground-state energy.

---

# 1. Introduction

This example illustrates a large‑scale 3D lattice calculation using QS³‑ED2,
where the computation is restricted to a **single NOD sector** and further
reduced using **translational and reflection symmetries**.

Key features include

- cubic lattice geometry in three dimensions
- translational symmetry in three directions
- reflection symmetry in three directions
- momentum‑sector selection
- fixed‑$\mathrm{NOD}$ restriction
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

The shipped script and archived `input_param.dat` use the isotropic
antiferromagnetic Heisenberg Hamiltonian $H=\sum_{\langle i,j\rangle}
\mathbf S_i\cdot\mathbf S_j$ with unit exchange and no fields.

Magnetic field

$$
\mathbf{h}=(0,0,0)
$$

Exchange parameters

$$
(J_x,J_y,J_z)=(1,1,1)
$$

Dzyaloshinskii–Moriya interaction

$$
\mathbf{D}=(0,0,0)
$$

$\Gamma$ interaction

$$
(\Gamma_x,\Gamma_y,\Gamma_z)=(0,0,0)
$$

---

# 4. Lattice Structure

System parameters from `output.dat`

```
NOS = 1000
L1 = 10
L2 = 10
L3 = 10
```

For a cubic lattice

$$
N = L_1 L_2 L_3 = 10\times10\times10 = 1000
$$

Each site has coordination number

$$
z = 6
$$

Total number of nearest‑neighbor bonds

```
NO_TWO = 3000
```

which matches

$$
\frac{Nz}{2} = \frac{1000\times6}{2} = 3000.
$$

---

# 5. Translational Symmetry

Translational symmetry operations are defined by

```
FILE_S1 = list_p1.dat
FILE_S2 = list_p2.dat
FILE_S3 = list_p3.dat
```

corresponding to

$$
T_x : (x,y,z) \rightarrow (x+1,y,z)
$$

$$
T_y : (x,y,z) \rightarrow (x,y+1,z)
$$

$$
T_z : (x,y,z) \rightarrow (x,y,z+1)
$$

with periodic boundary conditions.

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

The present calculation selects

$$
(k_x,k_y,k_z)=(0,0,0).
$$

---

# 7. Reflection (Inversion) Symmetry

In addition to translations, QS³‑ED2 can use **reflection operations**
along each lattice direction.

The parameters

```
L4 = 2
L5 = 2
L6 = 2
```

activate reflection operations for the

- x direction
- y direction
- z direction

respectively.

With the generator’s one-based coordinates $x=1,\ldots,L_x$ (and
likewise for $y,z$), these bond-centered reflections are

$$
R_x : (x,y,z) \rightarrow (L_x+1-x,y,z)
$$

$$
R_y : (x,y,z) \rightarrow (x,L_y+1-y,z)
$$

$$
R_z : (x,y,z) \rightarrow (x,y,L_z+1-z).
$$

The corresponding quantum numbers are specified by

```
M4 = 0
M5 = 0
M6 = 0
```

which select the **even parity sector** under each reflection.

Thus the ground state satisfies

$$
R_x|\psi\rangle = |\psi\rangle
$$

$$
R_y|\psi\rangle = |\psi\rangle
$$

$$
R_z|\psi\rangle = |\psi\rangle.
$$

Using these reflection symmetries significantly reduces the Hilbert‑space size.

---

# 8. Local Hilbert Space

Each site hosts

$$
S=\frac12
$$

so the local Hilbert‑space dimension is

$$
2S+1=2.
$$

---

# 9. NOD Sector Restriction

The NOD restriction is fixed

```
NODmin = 3
NODmax = 3
```

Thus

$$
\mathrm{NOD} = 3.
$$

For spin‑1/2 systems this corresponds to

$$
N_\downarrow = 3.
$$

---

# 10. Hilbert‑space Dimension

From `output.dat`

```
THS   = 166167000
THS(k)= 23719
```

- `THS` : dimension before symmetry reduction
- `THS(k)` : representative states after symmetry reduction

---

# 11. Lanczos Solver

The padded Hamiltonian-cache transition-capacity parameter is fixed

```
MNTE = 19
```

Output confirms

```
Current MNTE = 19
Optimal MNTE = 19
```

The diagnostic reports the maximum occupied count including the diagonal.
The allocation uses `MNTE+1` slots per cached row. For three separated
magnons the physical count is at most 18 hopping records plus one diagonal;
`MNTE=19` is a conservative supplied value, not a requirement that the
Lanczos basis contain 19 vectors.

Solver parameters

```
LNC_ENE_CONV = 1.0E-14
MAXITR = 10000
MINITR = 5
ITRINT = 5
```

Total iterations

```
total lanczos step: 140
```

---

# 12. Ground‑state Energy

The converged ground‑state energy is

$$
E_0 = 7.367224213680655 \times 10^{2}.
$$

---

# 13. Eigenvector Accuracy

Verification

$$
\langle GS|H|GS\rangle =
7.367224213680651 \times 10^{2}
$$

Dimensionless variance diagnostic

$$
|1-(\langle GS|H|GS\rangle)^2/\langle GS|H^2|GS\rangle|
=1.110223024625157\times10^{-15}.
$$

---

# 14. Observables

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

# 15. Runtime

Runtime recorded in the archived reference output

```
Time: 121.074 sec
```

---

# 16. Summary

This example demonstrates a large‑scale

$$
10\times10\times10
$$

cubic‑lattice calculation with QS³‑ED2 using

- translational symmetry
- reflection symmetry
- fixed‑$\mathrm{NOD}$ restriction
- Lanczos diagonalization
- symmetry‑reduced Hilbert spaces.
