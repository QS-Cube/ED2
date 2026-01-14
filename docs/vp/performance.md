# Performance

This page documents **performance characteristics** of ED2 and provides
recommended benchmarking procedures.
For CPC submissions, performance results should be reproducible and accompanied by:

- hardware description,
- compiler versions,
- BLAS/LAPACK backend,
- OpenMP settings,
- ED2 commit hash.

---

## What to benchmark

ED2 performance depends on:
- Hilbert-space dimension (full vs truncated sectors),
- solver choice (full diagonalization vs iterative methods),
- BLAS/LAPACK backend,
- OpenMP thread count and affinity.

Recommended benchmark metrics:
- wall-clock time for Hamiltonian construction,
- wall-clock time for eigensolver stage,
- peak memory usage,
- scaling with `OMP_NUM_THREADS`.

---

## Benchmarking environment

### Record the following

- CPU model and core count
- RAM size
- OS and kernel version
- Fortran compiler and version
- BLAS/LAPACK backend and version
- ED2 commit hash

### Recommended OpenMP settings

Start with:
```bash
export OMP_NUM_THREADS=<N>
export OMP_PROC_BIND=spread
export OMP_PLACES=cores
```

Avoid oversubscription:
- If BLAS is multi-threaded, set BLAS threads to 1 when using ED2 OpenMP threading,
  or vice versa.

---

## Benchmark procedure (template)

1. Choose a representative input file (system size and model).
2. Fix solver tolerance and number of eigenvalues.
3. Run multiple trials and report the median time.

Example:
```bash
for t in 1 2 4 8 16; do
  export OMP_NUM_THREADS=$t
  /usr/bin/time -p ./ed2 < input/benchmark.in > log_t${t}.txt
done
```

---

## Scaling expectations

- For sufficiently large workloads, ED2 should benefit from increasing thread count.
- Scaling can saturate due to:
  - memory bandwidth limits,
  - BLAS kernel behavior,
  - synchronization overhead,
  - cache/NUMA effects.

For CPC reporting, it is helpful to show:
- speedup vs thread count,
- time breakdown by stage (construction vs solver),
- effects of different BLAS backends.

---

## Representative benchmark table (to be filled)

| System | Solver | Hilbert dim. | Threads | Time (s) | Notes |
|---|---|---:|---:|---:|---|
| (example) | lanczos | (dim) | 1 | (t1) | baseline |
| (example) | lanczos | (dim) | 2 | (t2) |  |
| (example) | lanczos | (dim) | 4 | (t4) |  |

---

## Next steps

- Add at least one benchmark case that matches the CPC manuscript experiments.
- Provide scripts and reference logs to support reproducibility.
- Once stable, consider adding continuous performance tracking (optional).
