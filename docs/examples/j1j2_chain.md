
# J1–J2 Chain Example

This example demonstrates how to run **QS³ ED2** for a one‑dimensional spin system.
The example located in

```
examples/j1j2_chain/
```
contains all input and output files required to reproduce the calculation.

The system consists of **100 spin‑1/2 sites** arranged on a **periodic one‑dimensional chain**
with **nearest‑neighbor ($J_1$) and next‑nearest‑neighbor ($J_2$) couplings**.
Each bond can include anisotropic exchange (XYZ), Dzyaloshinskii–Moriya interactions, Γ interactions,
and the system is subject to a uniform magnetic field.

The ground state is computed using the **Lanczos method**, and the program evaluates

- ground‑state energy
- local magnetization
- two‑point spin correlation functions

---

# Model

This example implements a **$J_1$–$J_2$ spin chain** with (i) anisotropic exchange (XYZ),
(ii) Dzyaloshinskii–Moriya (DM) interaction, (iii) symmetric off‑diagonal $\Gamma$ interaction,
and (iv) a uniform magnetic field.

We consider a periodic chain of $N$ spin‑$1/2$ sites ($N=\texttt{NOS}=100$). The Hamiltonian is

$$
H =
\sum_{\langle i,j\rangle_1} H_{ij}^{(1)}
+
\sum_{\langle i,j\rangle_2} H_{ij}^{(2)}
+
\sum_{i=1}^{N} \mathbf{h}_i \cdot \mathbf{S}_i ,
$$

where $\langle i,j\rangle_1$ denotes **nearest‑neighbor (NN)** bonds and $\langle i,j\rangle_2$ denotes
**next‑nearest‑neighbor (NNN)** bonds. For each bond $(i,j)$ we define

$$
\begin{aligned}
H_{ij}^{(n)}
&=
\sum_{\alpha=x,y,z} J^{(n)}_{\alpha}\, S_i^{\alpha} S_j^{\alpha}
+
\mathbf{D}^{(n)} \cdot \left(\mathbf{S}_i \times \mathbf{S}_j\right)
\\
&\quad
+
\Gamma_x^{(n)}\left(S_i^{y}S_j^{z}+S_i^{z}S_j^{y}\right)
+
\Gamma_y^{(n)}\left(S_i^{z}S_j^{x}+S_i^{x}S_j^{z}\right)
+
\Gamma_z^{(n)}\left(S_i^{x}S_j^{y}+S_i^{y}S_j^{x}\right),
\end{aligned}
$$

with $n=1$ (NN, $J_1$) or $n=2$ (NNN, $J_2$). Here $J_{\alpha}^{(n)}$ is the anisotropic exchange,
$\mathbf{D}^{(n)}=(D_x^{(n)},D_y^{(n)},D_z^{(n)})$ is the DM vector, and
$(\Gamma_x^{(n)},\Gamma_y^{(n)},\Gamma_z^{(n)})$ are the symmetric off‑diagonal couplings.

In this example the field is uniform:
$\mathbf{h}_i=\mathbf{h}=(h_x,h_y,h_z)$ for all $i$.

Magnetic field:

$$
\mathbf{h}=(-0.1,-0.1,-0.3)
$$

Nearest‑neighbor ($J_1$) parameters:

$$
(J_x^{(1)},J_y^{(1)},J_z^{(1)})=(1.0,0.8,0.7)
$$

$$
\mathbf{D}^{(1)}=(0.2,0.1,5.0)
$$

$$
(\Gamma_x^{(1)},\Gamma_y^{(1)},\Gamma_z^{(1)})=(0.1,0.3,-0.2)
$$

Next‑nearest‑neighbor ($J_2$) parameters:

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

# Input Files

The calculation is controlled by several input files located in
`examples/chain/`.

## input_param.dat

This file defines the global simulation parameters.

| parameter | meaning |
|-----------|---------|
| `NOS` | number of sites |
| `NODMIN`, `NODMAX` | range of down‑spin sectors |
| `SPIN` | local spin magnitude |
| `HX,HY,HZ` | magnetic field components |
| `JX,JY,JZ` | exchange couplings |
| `DX,DY,DZ` | DM interaction |
| `GX,GY,GZ` | Γ interaction |

For this example

```
NOS = 100
NODMIN = 0
NODMAX = 3
SPIN = 0.5
```

The solver therefore evaluates sectors with

$$
N_{\downarrow}\in\{0,1,2,3\}.
$$

For spin‑1/2 systems the corresponding total magnetization is

$$
S^z_{\mathrm{tot}}=\frac{N}{2}-N_{\downarrow}.
$$

---

## list_xyz_dm_gamma.dat

This file defines **bond interactions**.

Each row contains

```
i  j  Jx  Jy  Jz  Dx  Dy  Dz  Gx  Gy  Gz
```

For the chain example the bonds are

```
(1,2)
(2,3)
...
(99,100)
(100,1)
```

The last bond indicates that the chain uses **periodic boundary conditions**.

---

## list_hvec.dat

This file specifies the magnetic field on each site.

Format

```
site   hx   hy   hz
```

In this example the field is uniform

$$
(h_x,h_y,h_z)=(-0.1,-0.1,-0.3).
$$

---

# Running the Example

Inside the example directory run

```
../../source/QS3ED2 < input.dat
```

The program prints a detailed execution log to the terminal.
When running the provided scripts, this output is redirected to

```
output.dat
```

---

# Reading `output.dat`

The file `output.dat` contains the main diagnostic information for the run.

## System size and translational symmetry

```
NOS = 100
```

The lattice dimensions are

```
L1 = 100
L2 = L3 = L4 = L5 = L6 = 1
```

This indicates a **one‑dimensional lattice**.

In QS³ ED2 translational symmetry operations are defined by

```
FILE_S1 ... FILE_S6
```

which correspond to translations associated with the lattice dimensions
`L1`–`L6`.

Because

```
L2 = L3 = L4 = L5 = L6 = 1
```

there are no translations in those directions, so

- `FILE_S2`–`FILE_S6` are ignored
- only `FILE_S1` is active

### Translation operator (`FILE_S1`)

The translation symmetry is defined in

```
list_p1.dat
```

which contains

```
2
3
4
...
100
1
```

This represents the mapping

$$
T(i)=i+1 \quad (i=1,\dots,99), \qquad T(100)=1.
$$

Thus the spin configuration transforms as

$$
(S_1,S_2,\dots,S_{100})
\rightarrow
(S_2,S_3,\dots,S_{100},S_1).
$$

This generates the cyclic translation group of the periodic chain.

QS³ ED2 uses this symmetry to construct **representative states** and reduce
the Hilbert space before diagonalization.

---

## Hilbert‑space size

```
THS = 166751
THS(k) = 1669
```

- `THS` : estimated dimension before symmetry reduction
- `THS(k)` : number of representative states after applying symmetry

The computational cost is governed mainly by `THS(k)`.

---

## Workspace parameter MNTE

```
MNTE = -1
```

activates automatic workspace estimation.

The program prints

```
Current MNTE = 1000
Optimal MNTE = 401
```

The recommended value for this example is

$$
MNTE \ge 401.
$$

---

## Lanczos solver

```
Eigen solver: Lanczos
```

Parameters

- convergence threshold

$$
LNC\_ENE\_CONV = 10^{-14}
$$

- iterations

```
total lanczos step = 145
```

---

## Ground-state energy

The computed ground-state energy is approximately

$$
E_0 \approx -1.2996...\times10^{1}.
$$

The exact value may differ slightly depending on the compiler,
BLAS library, or parallel execution environment.

---

## Eigenvector quality

ED2 verifies the accuracy of the Lanczos eigenvector using

$$
\left|
1-\frac{\langle GS|H|GS\rangle^2}{\langle GS|H^2|GS\rangle}
\right|.
$$

For this example the value is typically of order

$$
10^{-15}\sim10^{-16},
$$

indicating that the Lanczos ground state is converged to
near machine precision.

---

# Output Files

| file | description |
|-----|-------------|
| `eigenvalues.dat` | eigenvalues from Lanczos |
| `local_mag.dat` | local magnetization $\langle S_i^\alpha\rangle$ |
| `two_body_cf_xyz.dat` | full correlation tensor |
| `two_body_cf_z+-.dat` | $S^z$ and ladder correlations |
| `output.dat` | execution log |

---

# Observables

This example enables

```
CAL_LM = 1
CAL_CF = 1
```

so both local magnetization and two‑point correlations are computed in the
ground state $|{\rm GS}\rangle$.


## Correlation pairs (`list_ij_cf.dat`)

```
1 2
1 3
...
1 10
```

Thus correlations are evaluated for the pairs

$$
(1,2),(1,3),\dots,(1,10).
$$

This allows quick inspection of correlation decay along the chain.

---

## Local magnetization (`local_mag.dat`)

Columns

| column | meaning |
|---|---|
|1|site index $i$|
|2|$\langle S_i^x\rangle$|
|3|$\langle S_i^y\rangle$|
|4|$\langle S_i^z\rangle$|

Example output

```
i  -1.5e-08  -6.5e-09  4.7e-01
```

This indicates near‑zero transverse magnetization and a finite
$z$‑polarization.

Because the Hamiltonian and lattice are translation‑invariant,

$$
\langle S_i^\alpha\rangle \approx \langle S_{i+1}^\alpha\rangle.
$$

---

## Correlation tensor (`two_body_cf_xyz.dat`)

For each pair $(i,j)$ ED2 outputs

$$
C_{ij}^{\alpha\beta}
=\langle GS|S_i^\alpha S_j^\beta|GS\rangle.
$$

Columns

|col|meaning|
|---|---|
|1|$i$|
|2|$j$|
|3–11|correlation tensor components|

Matrix form

$$
\begin{pmatrix}
\langle S_i^x S_j^x\rangle & \langle S_i^x S_j^y\rangle & \langle S_i^x S_j^z\rangle \\
\langle S_i^y S_j^x\rangle & \langle S_i^y S_j^y\rangle & \langle S_i^y S_j^z\rangle \\
\langle S_i^z S_j^x\rangle & \langle S_i^z S_j^y\rangle & \langle S_i^z S_j^z\rangle
\end{pmatrix}
$$

A useful quantity is the bond chirality

$$
\langle (\mathbf S_i\times \mathbf S_j)_z\rangle
=
\langle S_i^xS_j^y\rangle
-
\langle S_i^yS_j^x\rangle .
$$

---

# Summary

This example illustrates a complete QS³ ED2 workflow

1. define a spin model via input files
2. construct a symmetry‑reduced Hilbert space
3. compute the ground state using the Lanczos method
4. evaluate physical observables

It also demonstrates how to interpret the diagnostic information printed in
`output.dat`.
