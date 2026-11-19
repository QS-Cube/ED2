# Quickstart

This walkthrough builds ED2, runs its chain example, and locates the generated
results. Use a fresh checkout and keep the parent shell at the repository root.
See [Installation](installation.md) for compiler/library details and optional
installation into a prefix.

## 1. Install prerequisites and build

On Debian/Ubuntu with GNU Fortran:

```bash
sudo apt-get update
sudo apt-get install git build-essential gfortran autoconf automake libopenblas-dev liblapack-dev
git clone https://github.com/QS-Cube/ED2.git
cd ED2
git rev-parse HEAD
autoreconf -vfi
./configure FC=gfortran FCFLAGS="-O2 -fopenmp"
make -j2
```

On a managed cluster, use the administrator's matching compiler and LP64
BLAS/LAPACK modules instead of the package-install commands. The executable is
`source/QS3ED2`; the example generators are built in the `script_*` directories.
Record the commit hash and compiler flags printed or used above.

## 2. Set threads and run the smoke test

```bash
export OMP_NUM_THREADS=1
export OPENBLAS_NUM_THREADS=1
export MKL_NUM_THREADS=1
make check
```

Expected harness output includes:

```text
PASS: test_ex1.sh
```

This checks that the example finishes, creates nonempty output files, and
writes a positive state index and finite-number energy syntax in every
eigenvalue row. It runs in a temporary directory, so it does not leave
`examples/chain/` behind.
A pass is a basic execution check; it does not by itself certify energies,
convergence, or the correctness of a different model.

## 3. Generate and run the chain example

From the repository root:

```bash
(cd script_chain && ./run.sh)
head -n 5 examples/chain/eigenvalues.dat
```

The subshell keeps subsequent commands at the repository root and gives
`mk_input` the directory it needs to read `fort.30`. The script uses the already
built binaries and writes the calculation under `examples/chain/`.

| File | What to inspect |
|---|---|
| `examples/chain/input.dat` | Selected solver, occupation window, symmetry, and file paths |
| `examples/chain/output.dat` | Echoed input, basis size, cache setup, and solver diagnostics |
| `examples/chain/eigenvalues.dat` | State index in column 1; energy in column 2 |
| `examples/chain/local_mag.dat` | Site index and the three local spin components |
| `examples/chain/two_body_cf_xyz.dat` | Requested site pairs and nine Cartesian correlations |

The supplied chain is a 100-site example with a restricted excitation window,
not the full `2^100` Hilbert space. Read the [chain example](../examples/chain.md)
and [input conventions](../user-guide/input-format.md) before changing its
Hamiltonian or symmetry parameters. In particular, input fields enter as
`+h.S`; use `h=-B` for a physical Zeeman term `-B.S`.

Energy and observable tables are appended by direct solver runs. The script
clears the energy table but retains earlier observable records. Preserve the
first run and choose a fresh output directory for an independent calculation;
see [Outputs](../user-guide/outputs.md).

## 4. Validate numerical results on small models

An independent NumPy reference test is available in the source tree. On
Debian/Ubuntu, install its optional dependencies and run:

```bash
sudo apt-get install python3 python3-numpy
python3 tests/audit_physics_regression.py \
  --exe "$PWD/source/QS3ED2" \
  --output "$PWD/physics-validation" \
  --with-iterative --field-cache-variants
```

Use an output directory that does not already exist. Inspect `summary.json`
and the per-case logs. This checks the tested small Hamiltonians against an
independent construction, including iterative and cache paths. For a new
scientific calculation, also check the chosen model's symmetries, truncation,
and convergence; those conditions cannot be established by the installation
smoke test.

## 5. Optional: the ex1–ex8 execution suite

```bash
make -C tests check-long \
  LONG_TESTS="test_ex1.sh test_ex2.sh test_ex3.sh test_ex4.sh test_ex5.sh test_ex6.sh test_ex7.sh test_ex8.sh"
```

The wrapper checks output presence and validates both columns of every
eigenvalue row; its reported `E0` comes from the second column. These are
execution and finite-format checks, not agreement with reference energies.
Retain its logs together with the independent checks above. The installation
guide also provides [bounds-checked I/O and basis tests](installation.md#bounds-checked-io-and-basis-checks).

The unqualified `make check-long` also runs ex9, a 1000-site cubic
three-magnon workload. Schedule that separately after reviewing its
[resource requirements and validation limits](../examples/cubic_sp_HB.md).
