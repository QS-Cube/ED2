# Installation

This page describes how to build and run **ED2 (QS³-ED2)** from source.

ED2 is written in **Fortran** and uses **OpenMP** for shared-memory parallelism.
Dense and sparse linear algebra operations rely on **BLAS/LAPACK** libraries.

For published or archived results, we strongly recommend recording the ED2 **version tag / Git commit hash**,
compiler version, BLAS/LAPACK backend, and OpenMP configuration.

---

## System requirements

### Operating system

- **Linux (x86_64)**  
  ED2 is routinely tested on recent Linux distributions (e.g., Ubuntu 22.04).
  Other UNIX-like systems may work but are not officially supported.

### Compilers

One of the following Fortran compilers is required:

- **GNU Fortran (`gfortran`)** (GCC 10 or later recommended)
- **Intel oneAPI Fortran (`ifx`)**

The code uses standard Fortran and OpenMP directives.

### Parallelization

- **OpenMP** is used for shared-memory parallelism (single-node execution model).

### Linear algebra libraries

A BLAS/LAPACK implementation is required. Supported and tested options include:

- **OpenBLAS** (recommended default)
- **Intel MKL**
- Vendor-provided BLAS/LAPACK implementations

---

## Install dependencies (Ubuntu example)

On Ubuntu/Debian-like systems, you can install a typical toolchain with:

```bash
sudo apt-get update
sudo apt-get install -y build-essential git gfortran libopenblas-dev liblapack-dev
```

If you plan to use Intel MKL, install Intel oneAPI and source the environment script
provided by Intel before building ED2.

> **HPC clusters**  
> On clusters, the required compilers and BLAS/LAPACK libraries are usually provided via environment modules
> (e.g., `module load gcc openblas` or `module load intel-oneapi mkl`). Consult your site documentation.

---

## Getting the source code

Clone the official ED2 repository:

```bash
git clone https://github.com/QS-Cube/ED2.git
cd ED2
```

All examples and input files referenced in this documentation assume execution from the
repository root directory.

---

## Building ED2 (recommended)

ED2 provides a helper script for configuring and building the code.
This is the recommended and supported build procedure.

```bash
./setup.sh
```

The build script typically performs the following tasks:

- selects a Fortran compiler toolchain,
- configures OpenMP flags,
- links against an available BLAS/LAPACK library,
- builds the ED2 executables.

After successful compilation, executables are placed in a predictable location
within the repository (see the script output for details).

> If your environment offers multiple toolchains (e.g., GNU vs Intel), open `setup.sh` and/or follow the
> repository’s build notes to select the intended compiler and BLAS/LAPACK backend.

---

## Manual build (advanced users)

Advanced users may prefer to build ED2 manually by editing the Makefile or build scripts.

### Compiler and OpenMP flags

Typical OpenMP flags are:

- GNU Fortran:
  ```text
  -fopenmp
  ```
- Intel oneAPI Fortran:
  ```text
  -qopenmp
  ```

### BLAS/LAPACK linkage

Example link flags:

- OpenBLAS:
  ```text
  -lopenblas
  ```
- Intel MKL: use Intel’s recommended link line
  (e.g., via `mkl_link_tool` or oneAPI environment scripts).

Consult your system documentation for the correct library paths and link options.

---

## Running ED2

Set the number of OpenMP threads using the `OMP_NUM_THREADS` environment variable:

```bash
export OMP_NUM_THREADS=8
```

Run ED2 by redirecting an input file:

```bash
./ed2 < input/example.in
```

(The exact executable name may depend on the build configuration.)

---

## OpenMP and BLAS thread settings (important)

Many BLAS libraries are multi-threaded. When ED2 uses OpenMP at the application level, it is often best to
**disable BLAS internal threading** to avoid oversubscription.

Typical settings:

- OpenBLAS:
  ```bash
  export OPENBLAS_NUM_THREADS=1
  ```
- Intel MKL:
  ```bash
  export MKL_NUM_THREADS=1
  ```
- Generic:
  ```bash
  export OMP_NUM_THREADS=8
  export OMP_PROC_BIND=spread
  export OMP_PLACES=cores
  ```

Users are encouraged to benchmark different settings for their hardware.

---

## Tested environments

ED2 has been tested on the following representative platforms:

| OS | Compiler | BLAS/LAPACK | Notes |
|---|---|---|---|
| Ubuntu 22.04 | gfortran | OpenBLAS | reference configuration |
| Linux (HPC) | ifx | Intel MKL | performance-oriented setup |

---

## Reproducibility notes

For numerical reproducibility and long-term usability:

- record the ED2 version tag or full Git commit hash,
- record compiler and BLAS/LAPACK versions,
- fix OpenMP thread counts and affinity settings,
- archive input files used for production runs.

These practices are strongly recommended for results reported in publications.

---

## Troubleshooting

### Build fails due to missing BLAS/LAPACK

Ensure that development headers and libraries for your chosen BLAS/LAPACK implementation
are installed and visible to the compiler and linker.

### Poor scaling with OpenMP threads

Check for oversubscription:

- disable multi-threading in BLAS if OpenMP is used at the ED2 level, or
- reduce the number of OpenMP threads.

### Numerical differences across systems

Small floating-point differences may arise from different compilers or BLAS implementations.
Always document the software environment used for production calculations.
