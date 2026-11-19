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
4. Review solver residuals and numerical limitations. Treat GNU 13/14
   results and any Intel oneAPI ifx/LP64 oneMKL run as **separate recorded
   configurations**, with compiler versions, link libraries, and audit
   artifacts. An Intel compiler build alone is not a validation of all
   scientific input families; a 1000-site ifx ex9 run is an independent
   optional benchmark.
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
sh tests/run_ex9_reproducibility.sh

# If you already have a completed full run, compare it independently:
python3 tests/verify_ex9.py \
  --actual examples/cubic_sp_HB \
  --legacy-ex9-symmetry-projection \
  --json-out ex9-comparison.json
```

The compute is CPU/memory intensive. The wrapper does not submit a job or
request scheduler resources. It refuses pre-existing outputs to prevent
append contamination, then preserves complete inputs, output files, checksums,
and a run log under a new `ex9-audit-*` directory. Select the node class,
thread count, and job walltime under the local scheduler's policy; retain scheduler peak RSS,
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
- absolute differences from archived reference values (energy tolerance
  `1e-7`, observable tolerance `1e-8`). The legacy ladder +-/-+ entries
  require the explicitly enabled real/even-reflection projection, while
  both the raw and symmetry-projected differences remain reported.

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

## Completed two-environment ex9 audit (19 November 2026)

Full ex9 calculations were completed with unchanged numerical source from
official main commit `63f81c198df6adfa992932e1b7c7fa5c359c8c43`.
The GitHub Actions audit checkout `035d81fa225e2cf362199f3e4b8d1a10a3da4ef2`
differs from main **only** by the audit workflow. Both executions used
GNU Fortran 14, `-O2 -fopenmp`, two OpenMP threads, one BLAS thread and
the supplied 1000-site/three-magnon input:

- Ubuntu 24.04, LP64 OpenBLAS/LAPACK:
  [full ex9 evidence run #44514651378](https://github.com/ueda1984/ED2/actions/runs/44514651378),
  6:50.75 wall-clock elapsed, 140 Lanczos steps;
- Debian/GNU Fortran 14.2, system LP64 BLAS/LAPACK:
  9:45.04 wall-clock elapsed; independently rebuilt from the same archived
  source snapshot.

The first run produced all four numerical output files but its historical
**raw** ladder comparison failed. This is a genuine archived-fixture
inconsistency, **not** an incomplete ex9 calculation. The previous
`calcu_cf` averaged only translation generators 1--3, omitting reflection
generators 4--6. The historical `two_body_cf_z+-.dat` consequently violates
the operator-adjoint identity
`<S^-_i S^+_j> = conj(<S^+_i S^-_j>)`
by as much as `2.7829938541e-5`. For the real, zero-momentum and
even-reflection ex9 state, these values must moreover be equal and real.

The corrected implementation produces Hermitian, real, pair-exchange
symmetric ladder correlations. The historical two channels are projected
**for comparison only** to their common real arithmetic mean, with
imaginary parts set to zero; all historical archive files remain untouched.
The explicit CLI flag
`--legacy-ex9-symmetry-projection` enables this *ex9-specific* projection,
and always records the unsymmetrized raw discrepancy.

| Full output comparison | Maximum absolute discrepancy |
| --- | ---: |
| Ubuntu vs Debian: energy | `6.82e-13` |
| Ubuntu vs Debian: all 1000 local magnetizations | `2.07e-12` |
| Ubuntu vs Debian: Cartesian correlations (9 pairs) | `4.66e-12` |
| Ubuntu vs Debian: ladder correlations (9 pairs) | `9.32e-12` |
| Ubuntu vs raw historical ladder archive | `1.39150e-5` |
| Ubuntu vs **symmetry-projected** historical ladder | `1.89112e-11` |
| Debian vs symmetry-projected historical ladder | `9.59420e-12` |

The matched energy is `736.7224213680655` (sector-specific);
`sum_i <S^z_i>=497`. The new runs are independent builds/environments of
the same code, **not** independent algorithms or independent verification
of every Hamiltonian term. They resolve the ex9 benchmark reproduction
question with the historical reference discrepancy explicitly documented.

The former `examples/ref_data/cubic_sp_HB` directory remains a historical
fixture. Do not overwrite or silently loosen comparisons to make it
appear to match. A future immutable release should separately archive
the newly computed outputs, build logs and source checksums.
