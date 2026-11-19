# ED2 (QS³-ED2): Exact Diagonalization for Quantum Spin Systems

**ED2 (QS³-ED2)** is a Fortran code for quantum spin lattice calculations.
QS³ stands for **Quantum Spin System Solver**. The code provides dense and
Lanczos-type diagonalization, local magnetizations, and two-site correlations,
with explicit control of the retained basis and spatial symmetries.

Start with [Installation](getting-started/installation.md) to prepare the
compiler and libraries, then follow the [Quickstart](getting-started/quickstart.md)
to run the supplied chain example. The [input reference](user-guide/input-format.md)
and [output reference](user-guide/outputs.md) describe the exact data formats
and numerical checks needed for scientific calculations.

## Physical model and scientific scope

For bonds normalized to the site order $i<j$, the input convention is

$$
\hat H = \sum_{i<j}\left[
\sum_{\alpha=x,y,z}J^\alpha_{ij}\hat S_i^\alpha\hat S_j^\alpha
+\mathbf D_{ij}\cdot(\hat{\mathbf S}_i\times\hat{\mathbf S}_j)
+\sum_{\mathrm{cyc}(\alpha,\beta,\gamma)}
\Gamma^\alpha_{ij}
(\hat S_i^\beta\hat S_j^\gamma+\hat S_i^\gamma\hat S_j^\beta)
\right]
+\sum_i\mathbf h_i\cdot\hat{\mathbf S}_i.
$$

Here the cyclic triples are $(x,y,z)$, $(y,z,x)$, and $(z,x,y)$.
The inputs specify exchange $J$, Dzyaloshinskii–Moriya interactions $D$,
symmetric off-diagonal exchange $\Gamma$, and site-dependent spin magnitudes.
Repeated interaction records contribute additively.

**The field sign is plus: $+\mathbf h\cdot\mathbf S$.** For the physical
Zeeman convention $-\mathbf B\cdot\mathbf S$, supply $\mathbf h=-\mathbf B$.
Reversing a bond's site order reverses its DM vector. See
[Hamiltonian lists and sign conventions](user-guide/input-format.md#hamiltonian-lists-and-sign-conventions)
for the list format and the internal orientation rule.

### Symmetry sectors and truncated spaces

ED2 can restrict the total number of local spin-lowering operations and can
use supplied site-permutation symmetries to reduce the working basis. A fixed
occupation sector is exact only when the Hamiltonian conserves it. With terms
that connect outside the retained space, the calculation instead diagonalizes
$P H P$, where $P$ projects onto that space. Check convergence as the retained
space is enlarged before interpreting a truncated result as a full-system
prediction.

Spatial permutations must preserve the complete Hamiltonian, site spins, and
local occupation caps. A successful run does not establish that an arbitrary
symmetry input is valid. The [algorithm overview](theory/algorithms.md)
explains the basis, solver paths, and verification limits.

## Solvers and execution model

| Facility | Scope |
|---|---|
| `ALG=1` | Conventional Lanczos ground-state calculation |
| `ALG=2` | Thick-restart Lanczos for requested low-lying eigenpairs |
| `ALG=3` | Dense Hermitian diagonalization of the selected space |
| OpenMP | Shared-memory parallelism within one node |
| BLAS/LAPACK | Explicit LP64 Fortran interfaces; a compatible implementation is required |

Dense matrices require storage proportional to the square of the projected
dimension. Iterative solvers require independent convergence checks. The
program has no MPI dependency.

## Current performance features and release scope

Official [`QS-Cube/ED2:main`](https://github.com/QS-Cube/ED2) includes the
general-purpose cache features merged in
[PR #1](https://github.com/QS-Cube/ED2/pull/1) on 19 November 2026:

- ordered complex CSR caching;
- coefficient-certified cache capacity;
- optional release of the padded cache;
- direct two-pass CSR construction.

All four environment controls are **off by default**. Their benefit depends
on the model and available memory. Read
[Hamiltonian caching, performance, and memory](user-guide/performance-and-memory.md)
and [model-specific optimization tips](examples/optimization-tips.md) for
prerequisites, compiler policies, and the distinction between cache-array
payload and whole-process memory.

A merge to `main` is not a tagged release. Verify the source commit used to
build an executable and the Read the Docs build commit when comparing versions.
Separate experimental fork branches are not part of the official feature set
unless their changes have actually been merged.

## Typical workflow

After installing the [required build dependencies](getting-started/installation.md#1-requirements):

```bash
git clone https://github.com/QS-Cube/ED2.git
cd ED2
git rev-parse HEAD
autoreconf -vfi
./configure FC=gfortran FCFLAGS="-O2 -fopenmp"
make -j2
export OMP_NUM_THREADS=1
export OPENBLAS_NUM_THREADS=1
export MKL_NUM_THREADS=1
make check
(cd script_chain && ./run.sh)
head -n 5 examples/chain/eigenvalues.dat
```

`make check` uses a temporary directory, checks nonempty outputs, and requires
a positive state index and finite-number energy syntax on every eigenvalue row. The
explicit script invocation generates the reusable example under
`examples/chain/`. A prepared input can be run from that directory with
`../../source/QS3ED2`; the relative path has two `..` components.

The supplied chain is a restricted-space example. Its successful execution is
an installation check, not a proof that an arbitrary model, symmetry, or
solver setting is correct. The [independent small-system checks](getting-started/installation.md#independent-small-system-physics-checks)
compare against separately constructed NumPy Hamiltonians.

Do not use unqualified `make check-long` as the first installation check: it
includes the large ex9 cubic three-magnon calculation. The installation guide
gives the ex1–ex8 subset and explains what the execution-check wrapper actually
checks.

## Reproducibility and citation

For each scientific result, preserve the exact source commit and local patch,
compiler flags, BLAS/LAPACK implementation, thread counts, all model inputs,
solver diagnostics, and independent reference-check results. Direct runs append
several output tables, so keep results from distinct runs separate.

The [citation and versioning guide](reference/citation-versioning.md)
distinguishes development commits, future tagged releases, software archives,
and journal articles. Contributor metadata is available in
[CITATION.cff](https://github.com/QS-Cube/ED2/blob/main/CITATION.cff).

## License, maintainers, and support

ED2 uses the [MIT License](https://github.com/QS-Cube/ED2/blob/main/LICENSE).
Maintainers listed here are Hiroshi Ueda and Daisuke Yamamoto; citation
metadata lists the software contributors.

Report reproducible problems through [GitHub Issues](https://github.com/QS-Cube/ED2/issues)
with the source revision, build configuration, smallest failing input, and
logs. Contributions can be proposed through pull requests.
