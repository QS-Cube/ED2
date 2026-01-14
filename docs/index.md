# ED2 (QS³-ED2): Exact Diagonalization for Quantum Spin Systems

**ED2 (QS³-ED2)** is a Fortran-based Exact Diagonalization (ED) code for quantum spin lattice models, designed for *reproducible* numerical studies and for publication-quality workflows (target: **Computer Physics Communications**).

This documentation is the **official user and developer guide**.  
The primary goal is that a third party can:

1. **Build** the code from source,
2. **Run** a reference example,
3. **Understand** the inputs/outputs,
4. **Cite** the software properly.

---

## Key features (high level)

- **Models**: general spin Hamiltonians (exchange interactions, anisotropies, Zeeman terms, etc.)
- **Hilbert-space control**: truncated subspace based on the number of spin-down (or equivalent) excitations  
  (useful for dilute magnons / constrained sectors)
- **Solvers**: full diagonalization and Lanczos-type iterative solvers (depending on build/config)
- **Parallelism**: OpenMP (thread-level parallelism)
- **Linear algebra**: BLAS/LAPACK backends (OpenBLAS, Intel MKL, vendor libs)

> Detailed, versioned specifications will be provided in:
> **Installation**, **Input format**, **Outputs**, and **Examples**.

---

## Quickstart (minimal)

### 1) Get the code

```bash
git clone https://github.com/QS-Cube/ED2.git
cd ED2
