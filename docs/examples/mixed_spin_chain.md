# Mixed‑Spin 1D Chain Example

This example demonstrates how to run **QS³ ED2** for a **mixed‑spin one‑dimensional chain**.
The example is located in

```
examples/mixed_spin_chain/
```

and contains all input and output files required to reproduce the calculation.

Compared with `examples/chain/`, the key difference is that the **local spin quantum number depends on the site**.
In this dataset, the chain alternates between **spin‑3/2** and **spin‑1/2**:

- `list_spin.dat` (first entries): `1.5, 0.5, 1.5, 0.5, 1.5, 0.5, 1.5, 0.5, ...`
- i.e. odd sites: \(S=3/2\), even sites: \(S=1/2\) (50 sites each for \(N=100\)).

Because the local Hilbert space dimension is site‑dependent, this example also provides

- `list_NODmax.dat` (first entries): `3, 1, 3, 1, 3, 1, 3, 1, ...`

which is required to define the basis truncation consistently for each site (see below).

The ground state is computed using the **Lanczos method**, and the program evaluates

- ground‑state energy
- local magnetization
- two‑point spin correlation functions

---

# Model

## Hamiltonian

The Hamiltonian implemented in this example is

$$
H =
\sum_{\langle i,j\rangle}
\left(
J_x S_i^x S_j^x +
J_y S_i^y S_j^y +
J_z S_i^z S_j^z
+ \mathbf{D}\cdot(\mathbf{S}_i \times \mathbf{S}_j)
+ H_\Gamma(i,j)
\right)
+
\sum_i \mathbf{h}\cdot\mathbf{S}_i,
$$

where the symmetric anisotropic interaction is

$$
H_\Gamma(i,j)=
\Gamma_x\left(S_i^y S_j^z + S_i^z S_j^y\right)
+\Gamma_y\left(S_i^z S_j^x + S_i^x S_j^z\right)
+\Gamma_z\left(S_i^x S_j^y + S_i^y S_j^x\right).
$$

**Mixed spins.**
The spin operators \(\mathbf{S}_i\) act on a site‑dependent local Hilbert space with \(S_i\) given by `list_spin.dat`.
(If `list_spin.dat` is present, it overrides the uniform `SPIN` value in `input_param.dat`.)

## Couplings used in this dataset

### Magnetic field

`list_hvec.dat` provides the on‑site field \(\mathbf{h}_i\).
In this example it is uniform:

$$
\mathbf{h} = (-0.1,\,-0.1,\,-0.3).
$$

### Bond interactions

`list_xyz_dm_gamma.dat` specifies the bond list and the couplings for each bond.
In the current `mixed_spin_chain` dataset, the file contains **nearest‑neighbor bonds only** (one block).

Each bond line stores

$$
(i,\,j,\,J_x,\,J_y,\,J_z,\,D_x,\,D_y,\,D_z,\,\Gamma_x,\,\Gamma_y,\,\Gamma_z).
$$

For reference, the first line (bond 1–2) corresponds to

- \(J_x=1,\,J_y=0.8,\,J_z=0.7\),
- \(\mathbf{D}=(0.2,0.1,5)\),
- \(\boldsymbol\Gamma=(0.1,0.3,-0.2)\).


---

# Input files

This directory uses the same core input structure as `examples/chain/`, plus two mixed‑spin specific lists.

## `input_param.dat`

Main runtime parameters (system size, basis truncation, algorithm switches, file names).

Important fields for this example:

- `NOS = 100`: number of sites
- `NODmin`, `NODmax`: truncation of the basis sector (see below)
- `FILE_SPIN = list_spin.dat`
- `FILE_NODMAX = list_NODmax.dat`
- `FILE_S1 = list_p1.dat` (translation mapping)

> Note: `wkdir` in `input_param.dat` is used to locate the working directory from the run script.
> In this documentation we assume you run from `examples/mixed_spin_chain/`.

## `list_spin.dat` (mixed‑spin specific)

A length‑`NOS` list containing the local spin \(S_i\) for each site.

- For spin‑1/2: \(S_i=0.5\) (local dimension \(2S_i+1=2\))
- For spin‑3/2: \(S_i=1.5\) (local dimension \(2S_i+1=4\))

In this dataset, the pattern is alternating \(3/2, 1/2, 3/2, 1/2,\dots\).

## `list_NODmax.dat` (mixed‑spin specific)

A length‑`NOS` list specifying the **maximum number of local “down steps”** allowed at each site.

QS³‑ED2 uses a highest‑weight labeling per site:
\(m_i = S_i, S_i-1, \dots, -S_i\).
Define a non‑negative integer

$$
n_i \equiv S_i - m_i \in \{0,1,\dots,2S_i\}.
$$

Then the code’s “NOD” counter is

$$
\mathrm{NOD} \equiv \sum_i n_i.
$$

`list_NODmax.dat` provides the **site‑wise upper bound** \(n_i \le \mathrm{NODmax}_i\).
For consistency, a common choice is

$$
\mathrm{NODmax}_i = 2S_i,
$$

which is exactly what this dataset uses:
spin‑3/2 sites have `3`, and spin‑1/2 sites have `1`.

Finally, the global sector selection in `input_param.dat` restricts

$$
\mathrm{NODmin} \le \mathrm{NOD} \le \mathrm{NODmax}.
$$

Since \(\sum_i S_i = 100\) in this example, the total magnetization is related by

$$
S^z_\mathrm{tot} = \sum_i m_i = \sum_i S_i - \mathrm{NOD} = 100 - \mathrm{NOD}.
$$

So choosing `NODmin=0` and `NODmax=3` means the calculation is restricted to the near‑fully‑polarized sector
\(S^z_\mathrm{tot} \in [100-3,\,100]\).

## `list_p1.dat` (translation mapping)

This file defines a site permutation used for translational symmetry reduction.

For a uniform spin‑1/2 chain, the one‑site translation is typically used.
For an **alternating mixed‑spin chain**, the smallest translation that preserves the spin pattern is a **two‑site shift**.

In this dataset, `list_p1.dat` implements exactly that:

- \(T(1)=3\), \(T(2)=4\), …, \(T(99)=1\), \(T(100)=2\)

i.e. a translation by **+2 sites (mod N)**.

## Other list files (same role as `examples/chain/`)

- `list_xyz_dm_gamma.dat`: bond list and couplings
- `list_hvec.dat`: on‑site field
- `list_ij_cf.dat`: pairs \((i,j)\) for which two‑point correlators are evaluated

---

# Running the Example

Inside the example directory run

```
../../source/QS3ED2 < input.dat
```

The program prints a detailed execution log to the terminal.
When running the provided scripts, this output is redirected to

```
output.dat
```

---


# Reading `output.dat`

The file `output.dat` contains the main diagnostic information for the run.

## System size and translational symmetry

From the input echo:

```
NOS = 100
L1  = 50
L2 = L3 = L4 = L5 = L6 = 1
```

This corresponds to a **one‑dimensional system**.

- `NOS = 100` : total number of sites
- `L1 = 50` : number of translational unit cells

In this mixed‑spin example, one unit cell contains **two sites**, so

```
50 cells × 2 sites = 100 sites
```

### Translation operator (`FILE_S1`)

The translational symmetry is defined by

```
FILE_S1 = list_p1.dat
```

For this example the mapping is

```
3
4
5
...
100
1
2
```

which corresponds to

T(i)=i+2  (i=1,...,98),   T(99)=1,  T(100)=2.

Thus the spin configuration transforms as

(S1,S2,S3,...,S100) → (S3,S4,S5,...,S100,S1,S2).

This two‑site translation preserves the alternating mixed‑spin pattern.

---

## Hilbert‑space size

`output.dat` reports

```
THS   = 171801
THS(k)= 3438
```

- `THS` is the number of states **before symmetry reduction**
- `THS(k)` is the number of **representative states** after translational symmetry reduction

---

## Lanczos solver

The solver parameters appear as

```
&INPUT_LANCZ
LNC_ENE_CONV = 1.0E-14
MAXITR = 10000
MINITR = 5
ITRINT = 5
/
```

During the calculation the program prints iteration logs such as

```
itr, ene, conv:   5   -2.134389873145227E+00   1.0E+00
itr, ene, conv:  10   -4.899004672179782E+00   5.6E-01
...
itr, ene, conv: 165   -5.652675156567413E+00   3.2E-15
```

The solver finishes with

```
total lanczos step: 165
E_0 = -5.652675156567413E+00
```

---

## Eigenvector quality

The accuracy of the Lanczos eigenvector is checked using

```
<GS| H |GS>  = -5.652675...
|1 - (<GS|H|GS>)^2/<GS|H^2|GS>| = 10E-15 ~ 10E-16
```

The final quantity should be close to machine precision for a well‑converged ground state.

---

# Observables and output files

This example computes the same categories of observables as in `chain.md` (when enabled). See `chain.md` for details.

---

# Summary

This example shows how to run QS³‑ED2 on a **mixed‑spin chain** by supplying:

- `list_spin.dat` to define site‑dependent \(S_i\)
- `list_NODmax.dat` to define consistent site‑wise basis constraints
- a translation mapping (`list_p1.dat`) compatible with the mixed‑spin unit cell (here: 2‑site shift)

All other parts of the workflow (run script, Lanczos solver, and observable outputs) match the standard `chain` example.
