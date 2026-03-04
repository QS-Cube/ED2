# J1–J2 Chain Example

The example located in

```
examples/j1j2_chain/
```

demonstrates how to run QS³-ED2 for a **frustrated 1D spin chain** with both **nearest-neighbor ($J_1$)** and **next-nearest-neighbor ($J_2$)** couplings, including anisotropic exchange (XYZ), Dzyaloshinskii–Moriya (DM) interaction, symmetric off-diagonal $\Gamma$ interaction, and a uniform magnetic field.

This example uses **translational symmetry** (1D momentum sectors) to reduce the Hilbert space size.

---

## Quick start

```bash
cd examples/j1j2_chain
./run.sh
```

(As in `chain.md`, `run.sh` resolves the ED2 executable and runs `QS3ED2 < input.dat`.)

---

# Model

We consider a periodic chain of $N$ spin-$1/2$ sites ($N=\texttt{NOS}=100). The Hamiltonian is

$$
H =
\sum_{\langle i,j\rangle_1} H_{ij}^{(1)}
+
\sum_{\langle i,j\rangle_2} H_{ij}^{(2)}
+
\sum_{i=1}^{N} \mathbf{h}\cdot\mathbf{S}_i ,
$$

where $\langle i,j\rangle_1$ denotes **nearest-neighbor (NN)** bonds and $\langle i,j\rangle_2$ denotes **next-nearest-neighbor (NNN)** bonds (periodic boundary condition).
For each bond $(i,j)$ we define

$$
\begin{aligned}
H_{ij}^{(n)}
&=
\sum_{\alpha=x,y,z} J_{\alpha}^{(n)}\, S_i^\alpha S_j^\alpha
+
\mathbf{D}^{(n)}\cdot\left(\mathbf{S}_i\times\mathbf{S}_j\right)
\\
&\quad
+
\Gamma_x^{(n)}\left(S_i^{y}S_j^{z}+S_i^{z}S_j^{y}\right)
+
\Gamma_y^{(n)}\left(S_i^{z}S_j^{x}+S_i^{x}S_j^{z}\right)
+
\Gamma_z^{(n)}\left(S_i^{x}S_j^{y}+S_i^{y}S_j^{x}\right).
\end{aligned}
$$

Here $n=1$ (NN, $J_1$) or $n=2$ (NNN, $J_2$). The couplings are specified in `list_xyz_dm_gamma.dat` (bond list), while the magnetic field is specified in `list_hvec.dat` (site list).

## Parameters used in this example

From `input_param.dat`:

- Spin: `SPIN = 0.5d0` (spin-$1/2$)
- System size: `NOS = 100`
- Magnetization sectors: `NODmin = 0`, `NODmax = 3`

Uniform magnetic field:

$$
\mathbf{h}=(h_x,h_y,h_z)=(-0.1d0,-0.1d0,-0.3d0).
$$

Nearest-neighbor ($J_1$) couplings:

$$
(J_x^{(1)},J_y^{(1)},J_z^{(1)})=(1.0d0,0.8d0,0.7d0),\quad
\mathbf{D}^{(1)}=(0.2d0,0.1d0,5.0d0),\quad
(\Gamma_x^{(1)},\Gamma_y^{(1)},\Gamma_z^{(1)})=(0.1d0,0.3d0,-0.2d0).
$$

Next-nearest-neighbor ($J_2$) couplings:

$$
(J_x^{(2)},J_y^{(2)},J_z^{(2)})=(0.5d0,0.4d0,0.35d0),\quad
\mathbf{D}^{(2)}=(0.1d0,0.05d0,2.5d0),\quad
(\Gamma_x^{(2)},\Gamma_y^{(2)},\Gamma_z^{(2)})=(0.05d0,0.15d0,-0.1d0).
$$

---

# Input files

This example uses the same high-level workflow as `chain.md`. The key difference is that this example includes both NN ($J_1$) and NNN ($J_2$) bonds.

## `input.dat`

Top-level control file that points to the other inputs (parameter file, lists, symmetry files, etc.).
(See `chain.md` for the detailed explanation of `input.dat` structure.)

## `input_param.dat`

Parameter file (Fortran namelist `&input_parameters`) specifying system size, sector restriction, and default coupling values.

## `list_hvec.dat`

Site list for the magnetic field.
In this example, the field is uniform (same $(h_x,h_y,h_z)$ for all sites).

## `list_xyz_dm_gamma.dat` (bond list)

Bond list for $(J_x,J_y,J_z)$, $(D_x,D_y,D_z)$, and $(\Gamma_x,\Gamma_y,\Gamma_z)$.

**Two-block structure (confirmed):**

- Lines **1–100**: NN bonds ($J_1$): `(1,2),(2,3),...,(99,100),(100,1)`
- Lines **101–200**: NNN bonds ($J_2$): `(1,3),(2,4),...,(99,1),(100,2)`

The file contains `NO_TWO = 200` bonds in total.

Example lines:

```text
(1)          1       2  1.000000000000000E+00  8.000000000000000E-01  7.000000000000000E-01  2.000000000000000E-01  1.000000000000000E-01  5.000000000000000E+00  1.000000000000000E-01  3.000000000000000E-01 -2.000000000000000E-01
(100)      100       1  1.000000000000000E+00  8.000000000000000E-01  7.000000000000000E-01  2.000000000000000E-01  1.000000000000000E-01  5.000000000000000E+00  1.000000000000000E-01  3.000000000000000E-01 -2.000000000000000E-01
(101)        1       3  5.000000000000000E-01  4.000000000000000E-01  3.500000000000000E-01  1.000000000000000E-01  5.000000000000000E-02  2.500000000000000E+00  5.000000000000000E-02  1.500000000000000E-01 -1.000000000000000E-01
(200)      100       2  5.000000000000000E-01  4.000000000000000E-01  3.500000000000000E-01  1.000000000000000E-01  5.000000000000000E-02  2.500000000000000E+00  5.000000000000000E-02  1.500000000000000E-01 -1.000000000000000E-01
```

---

# Running the example

Same as in `chain.md`:

```bash
../../source/QS3ED2 < input.dat
```

---

# Understanding `output.dat`

Key numbers for this example run:

- `THS = 166751`
- `THS(k) = 1669`
- `E0 = `
- `total lanczos step = `
- eigenvector quality: `9.336910151034534E-17`

---

# Translational symmetry (`FILE_S1`–`FILE_S6`)

This example uses 1D translation symmetry as in `chain.md`. See `chain.md` for details.

---

# Observables and output files

This example computes the same categories of observables as in `chain.md` (when enabled). See `chain.md` for details.

---

# Summary

This example demonstrates how to set up and run a **frustrated $J_1$–$J_2$ chain** with DM and $\Gamma$ couplings under a magnetic field, while exploiting **translational symmetry** to reduce the Hilbert space and accelerate Lanczos diagonalization.
