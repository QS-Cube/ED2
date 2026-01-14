# ED2 (QS³-ED2)
**Exact Diagonalization for Quantum Spin Systems**

ED2 (QS³-ED2) is a **Fortran-based Exact Diagonalization (ED) code** designed for
numerical studies of **quantum spin lattice models**.
The code targets **reproducible research**, **shared-memory performance via OpenMP**,
and **long-term usability**, with **Computer Physics Communications (CPC)** as the
primary publication venue.

---

## Key features

- **General quantum spin Hamiltonians**
  - Heisenberg, XYZ-type interactions
  - External magnetic fields
- **Controlled Hilbert-space truncation**
  - Restriction by excitation number (e.g., number of spin-down states)
  - Efficient access to dilute or constrained sectors
- **Numerical solvers**
  - Full diagonalization for very small systems
  - Lanczos-type iterative solvers for larger Hilbert spaces
- **Parallelization**
  - Shared-memory parallelism via **OpenMP**
  - No MPI dependency (single-node execution model)
- **Linear algebra backends**
  - BLAS/LAPACK (OpenBLAS, Intel MKL, or vendor implementations)

---

## Documentation

The **official documentation** is hosted on Read the Docs:

👉 https://ed2.readthedocs.io/en/latest/

The documentation includes:
- Installation instructions
- Quickstart examples
- Complete input/output specifications
- Reproducible reference examples
- Validation and performance benchmarks
- Algorithmic and theoretical background

---

## Requirements

- Linux (x86_64)
- Fortran compiler:
  - GNU Fortran (`gfortran`, GCC ≥ 10 recommended), or
  - Intel oneAPI Fortran (`ifx`)
- BLAS/LAPACK library (OpenBLAS or Intel MKL)
- OpenMP-capable compiler

---

## Quickstart

```bash
git clone https://github.com/QS-Cube/ED2.git
cd ED2
./setup.sh
```

After successful compilation, run a minimal example:

```bash
export OMP_NUM_THREADS=2
./ed2 < input/example.in
```

Refer to the **Quickstart** section in the documentation for a fully reproducible example.

---

## Reproducibility

For published results, users are strongly encouraged to record:
- ED2 version tag or full Git commit hash
- Compiler name and version
- BLAS/LAPACK backend
- OpenMP environment settings
- Input files used for production runs

---

## Citation

If you use ED2 in academic work, please cite it appropriately.

### Before DOI release
```
ED2 (QS³-ED2), QS-Cube/ED2, GitHub repository,
version <tag> or commit <hash>.
```

### After DOI release
A DOI will be provided via Zenodo and should be used for citation.
See the documentation for up-to-date citation instructions.

A `CITATION.cff` file is provided in the repository root to support automated citation.

---

## License

ED2 is released under the **MIT License**.
See the `LICENSE` file for details.

---

## Authors and maintainers

- Hiroshi Ueda
- Daisuke Yamamoto
- Tokuro Shimokawa

---

## Contributing and support

Bug reports and feature requests are welcome via **GitHub Issues**.
Contributions can be made through Pull Requests.

For scientific use, please ensure that all reported results are accompanied by
sufficient information to guarantee reproducibility.
