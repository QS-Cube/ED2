# Theory and Algorithms

This page summarizes the theoretical background and numerical algorithms implemented in ED2.

---

## Exact Diagonalization overview

Exact Diagonalization (ED) solves the many-body eigenvalue problem

$$
H |\psi_n\rangle = E_n |\psi_n\rangle
$$

by representing the Hamiltonian $H$ as a matrix in a chosen basis and computing its eigenvalues
and eigenvectors exactly (up to numerical precision).

---

## Hilbert-space construction

### Local basis

Each lattice site is associated with a local spin basis $|m_i\rangle$, where

$$
m_i = -S, -S+1, \ldots, S .
$$

The full Hilbert space for a system of $L$ sites has dimension

$$
\dim \mathcal{H}_{\mathrm{full}} = (2S + 1)^L .
$$

---

## Symmetry decomposition

ED2 explicitly exploits **lattice and internal symmetries** to decompose the Hilbert space
into independent symmetry sectors. Calculations are performed within selected sectors,
leading to block-diagonal Hamiltonian matrices and substantial reductions in computational cost.

### Translation symmetry

For translationally invariant lattices with periodic boundary conditions, ED2 can enforce
translation symmetry and work in fixed **crystal-momentum sectors**.
Basis states are classified according to their momentum quantum number $k$, and only states
belonging to the selected momentum sector are retained.

This symmetry reduces the effective Hilbert-space dimension by approximately a factor of the
number of lattice sites.

### Point-group symmetries

If the lattice geometry admits point-group symmetries (e.g., reflections or rotations),
ED2 can project the Hilbert space onto irreducible representations of the corresponding
point group.

This allows further block-diagonalization of the Hamiltonian and facilitates the
classification of eigenstates by symmetry.

### Spin-inversion symmetry

For spin-$1/2$ systems without explicit symmetry-breaking fields, ED2 can exploit
**spin-inversion symmetry**, defined by simultaneous inversion of all spins
($S_i^z \rightarrow -S_i^z$).

The Hilbert space is decomposed into even and odd spin-inversion sectors, which can be
treated independently.

---

## Truncated Hilbert space

In addition to symmetry decomposition, ED2 supports calculations in a **restricted Hilbert space**
defined by the number of spin-down (or equivalent) excitations.

For spin-$1/2$ systems, define

$$
N_{\downarrow} = \sum_i \frac{1 - \sigma_i^z}{2} .
$$

The truncated space is defined by bounds

$$
N_{\downarrow}^{\min} \le N_{\downarrow} \le N_{\downarrow}^{\max} .
$$

Only basis states satisfying these conditions are included.

---

## Hamiltonian representation

The Hamiltonian is assembled as a sparse matrix in the chosen symmetry-adapted basis.
Matrix elements are generated on-the-fly during Hamiltonian construction.

Typical Hamiltonian terms include exchange interactions and external fields.

---

## Eigenvalue solvers

### Full diagonalization

For very small Hilbert spaces, ED2 can perform full diagonalization using dense
BLAS/LAPACK routines.

### Lanczos algorithm

For larger systems, ED2 employs Lanczos-type iterative eigensolvers to compute a small number
of extremal eigenvalues within a given symmetry sector.

---

## Computational considerations

By combining symmetry decomposition, Hilbert-space truncation, and iterative solvers,
ED2 enables calculations that would otherwise be infeasible in the full Hilbert space.

---

## Relation to the CPC manuscript

This section corresponds to the algorithmic description presented in the accompanying
journal manuscript.
