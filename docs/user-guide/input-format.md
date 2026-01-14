# Input format

This page describes the ED2 input file format and documents the most important
parameters required to define a calculation.

> **Note**  
> The exact set of available keys may evolve. For reproducible research, always
> record the ED2 version (tag) or commit hash together with the input file used.

---

## File format and conventions

- ED2 reads the input from **standard input** (STDIN), so you typically run:
  ```bash
  ./ed2 < input/example.in
  ```
- The input consists of `KEY = VALUE` pairs (one per line).
- Blank lines are ignored.
- Lines starting with `#` are treated as comments.

---

## Minimal required parameters (typical)

The minimal set depends on the model, but most calculations specify:

- system size / lattice definition (e.g., `LATTICE_SIZE`)
- model selector (e.g., `MODEL`)
- Hamiltonian parameters (e.g., couplings and fields)
- solver parameters (e.g., `SOLVER`, `NUM_EIGENVALUES`)

See **Examples** for complete reference inputs.

---

## Symmetry specification (recommended)

ED2 can explicitly enforce lattice and internal symmetries and work within a chosen
**symmetry sector**. This reduces the effective Hilbert-space dimension via
block-diagonalization and can dramatically reduce runtime and memory usage.

### Overview

Symmetry handling is configured by enabling one or more symmetry projectors and by
specifying the target quantum numbers / irreducible representations.

The following symmetry classes are supported conceptually in ED2:

- **Translation symmetry (crystal momentum)**: select a momentum sector $k$
- **Point-group symmetry**: select an irrep label of the lattice point group
- **Spin-inversion symmetry**: select even/odd under global spin inversion

> If a symmetry is enabled but the specified quantum number is incompatible with
> the lattice/model settings, ED2 should report an error.

---

### Translation symmetry (momentum sector)

Enable translation symmetry and select a crystal-momentum sector.

**Keys (recommended naming)**
- `USE_TRANSLATION_SYMMETRY = true|false`
- `MOMENTUM_K = <integer>`  
  Momentum sector label. The convention is implementation-dependent, but typically
  $k = 0, 1, ..., L-1$ corresponds to $2\pi k/L$.

**Example**
```text
# Translation symmetry: k-sector
USE_TRANSLATION_SYMMETRY = true
MOMENTUM_K = 0
```

---

### Point-group symmetry

If the lattice admits point-group symmetries (reflections/rotations), ED2 can project
onto a chosen irreducible representation.

**Keys (recommended naming)**
- `USE_POINTGROUP_SYMMETRY = true|false`
- `POINTGROUP_IRREP = <string>`  
  Irrep label (e.g., `A1`, `A2`, `B1`, `B2`, ...), depending on the lattice and the
  implemented symmetry group.

**Example**
```text
# Point-group symmetry: select an irrep label
USE_POINTGROUP_SYMMETRY = true
POINTGROUP_IRREP = A1
```

---

### Spin-inversion symmetry

For models without explicit symmetry-breaking fields, ED2 can exploit global spin inversion
($S_i^z \to -S_i^z$) to split the Hilbert space into even/odd sectors.

**Keys (recommended naming)**
- `USE_SPININVERSION_SYMMETRY = true|false`
- `SPININVERSION_PARITY = +1|-1`  
  `+1` for even, `-1` for odd parity.

**Example**
```text
# Spin-inversion symmetry: even sector
USE_SPININVERSION_SYMMETRY = true
SPININVERSION_PARITY = +1
```

---

## Example: symmetry-enabled input (template)

The following template shows a typical setup where symmetries are enforced in addition to the
model and solver definition.

```text
# Example template (symmetry-enabled)

LATTICE_SIZE = 12
SPIN_S = 0.5
MODEL = Heisenberg
BOUNDARY = periodic

# Symmetries
USE_TRANSLATION_SYMMETRY = true
MOMENTUM_K = 0

USE_POINTGROUP_SYMMETRY = false
# POINTGROUP_IRREP = A1

USE_SPININVERSION_SYMMETRY = true
SPININVERSION_PARITY = +1

# Couplings
JX = 1.0
JY = 1.0
JZ = 1.0

# Solver
SOLVER = lanczos
NUM_EIGENVALUES = 3
TOLERANCE = 1e-12

OUTPUT_PREFIX = heisenberg_L12_k0_pinveven
VERBOSE = true
```

---

## Notes and best practices

- For **periodic boundary conditions**, translation symmetry is often the most effective first choice.
- When combining multiple symmetries, verify that the selected sector is **non-empty** for your system size.
- For publications, always record:
  - symmetry settings (enabled/disabled and quantum numbers),
  - ED2 version/tag or commit hash.

---

## Next steps

- See **Theory / Algorithms** for the conceptual background of symmetry decomposition.
- See **Examples** for fully validated reference inputs.
