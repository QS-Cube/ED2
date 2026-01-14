# Theory and Algorithms

This page summarizes the **theoretical background and numerical algorithms**
implemented in ED2.
The presentation is intended to be concise, implementation-oriented, and
consistent with the accompanying **Computer Physics Communications (CPC)**
manuscript.

---

## Exact Diagonalization overview

Exact Diagonalization (ED) solves the many-body eigenvalue problem

\[
H |\psi_n\rangle = E_n |\psi_n\rangle
\]

by representing the Hamiltonian \(H\) as a matrix in a chosen basis and
computing its eigenvalues and eigenvectors exactly (up to numerical precision).

The method provides:
- controlled numerical accuracy,
- full access to eigenstates,
- transparent validation for small systems.

Its main limitation is the exponential growth of the Hilbert-space dimension,
which ED2 mitigates through **Hilbert-space truncation** and **iterative solvers**.

---

## Hilbert-space construction

### Local basis

Each lattice site is associated with a local spin basis
\(|m_i\rangle\), where

\[
m_i = -S, -S+1, \ldots, S .
\]

The full Hilbert space for a system of \(L\) sites has dimension

\[
\dim \mathcal{H}_\text{full} = (2S + 1)^L .
\]

---

### Truncated Hilbert space

ED2 supports calculations in a **restricted Hilbert space** defined by
the number of spin-down (or equivalent) excitations.

For spin-1/2 systems, define
\[
N_{\downarrow} = \sum_i \frac{1 - \sigma_i^z}{2}.
\]

The truncated space is defined by bounds

\[
N_{\downarrow}^{\min} \le N_{\downarrow} \le N_{\downarrow}^{\max}.
\]

Only basis states satisfying this condition are included.

#### Motivation

Hilbert-space truncation is particularly effective for:
- dilute magnon problems,
- polarized or near-polarized phases,
- constrained quantum sectors.

This reduces both memory usage and computational cost while preserving
relevant low-energy physics.

---

## Hamiltonian representation

The Hamiltonian is assembled as a sparse matrix in the chosen basis.
Typical terms include:

- exchange interactions:
  \[
  H_J = \sum_{\langle i,j \rangle} (J_x S_i^x S_j^x + J_y S_i^y S_j^y + J_z S_i^z S_j^z),
  \]
- external fields:
  \[
  H_h = \sum_i (h_x S_i^x + h_y S_i^y + h_z S_i^z).
  \]

Matrix elements are generated on-the-fly during Hamiltonian construction.

---

## Eigenvalue solvers

### Full diagonalization

For very small Hilbert spaces, ED2 can perform full diagonalization using
dense linear algebra routines (BLAS/LAPACK).

This approach provides the complete spectrum but scales as

\[
\mathcal{O}(N^3)
\]

in time and \(\mathcal{O}(N^2)\) in memory, where \(N\) is the Hilbert-space dimension.

---

### Lanczos algorithm

For larger systems, ED2 employs **Lanczos-type iterative solvers** to compute
a small number of extremal eigenvalues.

Starting from a normalized random vector \(|v_0\rangle\), the Lanczos
recursion generates an orthonormal basis \(|v_k\rangle\) of the Krylov subspace:

\[
\mathcal{K}_m(H, |v_0\rangle) = \text{span}\{ |v_0\rangle, H|v_0\rangle, \ldots, H^{m-1}|v_0\rangle \}.
\]

In this basis, the Hamiltonian is reduced to a tridiagonal matrix, whose
eigenvalues approximate those of the full Hamiltonian.

#### Convergence

- Extremal eigenvalues (e.g., ground state) typically converge rapidly.
- Convergence depends on:
  - spectral gaps,
  - truncation bounds,
  - numerical tolerance.

---

## Thick-restart Lanczos (if enabled)

To control memory growth and improve numerical stability, ED2 may use
**thick-restart Lanczos** techniques.

Key features:
- retention of a subset of converged Ritz vectors,
- periodic restart of the Krylov basis,
- reduced memory footprint.

Details of restart strategies and parameters are documented in the CPC manuscript.

---

## Parallelization strategy

ED2 uses **OpenMP** for shared-memory parallelism.

Parallel regions typically include:
- Hamiltonian matrix element generation,
- sparse matrix–vector products,
- observable evaluations.

The algorithm is designed for single-node execution with predictable
scaling behavior up to moderate core counts.

---

## Numerical accuracy and stability

Key considerations:
- double-precision arithmetic throughout,
- explicit convergence thresholds for iterative solvers,
- reproducibility controlled via fixed tolerances and thread counts.

Loss of orthogonality in Lanczos iterations is monitored and mitigated
via restart strategies.

---

## Computational complexity

Let \(N\) be the Hilbert-space dimension after truncation.

- Hamiltonian construction: \(\mathcal{O}(N)\) to \(\mathcal{O}(N z)\),
  where \(z\) is the coordination number.
- Lanczos iteration: \(\mathcal{O}(N)\) per iteration.
- Memory usage: dominated by sparse matrix storage and Krylov vectors.

---

## Relation to the CPC manuscript

This documentation page provides a high-level summary.
The CPC article presents:
- formal definitions,
- algorithmic details,
- validation benchmarks,
- performance analysis.

Readers are encouraged to consult the manuscript for a complete description.

---

## Next steps

- See **Validation** for numerical correctness checks.
- See **Performance** for scaling benchmarks.
- See **Examples** for practical applications of these algorithms.
