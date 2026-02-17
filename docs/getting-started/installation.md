# Installation Guide for ED2 (QS³-ED2)

This document describes how to build, test, and run **ED2 (QS³-ED2)**,
a Fortran + OpenMP Exact Diagonalization code for quantum spin systems.

The build system is based on **GNU Autotools** and is designed to be:

- Portable across Linux systems
- HPC-friendly
- Reproducible
- Minimal in external dependencies

---

# 1. Requirements

## Required

- A Fortran compiler (tested with `ifort`, `gfortran`)
- BLAS and LAPACK libraries  
  - OpenBLAS (preferred)
  - Intel MKL (fallback supported)
- GNU Make

## Optional but Recommended

- Intel MKL (for best performance)
- Environment modules on HPC systems

---

# 2. Obtaining the Source Code

Clone the repository:

```bash
git clone https://github.com/QS-Cube/ED2.git
cd ED2
```

---

# 3. Building ED2

The build system uses Autotools.

## Step 1: Generate configuration scripts (if needed)

If building from a fresh clone:

```bash
autoreconf -vfi
```

## Step 2: Configure

```bash
./configure
```

### BLAS/LAPACK Detection

The configuration script attempts the following:

1. OpenBLAS
2. Generic BLAS (`-lblas`, `-llapack`)
3. Intel MKL fallback (`-qmkl=parallel`)

You may manually specify libraries:

```bash
./configure LIBS="-lopenblas"
```

or for MKL:

```bash
./configure LIBS="-qmkl=parallel"
```

---

## Step 3: Compile

```bash
make -j
```

The executable will be created as:

```
source/QS3ED2
```

Note:

- The executable does **not** rely on `PATH`.
- Example scripts resolve the binary via `ED2_EXE` or a relative path.

---

# 4. Running Regression Tests

After building, we strongly recommend running the provided test suites.

## 4.1 Lightweight Smoke Test

Runs Example 1 only:

```bash
make check
```

This test:

- Verifies basic functionality
- Runs quickly
- Is suitable for CI or quick validation

---

## 4.2 Extended Regression Tests

Runs Examples 1–9:

```bash
make check-long
```

This test:

- Executes a broader set of example calculations
- May take longer depending on system size
- Is recommended when validating installation on a new platform

The extended test suite is particularly useful for:

- New HPC environments
- New BLAS/MKL configurations
- Compiler changes

---

# 5. Running ED2 Manually

After building:

```bash
cd script_chain
./run.sh
```

All example scripts:

- Use the already built executable
- Do not rebuild the code
- Do not rely on `PATH`
- Respect the `ED2_EXE` environment variable if set

Example of manual override:

```bash
ED2_EXE=../source/QS3ED2 ./run.sh
```

---

# 6. Threading and Performance

ED2 uses:

- OpenMP (in the main code)
- BLAS/LAPACK threading (depending on library)

To avoid nested threading, we recommend:

```bash
export OMP_NUM_THREADS=1
export OPENBLAS_NUM_THREADS=1
export MKL_NUM_THREADS=1
```

For benchmarking, users may tune these values.

---

# 7. Reproducibility Notes

For numerical reproducibility and long-term usability:

- Record compiler name and version
- Record BLAS/LAPACK library and version
- Record OpenMP thread count
- Record environment variables affecting BLAS
- Record whether `make check` and `make check-long` completed successfully

Floating-point results may vary slightly across compilers and libraries,
but physical quantities should remain consistent within numerical precision.

---

# 8. Cleaning the Build

To remove build artifacts:

```bash
make clean
```

To remove configuration files:

```bash
make distclean
```

---

# 9. Installing (Optional)

ED2 does not require installation for normal usage.

However, if desired:

```bash
make install
```

(Default installation prefix may be changed via `./configure --prefix=...`.)

---

# 10. Troubleshooting

## BLAS not detected

Specify manually:

```bash
./configure LIBS="-lopenblas"
```

or

```bash
./configure LIBS="-qmkl=parallel"
```

---

## OpenMP issues

Ensure compiler supports OpenMP:

- ifort: enabled by default
- gfortran: may require `-fopenmp`

---

## Test failures

If `make check-long` fails:

1. Ensure build completed successfully.
2. Confirm threading variables are set to 1.
3. Verify BLAS/LAPACK linkage.
4. Rebuild from clean state:

```bash
make distclean
autoreconf -vfi
./configure
make -j
make check-long
```

---

# 11. Citation

If you use ED2 in published work, please cite the accompanying CPC manuscript.

(Full citation information will be provided in the repository README.)

---

# 12. License

See `LICENSE` file in the repository.

---

# Summary

Typical usage workflow:

```bash
git clone ...
cd ED2
autoreconf -vfi
./configure
make -j
make check
make check-long
```

ED2 is designed to be portable, reproducible, and suitable for HPC environments while maintaining minimal external dependencies.
