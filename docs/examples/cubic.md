# cubic

## 1. Scientific Purpose

This example serves as a reference implementation of a specific lattice and Hamiltonian
within QS³-ED2. It demonstrates:

- explicit Hilbert-space construction
- symmetry reduction (representative states)
- Lanczos ground-state computation
- observable evaluation (local and two-body correlations)
- memory tuning via MNTE

---

## 2. Model & Lattice Interpretation

The Hamiltonian is constructed from the files:

- `list_xyz_dm_gamma.dat`
- `list_hvec.dat`
- `list_spin.dat`

The general form is

$$
H = \sum_{\langle i,j angle} 
\left(
J^{lpha}_{ij} S_i^{lpha} S_j^{lpha}
+ D^{lpha}_{ij} (S_i 	imes S_j)^{lpha}
+ \Gamma^{lphaeta}_{ij} S_i^{lpha} S_j^{eta}
ight)
+ \sum_i \mathbf{h}_i \cdot \mathbf{S}_i.
$$

Inspect the above files to identify the specific couplings used in this example.

---

## 3. Directory Contents

- `eigenvalues.dat`
- `input.dat`
- `input_param.dat`
- `list_NODmax.dat`
- `list_hvec.dat`
- `list_ij_cf.dat`
- `list_p1.dat`
- `list_p2.dat`
- `list_p3.dat`
- `list_spin.dat`
- `list_xyz_dm_gamma.dat`
- `local_mag.dat`
- `output.dat`
- `two_body_cf_xyz.dat`
- `two_body_cf_z+-.dat`


---

## 4. How to Run

From inside:

```
cd examples/cubic
../../QS3ED2.exe < input.dat
```

---

## 5. What to Verify

After execution, inspect:

### (a) Hilbert-space size

`output.dat` reports:

- THS (raw dimension)
- THS(k) (symmetry-reduced dimension)

Check consistency with expected combinatorics.

---

### (b) Lanczos Convergence

Confirm that:

$$
|E^{(n)} - E^{(n-1)}| < \epsilon
$$

and that the eigenvector quality measure

$$
\delta =
\left|
1 - rac{\langle GS|H|GSangle^2}
         {\langle GS|H^2|GSangle}
ight|
$$

is numerically negligible.

---

### (c) Physical Observables

If `cal_lm = 1`:

- Inspect `local_mag.dat`
- Verify expected symmetry behavior

If `cal_cf = 1`:

- Inspect full correlation tensor
$$
C_{ij}^{lphaeta} = \langle S_i^{lpha} S_j^{eta} angle.
$$

---

## 6. Memory & Performance

Check:

```
Optimal MNTE = ...
```

For large systems, tuning MNTE close to the optimal value reduces memory usage.

---

## 7. Scaling Considerations

For spin-1/2 systems:

$$
\dim(\mathcal{H}) = 2^N
$$

In fixed $S^z$ sector:

$$
\dim(\mathcal{H}_M) = inom{N}{N/2 + M}.
$$

Lanczos complexity approximately scales as:

$$
\mathcal{O}(N_{itr} 	imes N_{nz}).
$$

---

## 8. Reproducibility Notes

For publication-grade runs, archive:

- all input files
- all generated outputs
- ED2 git commit hash
- compiler and BLAS/LAPACK versions
- OpenMP thread count

---

This example provides a validated reference configuration for QS³-ED2.
