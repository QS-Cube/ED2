# Input format

This page defines the **input file format** used by ED2.
All calculations are controlled by a plain-text input file, which specifies
the physical model, Hilbert-space constraints, and solver options.

The input format is designed to be:
- human-readable,
- version-stable,
- suitable for long-term reproducibility.

For published results, always archive the exact input file together with the ED2
commit hash and software environment.

---

## General structure

An ED2 input file consists of **keyword–value pairs**, one per line.

```
KEYWORD = value
```

- Keywords are **case-insensitive**.
- Lines starting with `#` are treated as comments.
- Blank lines are ignored.
- Units are dimensionless unless explicitly stated.

---

## Global parameters

| Keyword | Type | Default | Description |
|---|---|---|---|
| `LATTICE_SIZE` | int | required | Number of lattice sites |
| `SPIN_S` | float | required | Spin quantum number (e.g., 0.5, 1.0) |
| `MODEL` | string | required | Model identifier (e.g., Heisenberg, XYZ) |
| `BOUNDARY` | string | `open` | Boundary condition (`open`, `periodic`) |

---

## Hilbert-space control

ED2 allows calculations in either the full Hilbert space or a restricted subspace.

| Keyword | Type | Default | Description |
|---|---|---|---|
| `N_DOWN_MIN` | int | 0 | Minimum number of spin-down excitations |
| `N_DOWN_MAX` | int | LATTICE_SIZE | Maximum number of spin-down excitations |
| `USE_TRUNCATION` | bool | false | Enable truncated Hilbert space |

When truncation is enabled, only basis states satisfying  
`N_DOWN_MIN ≤ N_down ≤ N_DOWN_MAX` are included.

---

## Hamiltonian parameters

### Exchange interactions

| Keyword | Type | Default | Description |
|---|---|---|---|
| `JX` | float | 0.0 | Exchange coupling in x direction |
| `JY` | float | 0.0 | Exchange coupling in y direction |
| `JZ` | float | 0.0 | Exchange coupling in z direction |

### External fields

| Keyword | Type | Default | Description |
|---|---|---|---|
| `HX` | float | 0.0 | Magnetic field along x |
| `HY` | float | 0.0 | Magnetic field along y |
| `HZ` | float | 0.0 | Magnetic field along z |

---

## Solver configuration

| Keyword | Type | Default | Description |
|---|---|---|---|
| `SOLVER` | string | `lanczos` | Solver type (`full`, `lanczos`) |
| `MAX_ITER` | int | 1000 | Maximum number of iterations |
| `TOLERANCE` | float | 1e-10 | Convergence tolerance |
| `NUM_EIGENVALUES` | int | 1 | Number of eigenvalues to compute |

---

## Output control

| Keyword | Type | Default | Description |
|---|---|---|---|
| `OUTPUT_PREFIX` | string | `ed2` | Prefix for output files |
| `WRITE_WAVEFUNCTION` | bool | false | Save eigenvectors |
| `VERBOSE` | bool | false | Verbose output |

---

## Example input file

```text
# Example: Heisenberg chain with L=4, S=1/2

LATTICE_SIZE = 4
SPIN_S = 0.5
MODEL = Heisenberg
BOUNDARY = open

USE_TRUNCATION = true
N_DOWN_MIN = 2
N_DOWN_MAX = 2

JX = 1.0
JY = 1.0
JZ = 1.0
HZ = 0.0

SOLVER = lanczos
NUM_EIGENVALUES = 1
TOLERANCE = 1e-12

OUTPUT_PREFIX = example
VERBOSE = true
```

---

## Validation rules

- Missing required keywords cause a runtime error.
- Inconsistent parameters (e.g., `N_DOWN_MAX < N_DOWN_MIN`) are rejected.
- Unsupported keywords are ignored with a warning.

---

## Reproducibility notes

- Always record the exact input file used.
- Numerical results may depend on solver parameters and truncation choices.
- Changes in defaults across ED2 versions will be documented in the changelog.

---

## Next steps

- See **Outputs** for the definition of generated files.
- See **Examples** for validated reference calculations.
