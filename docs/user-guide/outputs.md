# ED2 Output Files

This page documents the concrete output files produced by QS³-ED2,
using `examples/chain` as a canonical reference.

All physics quantities are written in plain-text format and are intended
to be stable across versions for reproducibility.

---

## Example: `examples/chain`

A typical ground-state calculation with

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
- two-body spin correlations (Cartesian basis)
- two-body spin correlations ($z,+,-$ basis)
- human-readable diagnostic log

---

## Overview

ED2 constructs the many-body Hilbert space explicitly and computes
eigenstates of the Hamiltonian.  Unless otherwise specified, observables
are evaluated in the lowest-energy eigenstate.

Generated files depend on input flags such as

$$
\texttt{cal\_lm},\quad
\texttt{cal\_cf},\quad
\texttt{wr\_wf}.
$$

The detailed specification of all input keys and auxiliary files
(`FILE_*`, `list_*.dat`) is given in `input-format.md`.

---

## Energy Eigenvalues

### File: `eigenvalues.dat`

This file contains the computed energy eigenvalues.

### Format

| Column | Meaning |
|--------|---------|
| 1 | Eigenstate index (1-based) |
| 2 | Energy $E_n$ |

Properties:

- Energies are sorted in ascending order:
  
  $$
  E_1 \le E_2 \le \cdots
  $$

- The first row corresponds to the ground state $E_1$.
- Units are identical to the Hamiltonian parameters.

---

## Local Magnetization (`cal_lm = 1`)

### File: `local_mag.dat`

This file contains expectation values of local spin operators
evaluated in the lowest eigenstate:

$$
\langle S_i^x \rangle,\quad
\langle S_i^y \rangle,\quad
\langle S_i^z \rangle.
$$

### Format

| Column | Meaning |
|--------|---------|
| 1 | Site index $i$ |
| 2 | $\langle S_i^x \rangle$ |
| 3 | $\langle S_i^y \rangle$ |
| 4 | $\langle S_i^z \rangle$ |

Remarks:

- Values of order $\sim 10^{-8}$ indicate vanishing moments
  within numerical precision.
- If the Hamiltonian preserves spin symmetry, local moments may vanish
  even in symmetry-broken phases due to finite-size effects.

---

## Two-Body Correlation Functions (`cal_cf = 1`)

ED2 evaluates pairwise spin correlations for all site pairs specified
in the pair list file (see `FILE_two_cf` in `input-format.md`).

### File: `two_body_cf_xyz.dat`

This file contains the full Cartesian correlation tensor

$$
\langle S_i^\alpha S_j^\beta \rangle,
\qquad \alpha,\beta \in \{x,y,z\}.
$$

### Format

| Column | Meaning |
|--------|---------|
| 1 | Site $i$ |
| 2 | Site $j$ |
| 3 | $\langle S_i^x S_j^x \rangle$ |
| 4 | $\langle S_i^x S_j^y \rangle$ |
| 5 | $\langle S_i^x S_j^z \rangle$ |
| 6 | $\langle S_i^y S_j^x \rangle$ |
| 7 | $\langle S_i^y S_j^y \rangle$ |
| 8 | $\langle S_i^y S_j^z \rangle$ |
| 9 | $\langle S_i^z S_j^x \rangle$ |
|10 | $\langle S_i^z S_j^y \rangle$ |
|11 | $\langle S_i^z S_j^z \rangle$ |

Thus each row represents the full $3\times3$ spin correlation tensor
for a fixed pair $(i,j)$.

---

### File: `two_body_cf_z+-.dat`

This file expresses correlations in the basis

$$
S^z,\quad S^+,\quad S^-,
$$

where

$$
S^\pm = S^x \pm i S^y.
$$

It contains matrix elements such as

$$
\langle S_i^z S_j^z \rangle,\quad
\langle S_i^z S_j^+ \rangle,\quad
\langle S_i^+ S_j^- \rangle,\quad \text{etc.}
$$

This representation is particularly useful for:

- models with Dzyaloshinskii–Moriya interactions,
- non-collinear magnetic order,
- chiral correlations.

Each row corresponds to a site pair $(i,j)$,
followed by all $z,+,-$ operator combinations.

---

## Eigenvectors (optional)

If

$$
\texttt{wr\_wf} = 1,
$$

ED2 writes files of the form

```
eigenvec_XXXX.dat
```

containing eigenvector components in the explicit many-body basis.

Let $\{ |b_k\rangle \}$ denote the internally constructed basis.
The eigenvector is written as

$$
|\psi_n\rangle = \sum_k c_k^{(n)} |b_k\rangle.
$$

Notes:

- Basis ordering follows ED2’s internal convention.
- Indices correspond directly to the constructed Hilbert space
  (no hidden symmetry projection).
- Files may become very large for large Hilbert spaces.

---

## Standard Output (`output.dat`)

When standard output is redirected, `output.dat` contains:

- model and lattice information,
- Hilbert-space dimension $\dim \mathcal{H}$,
- solver configuration,
- Lanczos / TRLan iteration history,
- convergence diagnostics.

This file is intended for human inspection and debugging.

---

## Mapping Between Input Flags and Outputs

| Input flag | Generated files |
|------------|-----------------|
| `cal_lm = 1` | `local_mag.dat` |
| `cal_cf = 1` | `two_body_cf_xyz.dat`, `two_body_cf_z+-.dat` |
| `wr_wf = 1`  | `eigenvec_*.dat` |

The precise definitions of `FILE_spin`, `FILE_NODmax`,
`FILE_two_cf`, and other auxiliary input files are given in
`input-format.md`.

---

## Reproducibility Checklist

For published calculations, archive:

- all input files (`input.dat` and referenced `list_*.dat`),
- all output `.dat` files used in analysis,
- ED2 git commit hash,
- compiler and BLAS/LAPACK versions,
- OpenMP configuration.

These records ensure that numerical results can be independently reproduced.

---

## Minimal Workflow

1. Prepare `input.dat` and required `list_*.dat` files.
2. Run ED2.
3. Inspect `eigenvalues.dat` for ground-state energy $E_1$.
4. Analyze
   $$
   \langle S_i^\alpha \rangle
   \quad\text{and}\quad
   \langle S_i^\alpha S_j^\beta \rangle
   $$
   using the corresponding output files.
5. Verify convergence using `output.dat`.
