# ED2 Output Files

This page documents the concrete output files produced by QS³‑ED2, using
`examples/chain` as a canonical reference.  The goal is to make each file
interpretable without inspecting the source code.

All physics results are written as plain‑text files and are designed to be
stable across versions for reproducibility.

---

## Example: `examples/chain`

A typical ground‑state calculation with

- `cal_lm = 1`
- `cal_cf = 1`
- eigenvectors disabled

produces:

```
examples/chain/
 ├ input.dat
 ├ eigenvalues.dat
 ├ local_mag.dat
 ├ two_body_cf_xyz.dat
 ├ two_body_cf_z+-.dat
 └ output.dat   (stdout redirect)
```

These correspond to:

- energy eigenvalues
- local magnetization
- two‑body spin correlations (Cartesian)
- two‑body spin correlations (z,+,− representation)
- human‑readable diagnostic log

---

## Overview

ED2 computes eigenstates of an explicitly constructed Hilbert space and
evaluates observables in the lowest‑energy state unless otherwise specified.

Generated files depend on input flags such as:

```
cal_lm
cal_cf
eigvec
```

Physics results are written to dedicated `.dat` files, while solver progress
and configuration are printed to standard output.

---

## Energy Eigenvalues

### File: `eigenvalues.dat`

Lowest energy eigenvalues obtained by full diagonalization, Lanczos, or TRLan.

### Format

| Column | Meaning |
|--------|---------|
| 1 | Eigenstate index (1‑based) |
| 2 | Energy |

Notes:

- Energies are sorted in ascending order.
- The first row corresponds to the ground state.
- Units are identical to the Hamiltonian parameters.

---

## Local Magnetization (`cal_lm = 1`)

### File: `local_mag.dat`

Expectation values of local spin operators in the lowest eigenstate:

```
<S_i^x>, <S_i^y>, <S_i^z>
```

### Format

| Column | Meaning |
|--------|---------|
| 1 | Site index i |
| 2 | <S_i^x> |
| 3 | <S_i^y> |
| 4 | <S_i^z> |

Remarks:

- Values close to zero (≈1e‑8) indicate vanishing moments within numerical
  precision.
- If the Hamiltonian preserves spin symmetry, local moments may vanish even in
  symmetry‑broken phases.

---

## Two‑Body Correlation Functions (`cal_cf = 1`)

ED2 outputs full pairwise spin correlations for all site pairs.

### File: `two_body_cf_xyz.dat`

Cartesian representation:

```
<S_i^α S_j^β>,  α,β ∈ {x,y,z}
```

### Format

| Column | Meaning |
|--------|---------|
| 1 | Site i |
| 2 | Site j |
| 3 | <S_i^x S_j^x> |
| 4 | <S_i^x S_j^y> |
| 5 | <S_i^x S_j^z> |
| 6 | <S_i^y S_j^x> |
| 7 | <S_i^y S_j^y> |
| 8 | <S_i^y S_j^z> |
| 9 | <S_i^z S_j^x> |
|10 | <S_i^z S_j^y> |
|11 | <S_i^z S_j^z> |

This provides the complete 3×3 spin correlation tensor for each pair (i,j).

---

### File: `two_body_cf_z+-.dat`

Mixed longitudinal/transverse representation using

```
S^z, S^+, S^-
```

This file contains correlations such as:

```
<S_i^z S_j^z>, <S_i^z S_j^+>, <S_i^+ S_j^->, ...
```

and is primarily intended for models with Dzyaloshinskii–Moriya interactions,
non‑collinear order, or chiral correlations.

Each row corresponds to a site pair (i,j), followed by all z,+,− combinations.

---

## Standard Output (`output.dat`)

When standard output is redirected, `output.dat` contains:

- model and lattice information
- Hilbert‑space dimension
- solver configuration
- Lanczos / TRLan iteration history
- convergence diagnostics

This file is intended for human inspection and debugging and should not be
parsed programmatically.

---

## Eigenvectors (optional)

If `eigvec = 1`, ED2 writes files of the form:

```
eigenvec_XXXX.dat
```

These contain eigenvector components in the explicit many‑body basis used
internally by ED2.

Notes:

- Basis ordering follows ED2’s internal convention.
- Indices correspond directly to the constructed Hilbert space (no hidden
  symmetry projection).
- Files may become very large and are intended for advanced post‑processing.

---

## Mapping Between Input Flags and Outputs

| Input flag | Generated files |
|------------|-----------------|
| `cal_lm` | `local_mag.dat` |
| `cal_cf` | `two_body_cf_xyz.dat`, `two_body_cf_z+-.dat` |
| `eigvec` | `eigenvec_*.dat` |

---

## Solver‑Dependent Behavior

- Full diagonalization: all requested eigenvalues are exact within numerical
  precision.
- Lanczos / TRLan: eigenvalues are approximate; convergence information is
  reported in standard output.
- Residuals and iteration counts appear only in the solver log.

---

---

## Relationship to `input-format.md` and auxiliary `list_*.dat` files

ED2 itself reads **only** the main NAMELIST input (`input.dat`) from STDIN and any
files referenced by `FILE_*` keys in `input.dat`.  The authoritative specification
of these keys and `list_*.dat` helper files is documented in:

- `docs/user-guide/input-format.md`

In particular, the following inputs control the outputs documented on this page:

| Output file | Controlled by keys in `input.dat` | Reads these auxiliary files (via `FILE_*`) |
|---|---|---|
| `eigenvalues.dat` | `ALG` (and solver blocks) | — |
| `local_mag.dat` | `cal_lm`, `OUTDIR` | `FILE_spin`, `FILE_NODmax` |
| `two_body_cf_xyz.dat` / `two_body_cf_z+-.dat` | `cal_cf`, `NO_two_cf`, `FILE_two_cf`, `OUTDIR` | `FILE_two_cf` (pair list), plus `FILE_spin`, `FILE_NODmax` |
| `eigenvec_*.dat` (optional) | `wr_wf`, `re_wf`, `FILE_wf` | — |
| `output.dat` (stdout redirect) | verbosity / solver settings | — |

> Note on example-specific files  
> Some example directories contain files such as `input_param.dat`. These are
> **not consumed by ED2 directly**; they are typically used by example scripts to
> generate `input.dat` and `list_*.dat` files.  For ED2 runs, the relevant inputs
> are `input.dat` and the referenced `list_*.dat` files.

For details on the meaning and format of each `FILE_*` list (e.g. `FILE_spin`,
`FILE_NODmax`, `FILE_two_cf`, symmetry permutations `FILE_S1..FILE_S6`, and the
Hamiltonian term lists), please consult `input-format.md`.


## Reproducibility Checklist

For published calculations, archive:

- all input files
- all output `.dat` files used in analysis
- ED2 git commit hash
- compiler and BLAS/LAPACK versions
- OpenMP configuration

These records are essential for independent reproduction of numerical results.

---

## Minimal Workflow

1. Prepare `input.dat`
2. Run ED2
3. Inspect `eigenvalues.dat` for ground‑state energy
4. Analyze `local_mag.dat` and `two_body_cf_*.dat`
5. Use `output.dat` to confirm convergence and Hilbert‑space size

---

This documentation reflects the concrete behavior of ED2 as demonstrated in
`examples/chain` and is intended to serve as a practical reference for both
new users and advanced workflows.
