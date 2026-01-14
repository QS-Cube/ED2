# Installation

This page describes how to build and run **ED2 (QS³-ED2)** from source.

ED2 is written in **Fortran** and uses **OpenMP** for shared-memory parallelism.
Linear algebra operations rely on **BLAS/LAPACK** libraries.

---

## Build overview

ED2 uses **GNU Autotools** (`configure`, `make`) for portable and reproducible builds.
The build system automatically detects available BLAS/LAPACK libraries in common environments.

### Automatic BLAS/LAPACK detection

- **OpenBLAS / netlib BLAS & LAPACK**  
  Detected automatically when available in standard library paths.

- **Intel MKL (recommended on Intel systems)**  
  If the Intel compiler (**ifort**) is used and no standalone BLAS/LAPACK is found,
  ED2 automatically falls back to Intel MKL using the compiler option `-qmkl=parallel`.

This design avoids manual configuration in most HPC environments.

---

## Typical build commands

### GNU compiler + OpenBLAS
```bash
./configure FC=gfortran
make
```

### Intel compiler + automatic MKL fallback
```bash
./configure FC=ifort
make
```

### Explicit MKL selection (optional)
```bash
./configure FC=ifort --with-lapack=mkl
make
```

---

## Notes for HPC systems

On many clusters, BLAS/LAPACK libraries are provided via environment modules.
For example:

```bash
module load openblas
./configure FC=gfortran
```

or

```bash
module load intel-oneapi-mkl
./configure FC=ifort
```

---

## Reproducibility recommendation

For published results, record:
- ED2 version tag or Git commit hash
- Compiler and version
- BLAS/LAPACK backend
- OpenMP thread settings

This information is essential for long-term reproducibility.
