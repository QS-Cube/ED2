
# Performance Study: Magnetization Plateau in a Mixed-Spin Chain

This performance example demonstrates how **QS³‑ED2** can efficiently handle **site‑dependent spin magnitudes** and **magnetization‑sector constraints** using

- `list_spin.dat`
- `list_NODmax.dat`

These features allow exact‑diagonalization studies of **mixed‑spin systems**, which are difficult to treat with traditional ED implementations.

As a representative benchmark, we analyze the **spin‑dependence of the magnetization plateau width** in a one‑dimensional mixed‑spin chain consisting of alternating spins

$$
(S,1/2).
$$

The plateau occurs at

$$
\frac{M}{M_s}=\frac{2S-1}{2S+1}.
$$

---

# Model Hamiltonian

We consider an antiferromagnetic mixed‑spin chain described by

$$
\hat H =
J\sum_{j=1}^{L}
\left[
\hat{\mathbf s}_{2j}\cdot
(\hat{\mathbf S}_{2j-1}+\hat{\mathbf S}_{2j+1})
-
h(\hat S^z_{2j-1}+\hat s^z_{2j})
\right],
$$

with periodic boundary conditions

$$
\hat{\mathbf S}_{2L+1}=\hat{\mathbf S}_1.
$$

Here

- $\hat{\mathbf S}_{2j-1}$ : spin‑$S$ operator
- $\hat{\mathbf s}_{2j}$ : spin‑$1/2$ operator

The coupling constant satisfies

$$
J>0
$$

and we set

$$
J=1
$$

as the unit of energy.

---

# Symmetry

The Hamiltonian is invariant under

- two‑site translation
- site inversion

The ground state appears in the symmetry sector

- momentum $k=0$
- even inversion parity

corresponding to

```
M1 = 0
M2 = 0
```

in the ED2 input file.

---

# Saturation magnetization

The saturation magnetization is

$$
M_s = \sum_{r=1}^{2L} S_r
$$

For the alternating chain

$$
(S,1/2)
$$

this becomes

$$
M_s = L(S+1/2) = \frac{L(2S+1)}{2}.
$$

---

# Magnetization sector

We denote the number of lowering operations from the fully polarized state by

$$
N_{\downarrow}.
$$

In QS³‑ED2 this corresponds to

```
NODmax
```

At the plateau position

$$
\frac{M}{M_s}=\frac{2S-1}{2S+1},
$$

the lowering number is

$$
N_{\downarrow}=L.
$$

Therefore the plateau lies between the sectors

$$
N_{\downarrow}=L
$$

and

$$
N_{\downarrow}=L-1.
$$

---

# Input configuration

For a system with $2L$ sites

```
NOS    = 2L
L1     = L
L2     = 2
NO_one = 0
NO_two = 2L
```

Symmetry sector

```
M1 = 0
M2 = 0
```

Local spins and lowering limits are specified using

```
list_spin.dat
list_NODmax.dat
```

---

# Plateau width

The ground state in magnetic field $h$ minimizes

$$
E_0(N_{\downarrow}) - hM(N_{\downarrow}).
$$

The critical field between two sectors is

$$
h_c(N_{\downarrow}) =
E_0(N_{\downarrow})-E_0(N_{\downarrow}-1).
$$

Thus the plateau width is obtained from the energy difference between the sectors

- $N_{\downarrow}=L$
- $N_{\downarrow}=L-1$

---

# Finite‑size behaviour

Finite‑size effects are extremely small.

Accurate results are obtained already for

$$
L = 2,3,\dots,8.
$$

---

# Benchmark result

![plateau width](mixed_spin_plateau.svg){ width="650" }

The numerical results

- reproduce DMRG data for small $S$
- approach the nonlinear spin‑wave result as $S\to\infty$.

---

# Summary

This benchmark demonstrates that **QS³‑ED2 can efficiently treat mixed‑spin quantum systems** with

- heterogeneous local spins
- flexible magnetization‑sector constraints
