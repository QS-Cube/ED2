# Verified compiler and BLAS/LAPACK backends

These are tested configurations of **development source**, not a formal release or a promise of universal portability.

| Platform | Compiler / LP64 libraries | Verified evidence |
| --- | --- | --- |
| Ubuntu 24.04 | GNU Fortran 13 + OpenBLAS/LAPACK | [Independent physics, complex BLAS and CSR CI](https://github.com/QS-Cube/ED2/actions/runs/44537916445) |
| Ubuntu 24.04 | GNU Fortran 14 + OpenBLAS/LAPACK | Same [CI](https://github.com/QS-Cube/ED2/actions/runs/44537916445) |
| Debian 13 | GNU Fortran 14.2 + system BLAS/LAPACK | [Full ex9 reproduction](release-qualification.md#completed-two-environment-ex9-audit-19-november-2026) including all nine two-body pairs |
| Ubuntu 24.04 | **Intel ifx 2026.2.0** + **oneMKL 2026.2, sequential LP64** | [ifx CI run #44540286460](https://github.com/ueda1984/ED2/actions/runs/44540286460): 49/49 independent physics at 1 thread, 49/49 at 4 threads, 8/8 native checks, typed ZHEEVR, CSR/dense-H, 12 partial-cache cases, `make distcheck` |

The Intel executable dynamically linked `libmkl_intel_lp64.so.3`,
`libmkl_sequential.so.3` and `libmkl_core.so.3`; no OpenBLAS was used.
Intel test build: `FC=ifx`, `FCFLAGS="-O2 -qopenmp -fp-model precise -qmkl=sequential"`, `--with-lapack=mkl`.

The Intel evidence does **not** cover a new full 1000-site ex9 computation,
ILP64, GPU offload, or other untested CPUs, systems, or scientific inputs.
GNU's two-environment ex9 agreement uses the same numerical implementation,
not an independent implementation.

## Release-source archive integrity (no release is created)

Before naming a public release, freeze and review the target commit.
Run `make distcheck && make dist`, followed by:

```bash
python3 tests/release_archive_preflight.py \
  --archive qs3-ed2-X.Y.Z.tar.gz \
  --json-out source-archive-manifest.json
```

Use the actual archive filename, not `X.Y.Z`. When release metadata is
approved, add `--release-tag vX.Y.Z` to check consistency with `AC_INIT` and
`CITATION.cff`. The script checks required archive member SHA-256 hashes
against the exact tracked Git source. This does not make a tag, assign a DOI,
or substitute for independent numerical regression tests.

See [Release qualification](release-qualification.md) for the full release gate.
