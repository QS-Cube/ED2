# Quickstart

This page demonstrates the **fastest fully reproducible workflow** to verify that QS³-ED2
builds and runs correctly on your system.

The objective is deliberately minimal:

- build the code,
- execute a reference calculation,
- confirm successful output.

Conceptual background, design philosophy, and citation information are documented on the main documentation home page.

---

## 1. Clone and build

```bash
git clone https://github.com/QS-Cube/ED2.git
cd ED2
autoreconf -vfi
./configure
make -j
```

This produces the executable:

```
source/QS3ED2
```

The binary is intentionally **not installed into PATH**.
All example scripts resolve it explicitly to avoid environment-dependent failures on HPC systems.

---

## 2. Run the smoke test

```bash
make check
```

This executes a minimal reference calculation and verifies basic functionality.

Expected result:

```
PASS: test_ex1.sh
```

If this passes, the core solver, BLAS/LAPACK linkage, and OpenMP configuration are working.

---

## 3. Run a full example manually

Move to the chain example:

```bash
cd script_chain
./run.sh
```

This performs a small Exact Diagonalization calculation and prints:

- solver configuration,
- convergence information,
- eigenvalues,
- local magnetization,
- selected correlation functions.

Output files such as:

```
eigenvalues.dat
local_mag.dat
two_body_cf_xyz.dat
```

are generated in the working directory.

Important properties of the example scripts:

- no recompilation occurs,
- the executable is resolved explicitly,
- PATH is never used,
- helper programs are built at `make` time only.

These choices ensure reproducible execution on shared HPC environments.

---

## 4. Optional: extended regression suite

```bash
make check-long
```

Runs all reference examples sequentially.

Recommended after:

- moving to a new machine or cluster,
- changing compiler,
- changing BLAS / MKL backend.

---

## 5. Thread control (recommended)

QS³-ED2 uses OpenMP in the main solver and threaded BLAS/LAPACK libraries.
To avoid nested parallelism during validation runs:

```bash
export OMP_NUM_THREADS=1
export OPENBLAS_NUM_THREADS=1
export MKL_NUM_THREADS=1
```

Users may later tune these values for performance benchmarking.
