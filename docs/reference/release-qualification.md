# Release qualification and large-example validation

ED2 development `main` and Read the Docs `latest` are moving targets. A
successful merge or documentation build does **not** constitute a tagged
software release. Until the maintainers select a release version, cite the
full Git commit used for each calculation.

## Before assigning a release number

1. Freeze a candidate commit and ensure the source tree is clean. Record its
   SHA, compiler/flags, BLAS/LAPACK implementation, operating system, and
   `ED2_*` environment options.
2. Check GNU Fortran 13 and 14 CI, independent small-system physics checks,
   bounds-checked runtime tests, and `make distcheck`. Keep logs and artifacts.
3. Run a fresh, resource-controlled `ex9` calculation, **including both
   two-body correlation files**, or document that the expensive example is not
   yet independently reproduced. `make check` and the regular CI do not
   execute this complete 1000-site workload.
4. Review solver residuals and numerical limitations. Document compiler
   backends that have not actually been exercised (notably Intel/MKL/ifx).
5. Decide the public `vMAJOR.MINOR.PATCH` identifier; update `AC_INIT` in
   `configure.ac` and the `version` field of `CITATION.cff` to match, and enter
   the *actual* release date as `date-released` in `CITATION.cff`. The existing
   `AC_INIT` package number must not be taken as evidence of an issued release.
6. Run `python3 tests/check_release_metadata.py --release-tag vX.Y.Z`, replacing
   the example with the proposed tag, before tagging. Rebuild distribution
   archives; check that `README.md`, `LICENSE`, `CITATION.cff`, examples, and
   offline regression scripts are included.
7. With the appropriate repository permissions, create and publish the
   reviewed tag/release. Confirm that the tag points to the tested commit.
   Build the versioned Read the Docs pages and archive the matching source and
   checksums. Add an actual archival DOI only after issuance; do not cite a
   placeholder Zenodo or journal DOI.

The default `python3 tests/check_release_metadata.py` intentionally checks
for the **unreleased-development** state and ensures that `CITATION.cff`
does not claim an unissued version/date. After the first versioned release,
adapt the mainline CI policy to permit actual published release metadata;
do not keep a development-only guard without review.

## How to complete the 1000-site ex9 verification

The `script_cubic_sp_HB/run.sh` example uses a periodic \(10\times10\times10\)
spin-1/2 Heisenberg lattice, `NODmin=NODmax=3`, three translations and three
reflections, with 9 requested site pairs. The unreduced sector contains
166,167,000 spin configurations; the example's saved reference reports
23,719 representatives in the requested symmetry sector. The expensive
pair-correlation stage is **not** covered by lightweight CI.

Run it in a **fresh source checkout or clean scratch copy** on a compute node,
not on a directory containing valuable past output. Its current example
script clears `eigenvalues.dat` but observable files are opened for append,
so preexisting outputs can invalidate comparisons. From the source root:

```bash
export OMP_NUM_THREADS=4
export OMP_DYNAMIC=FALSE
export OPENBLAS_NUM_THREADS=1
export MKL_NUM_THREADS=1

git rev-parse HEAD
git status --short
(cd script_cubic_sp_HB && ./run.sh) > ex9-run.log 2>&1

python3 tests/verify_ex9.py \
  --actual examples/cubic_sp_HB \
  --json-out ex9-comparison.json
```

The script is CPU/memory intensive. Select the node class, thread count, and
job walltime under the local scheduler's policy; retain scheduler peak RSS,
walltime, stdout/stderr, complete input files, and the resulting
`eigenvalues.dat`, `local_mag.dat`, `two_body_cf_xyz.dat`, and
`two_body_cf_z+-.dat`. A killed, partial, or appended observable file is
**not** a successful result.

The comparison verifies all of the following:

- exactly 1 finite energy, 1000 complete local-magnetization rows, and 9
  rows of each two-body correlation format;
- ordered site/pair identifiers, spin-1/2 operator bounds, vanishing
  transverse one-site magnetizations, and total
  \(\sum_i\langle S_i^z\rangle=1000/2-3=497\);
- agreement between the Cartesian and ladder correlator output formats;
- absolute differences from all archived reference values, with default
  tolerances `1e-7` for energy and `1e-5` for observables (record any
  scientifically justified tolerance changes).

Use `python3 tests/verify_ex9.py` without `--actual` to check **only the
archived reference fixture**. That fast check is suitable for CI, but it
must **not** be described as a new 1000-site calculation or as independent
reproduction of the archived correlation functions. Even a full comparison
to archived outputs needs solver convergence and model validation to support
scientific claims.

If the full calculation is too slow, record the timed-out stage separately.
Optimize or parallelize the pair-correlation measurement only with
corresponding small-system independent-operator tests; do not change the
scientific benchmark or skip `cal_cf=1` merely to obtain a green check.
