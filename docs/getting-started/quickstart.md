# Quickstart

This page provides a **minimal reproducible example** to verify that ED2 is correctly
installed and functioning as expected.
The goal is to run a small calculation, confirm that the code executes successfully,
and identify the key output files.

---

## Prerequisites

Before proceeding, ensure that:

- ED2 has been built successfully (see **Installation**),
- the ED2 executable is available in the repository,
- OpenMP environment variables can be set in your shell.

---

## Step 1: Choose a reference input

ED2 ships with example input files located in the `examples/` and/or `input/`
directories of the repository.

For this quickstart, select a **small system** input file, for example:

```text
input/example.in
```

(The exact filename may differ depending on the repository version.
Any minimal test input defining a small spin system is sufficient.)

---

## Step 2: Set OpenMP environment variables

For a first test, use a small number of threads:

```bash
export OMP_NUM_THREADS=2
```

This ensures predictable behavior on most machines.

---

## Step 3: Run ED2

Execute ED2 by redirecting the input file:

```bash
./ed2 < input/example.in
```

If the executable name differs in your build environment, replace `ed2`
with the actual executable name produced during compilation.

---

## Step 4: Check standard output

A successful run typically prints:

- basic information about the Hilbert space,
- solver configuration,
- convergence messages (for iterative solvers),
- final energy values.

The absence of runtime errors or crashes indicates that ED2 is functioning correctly.

---

## Step 5: Inspect output files

After completion, ED2 generates one or more output files in the working directory
(or a subdirectory specified in the input file).

Typical outputs include:

- **Energy eigenvalues** (ground state and possibly excited states),
- **Expectation values** of selected observables,
- **Diagnostic information** related to convergence.

Refer to the **Outputs** section of the documentation for a precise definition
of file formats and column meanings.

---

## Expected results

For a fixed input file, results should be **numerically reproducible**
on the same machine and software environment.

Small floating-point differences may appear when changing:
- compiler,
- BLAS/LAPACK backend,
- number of OpenMP threads.

These differences are expected and should be documented for published results.

---

## Troubleshooting

- **The executable is not found**  
  Ensure that the build step completed successfully and that you are running
  the command from the correct directory.

- **The run is very slow**  
  Reduce system size in the input file or lower `OMP_NUM_THREADS`.

- **Numerical values differ from expectations**  
  Confirm that the input file matches the intended model and that all parameters
  are correctly specified.

---

## Next steps

- Proceed to **Input format** to understand all available input parameters.
- Consult **Examples** for additional reference calculations.
- For scientific use, always record the ED2 commit hash and software environment.
