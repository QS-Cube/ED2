# ED2 (QS³-ED2): Exact Diagonalization for Quantum Spin Systems

**ED2 (QS³-ED2)** is a Fortran-based Exact Diagonalization (ED) code for quantum spin lattice models.
It is designed for **reproducible numerical studies** and **high-performance shared-memory execution**
using OpenMP.

This documentation serves as the **official user and developer guide** for ED2.

The primary goal of this documentation is to ensure that any third party can:

1. **Build** the code from source,
2. **Run** reference calculations,
3. **Understand** all inputs and outputs,
4. **Reproduce** published results,
5. **Cite** the software unambiguously.

---

## Overview

Exact Diagonalization remains one of the most reliable and transparent numerical approaches
for strongly correlated quantum many-body systems.
ED2 focuses on **spin lattice models** and provides a flexible framework to explore ground states,
low-energy excitations, and physical observables within well-defined Hilbert spaces.

The code supports both full Hilbert spaces and **restricted (truncated) subspaces**, enabling
efficient calculations for dilute excitations or constrained quantum sectors.

---

## Key features

- **Explicit symmetry-resolved Hilbert spaces**  
  Translation symmetry (crystal momentum), point-group symmetries, and spin-inversion symmetry
  can be enforced explicitly, allowing calculations to be performed within well-defined
  symmetry sectors. This enables block-diagonalization of the Hamiltonian and significantly
  reduces computational cost and memory usage.

- **General spin Hamiltonians**  
  Exchange interactions, anisotropies, external fields, and related terms.

- **Controlled Hilbert-space truncation**  
  Calculations can be restricted to sectors with a specified number of spin-down
  (or equivalent) excitations, substantially reducing memory and computational cost.

- **Solvers**
    - Full diagonalization (small systems)
    - Iterative eigensolvers (Lanczos-type methods), depending on build configuration

- **Parallelization**
    - Shared-memory parallelism via **OpenMP**

- **Linear algebra backends**
    - BLAS/LAPACK via **OpenBLAS**, **Intel MKL**, or vendor libraries

---

## Typical workflow

A typical ED2 workflow consists of:

1. Installing required compilers and linear algebra libraries,
2. Building ED2 from source,
3. Preparing an input file defining the model, symmetries, and Hilbert-space constraints,
4. Running the ED2 executable,
5. Analyzing energies and physical observables from output files.

Each step is documented explicitly in this manual.

---

## Documentation structure

The documentation is organized as follows:

- **Getting Started**
    - Installation: build requirements and compilation procedures
    - Quickstart: a minimal reproducible example

- **User Guide**
    - Input format: complete description of all input parameters
    - Outputs: definition of output files, columns, and physical quantities

- **Examples**
    - Reproducible reference calculations

- **Theory and Algorithms**
    - Hilbert-space construction, symmetry decomposition, and truncation
    - Numerical solvers and computational complexity

- **Validation and Performance**
    - Cross-checks against known results
    - Scaling and performance benchmarks

- **Development and Reference**
    - Contribution guidelines
    - Citation and versioning policy

---

## Citation

A dedicated journal manuscript describing ED2 is in preparation.

Until an official DOI is available, please cite ED2 using a **release tag or commit hash**:

> ED2 (QS³-ED2), QS-Cube/ED2, GitHub repository, commit `<hash>`.

A `CITATION.cff` file is provided in the repository to facilitate automated citation.

---

## License

ED2 is released under the **MIT License**.
See the `LICENSE` file in the repository for details.

---

## Authors and maintainers

- Hiroshi Ueda  
- Daisuke Yamamoto  
- Tokuro Shimokawa  

---

## Support and contributions

Bug reports, feature requests, and contributions are welcome.

- Issue tracker: GitHub Issues
- Contributions: Pull Requests

For scientific use, please ensure that all results are accompanied by sufficient
information to guarantee reproducibility (software version, compiler, and library details).
