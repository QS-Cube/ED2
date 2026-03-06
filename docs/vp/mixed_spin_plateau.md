# Performance: Magnetization Plateau in a Mixed-Spin Chain

## Overview

One of the distinctive capabilities introduced in **QS³‑ED2** is the support for **site‑dependent local spin magnitudes** and **site‑dependent limits on the number of lowering operations**.  
These are specified through the input files

- `list_spin.dat`
- `list_NODmax.dat`

This functionality makes it possible to efficiently treat systems with **non‑uniform local spins**, such as mixed‑spin chains.

As a representative example, we investigate the **magnetization plateau** appearing in an antiferromagnetic mixed‑spin chain with alternating spins

$$
(S,\,1/2).
$$

In particular, we study the **dependence of the plateau width on the spin magnitude \(S\)** at the magnetization

$$
\frac{M}{M_s} = \frac{2S-1}{2S+1}.
$$

This plateau is well known from analytical and numerical studies, including nonlinear spin‑wave theory and density‑matrix renormalization group (DMRG) calculations.

---

# Model

We consider a one‑dimensional mixed‑spin chain with alternating spins \(S\) and \(1/2\).  
The Hamiltonian is

$$
\hat H =
J\sum_{j=1}^{L}
\left[
\hat{\mathbf s}_{2j}\cdot
\left(\hat{\mathbf S}_{2j-1}+\hat{\mathbf S}_{2j+1}\right)
-
h\left(\hat S^z_{2j-1}+\hat s^z_{2j}\right)
\right],
$$

with periodic boundary conditions

$$
\hat{\mathbf S}_{2L+1}=\hat{\mathbf S}_1 .
$$

Here

- \(\hat{\mathbf S}_{2j-1}\) is a spin‑\(S\) operator
- \(\hat{\mathbf s}_{2j}\) is a spin‑\(1/2\) operator

located at sites \(2j-1\) and \(2j\), respectively.

The exchange coupling is antiferromagnetic

$$
J>0
$$

and throughout this benchmark we use

$$
J=1
$$

as the unit of energy.

The system contains \(2L\) sites, corresponding to \(L\) unit cells.

---

# Symmetries

The Hamiltonian is invariant under the following symmetry operations:

### Two‑site translation

Translation by one unit cell (two lattice sites).

### Site inversion

Reflection about the center of a unit cell combined with the exchange of the two sublattices.

These symmetries allow the Hilbert space to be decomposed into symmetry sectors, significantly reducing the computational cost.

In practice, the ground state of this system appears in the sector

- momentum \(k=0\) (Γ point)
- even parity under site inversion

which corresponds to

```
M1 = 0
M2 = 0
```

in the QS³‑ED2 input file.

---

# Saturation magnetization

The saturation magnetization of the system is

$$
M_s = \sum_{r=1}^{2L} S_r
$$

where \(S_r\) is the local spin magnitude at site \(r\).

For the alternating chain

$$
(S,\,1/2)
$$

this becomes

$$
M_s = L\left(S+\frac12\right)
      = \frac{L(2S+1)}{2}.
$$

---

# Magnetization sector

It is convenient to characterize the magnetization sector by the **number of lowering operations applied to the fully polarized state**, denoted

$$
N_{\downarrow}.
$$

In QS³‑ED2 this quantity corresponds directly to the parameter

```
NODmax
```

in the input configuration.

At the plateau position

$$
\frac{M}{M_s}=\frac{2S-1}{2S+1},
$$

the corresponding lowering number is

$$
N_{\downarrow}
= M_s - M
= M_s\left(1-\frac{2S-1}{2S+1}\right)
= L.
$$

Therefore, the plateau is located between the two neighboring magnetization sectors

$$
N_{\downarrow}=L
\qquad
\text{and}
\qquad
N_{\downarrow}=L-1.
$$

---

# QS³‑ED2 input structure

For a chain of length \(2L\), the key input parameters are

```
NOS     = 2L
L1      = L
L2      = 2
NO_one  = 0
NO_two  = 2L
```

The momentum and inversion sectors are specified as

```
M1 = 0
M2 = 0
```

The local spins and lowering limits are provided through

- `list_spin.dat`
- `list_NODmax.dat`

which define the allowed local spin values and the maximum number of lowering operations per site.

---

# Determining the plateau width

In the presence of a magnetic field \(h\), the ground state minimizes

$$
E_0(N_{\downarrow}) - h\,M(N_{\downarrow}).
$$

The critical field separating two neighboring magnetization sectors is determined from the difference of ground‑state energies,

$$
h_c(N_{\downarrow})
=
E_0(N_{\downarrow})
-
E_0(N_{\downarrow}-1).
$$

The magnetization plateau width is therefore obtained from the difference between two neighboring critical fields.

For the plateau considered here, the relevant energies are simply

- the ground state in the sector \(N_{\downarrow}=L\)
- the ground state in the sector \(N_{\downarrow}=L-1\)

so that the plateau width can be computed directly from the difference of these energies.

---

# Finite‑size behavior

Using QS³‑ED2, the plateau width can be computed with extremely small finite‑size effects.

Even relatively small systems

$$
L = 2,3,\dots,8
$$

already provide numerically well‑converged results.

---

# Results

The resulting plateau width as a function of the spin magnitude \(S\) is shown in Fig. 4.

The numerical results exhibit the following behavior:

- For **small \(S\)**, the results reproduce previously reported **DMRG calculations**.
- For **large \(S\)**, the results approach the **exact nonlinear spin‑wave prediction** in the limit \(S\to\infty\).

This agreement across the entire range of \(S\) demonstrates the reliability of QS³‑ED2 for treating mixed‑spin quantum systems with site‑dependent spin magnitudes.

---

# Practical remarks

This example highlights two important features of QS³‑ED2:

1. **Support for heterogeneous local spins** via `list_spin.dat`.
2. **Flexible magnetization‑sector control** through `list_NODmax.dat`.

Together, these capabilities enable efficient exact‑diagonalization studies of a broad class of quantum spin models that were difficult to treat in earlier implementations.
