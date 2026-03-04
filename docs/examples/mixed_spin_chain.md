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
This file contains **two blocks**:

1. **Nearest‑neighbor (J1) bonds**: \((i,i+1)\) including \((N,1)\)
2. **Next‑nearest‑neighbor (J2) bonds**: \((i,i+2)\) including \((N,2)\) and \((N-1,1)\)

Each bond line stores

$$
(i,\,j,\,J_x,\,J_y,\,J_z,\,D_x,\,D_y,\,D_z,\,\Gamma_x,\,\Gamma_y,\,\Gamma_z).
$$

For reference, the first line of each block corresponds to

- **J1 block** (bond 1–2):
  \(J_x=1,\,J_y=0.8,\,J_z=0.7\),
  \(\mathbf{D}=(0.2,0.1,5)\),
  \(\boldsymbol\Gamma=(0.1,0.3,-0.2)\).
- **J2 block** (bond 1–3):
  \(J_x=0.5,\,J_y=0.4,\,J_z=0.35\),
  \(\mathbf{D}=(0.1,0.05,2.5)\),
  \(\boldsymbol\Gamma=(0.05,0.15,-0.1)\).

> If you want a pure nearest‑neighbor model, simply remove the second block (or comment it out by deleting those lines)
> and adjust `NO_TWO` / bond counting accordingly in your workflow.

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

# Running the example

The run procedure (build, set executable path, run script) is the same as `examples/chain/`.
If you already have `examples/chain/run.sh` working, you can reuse it for this directory.

A typical workflow is:

```bash
cd examples/mixed_spin_chain
./run.sh
```

The main log is written to

```
output.dat
```

and observable outputs are written under

```
output/
```

---

# Understanding `output.dat`

`output.dat` summarizes (i) parsed input, (ii) symmetry setup, (iii) basis size, and (iv) the Lanczos run.

Key lines to check for this mixed‑spin example:

- The code confirms the presence of the mixed‑spin inputs:
  - `FILE_NODMAX = list_NODmax.dat`
  - `FILE_SPIN   = list_spin.dat`
- Basis sizes:
  - `THS = 166751` (total states in the selected NOD sector before symmetry reduction)
  - `THS(k) = 1669` (representatives in the chosen translational symmetry sector)
- Lanczos convergence and final energy:
  - `E_0 = -3.656548006870285E+00`
- Eigenvector quality diagnostic:
  - `|1 - (<GS|H|GS>)^2/<GS|H^2|GS>| = 9.3369e-17` (machine precision)

---

# Output files

When `CAL_LM=1` and `CAL_CF=1`, the following files are produced (under `output/`):

- `local_mag.dat`: site‑resolved magnetizations
- `two_body_cf_z+-.dat`: \(\langle S_i^z S_j^z\rangle\), \(\langle S_i^+ S_j^-\rangle\), etc. for pairs in `list_ij_cf.dat`
- `two_body_cf_xyz.dat`: \(\langle S_i^\alpha S_j^\beta\rangle\) data for \(\alpha,\beta\in\{x,y,z}\)

For mixed spins, remember that the local operator norms differ between the two species;
when comparing sites, it is often useful to normalize by \(S_i\) or \(S_i(S_i+1)\) depending on the quantity of interest.

---

# Summary

This example shows how to run QS³‑ED2 on a **mixed‑spin chain** by supplying:

- `list_spin.dat` to define site‑dependent \(S_i\)
- `list_NODmax.dat` to define consistent site‑wise basis constraints
- a translation mapping (`list_p1.dat`) compatible with the mixed‑spin unit cell (here: 2‑site shift)

All other parts of the workflow (run script, Lanczos solver, and observable outputs) match the standard `chain` example.
