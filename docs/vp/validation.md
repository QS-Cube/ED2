# Validation

This page documents **validation tests** for ED2.
The goal is to demonstrate that ED2 produces correct results by comparing against:

- analytically solvable limits (when available),
- exact results for very small systems,
- independent reference implementations.

For a CPC submission, this section should be kept **versioned and reproducible**:
each validation item should specify the input, execution command, and a quantitative
acceptance criterion.

---

## General validation policy

- Each validation case is defined by an input file and an expected numerical result.
- Unless otherwise noted, validation is performed using:
  - `OMP_NUM_THREADS = 1` (to reduce non-determinism),
  - identical solver tolerances,
  - fixed ED2 commit hash.

### Numerical tolerances

Floating-point results may vary slightly across compilers and BLAS/LAPACK backends.
Therefore, acceptance criteria should be expressed using tolerances, e.g.:

- absolute tolerance: `|E - E_ref| < 1e-10`
- relative tolerance: `|E - E_ref| / |E_ref| < 1e-12`

For iterative solvers, convergence thresholds must be stated explicitly.

---

## Validation case V1: Heisenberg chain (L = 4, S = 1/2)

This is the minimal sanity-check example used throughout the documentation.

### Input
Use the example in the **Examples** section (or an equivalent small-system input).

### Run
```bash
export OMP_NUM_THREADS=1
./ed2 < input/heisenberg_L4.in
```

### Check
- The run completes without error.
- The output file `<OUTPUT_PREFIX>_energies.dat` exists and contains at least one eigenvalue.
- The ground-state energy `E0` is consistent with a trusted reference value.

> **Action item for ED2 maintainers**  
> Once a canonical reference value is chosen (from an exact full diagonalization reference),
> record it here and define the numerical tolerance.

---

## Validation case V2: Full vs truncated Hilbert space consistency (small systems)

For very small systems where the full Hilbert space is tractable, truncation can be validated
by choosing truncation bounds that include the full space.

### Procedure
- Run a small system in the full Hilbert space.
- Run the same system with truncation bounds set to include all basis states.
- Compare the lowest eigenvalues.

### Acceptance criterion
- The lowest `k` eigenvalues match within a specified tolerance.

---

## Validation case V3: Sector checks (if applicable)

If ED2 supports calculations in constrained sectors (e.g., fixed excitation number),
validate that:

- the reported basis size matches the expected combinatorial count,
- sector-restricted results match full-space results when projected appropriately.

---

## Regression testing (recommended)

For sustainable development, ED2 should maintain a small collection of regression tests.

Recommended structure:
- Store validation inputs under `tests/inputs/`
- Store expected results under `tests/reference/`
- Provide a driver script (e.g., Python or shell) that runs ED2 and checks tolerances.

Even a small test suite substantially improves reliability and CPC reviewer confidence.

---

## Next steps

- See **Performance** for benchmarks and scaling studies.
- As the CPC manuscript matures, expand this page with:
  - additional models,
  - convergence studies (Lanczos tolerances vs accuracy),
  - cross-platform comparisons.
