# Examples

This section provides **fully reproducible reference examples** using ED2.
Each example specifies the input file, execution command, and expected outputs,
and can be used both as a tutorial and as a validation reference.

---

## Example 1: Heisenberg spin-1/2 chain (L = 4)

This example demonstrates a minimal Exact Diagonalization calculation
for a one-dimensional spin-1/2 Heisenberg chain with open boundary conditions.

The system size is intentionally small so that results can be easily
checked and reproduced on any machine.

---

### Physical model

- Model: Heisenberg spin chain
- Spin quantum number: S = 1/2
- Number of sites: L = 4
- Boundary condition: open
- Exchange couplings:
  - Jx = Jy = Jz = 1.0
- External magnetic field: zero

---

### Input file

Create the following input file (for example, `input/heisenberg_L4.in`):

```text
# Heisenberg spin-1/2 chain, L = 4

LATTICE_SIZE = 4
SPIN_S = 0.5
MODEL = Heisenberg
BOUNDARY = open

USE_TRUNCATION = false

JX = 1.0
JY = 1.0
JZ = 1.0

SOLVER = lanczos
NUM_EIGENVALUES = 1
TOLERANCE = 1e-12

OUTPUT_PREFIX = heisenberg_L4
VERBOSE = true
```

---

### Execution

Run ED2 from the repository root directory:

```bash
export OMP_NUM_THREADS=2
./ed2 < input/heisenberg_L4.in
```

---

### Expected results

After successful execution, the following files should be generated:

- `heisenberg_L4_energies.dat`
- `heisenberg_L4_observables.dat` (if observables are enabled)

For the isotropic Heisenberg chain with L = 4 and open boundaries,
the ground-state energy should be approximately:

```
E0 ≈ -1.616
```

(The exact value may differ slightly depending on numerical precision
and solver configuration.)

---

### Interpretation

- The negative ground-state energy indicates antiferromagnetic correlations.
- For such a small system, the full Hilbert space is tractable, and
  truncation is not required.
- This example serves as a sanity check for correct compilation and execution.

---

### Reproducibility notes

For this example, full numerical reproducibility is expected when using:
- the same ED2 commit hash,
- the same compiler and BLAS/LAPACK backend,
- identical solver parameters.

Small floating-point differences may appear across different environments.

---

## Next steps

- Modify the input file to change system size or coupling constants.
- Enable Hilbert-space truncation to explore constrained sectors.
- Proceed to **Validation and Performance** for systematic benchmarks.
