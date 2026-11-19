
# Performance Example: Response Analysis with Fictitious Symmetry-Breaking Fields

This page outlines a workflow for symmetry-breaking responses near
saturation magnetization. The original figures, per-point input decks, raw
energy and magnetization data, and fit scripts are not included in the
repository. Quantitative results quoted below remain **unverified historical
claims**, not a reproducible benchmark of the current source revision.

Use the model and analysis definitions as a starting point for new
calculations. Archive the missing inputs, software revision, execution
metadata, and numerical results before presenting the historical values
as validated ED2 results.

The proposed calculation consists of

- calculations close to **saturation magnetization**
- controlled truncation of the Hilbert space using the **number of down spins**
- systematic analysis of **responses to small transverse fields**
- **finite‑size scaling analysis** of susceptibilities and order parameters

with an explicit check of the occupation cutoff at each system size.

The calculations below are performed for the **antiferromagnetic Heisenberg model on the square lattice** near the saturation field.

---

# Model

We consider the spin‑1/2 Heisenberg Hamiltonian

$$
\hat H =
J\sum_{\langle i,j\rangle}
\mathbf S_i \cdot \mathbf S_j
-
H \sum_i S_i^z
-
\delta h_u \sum_i S_i^x
-
\sum_i \delta h_s^{(i)} S_i^x .
$$

Here

- $J>0$ is the exchange interaction,
- $H$ is the longitudinal magnetic field,
- $\delta h_u$ is a **uniform transverse field**, and
- $\delta h_s^{(i)}$ is a **staggered transverse field**.

The transverse fields are introduced as **fictitious symmetry‑breaking fields** in order to probe the response of the system and detect spontaneous symmetry breaking.

The intended regime is near saturation, where a small occupation window
may be useful. ED2 adds input fields with a **plus** sign: to realize the
Hamiltonian above, the input coefficients are
$h^x_i=-(\delta h_u+\delta h_s^{(i)})$, $h^y_i=0$, and $h^z_i=-H$.
A staggered pattern can reduce the allowed lattice-translation symmetry;
check every supplied generator against the complete field pattern.

---

# Hilbert‑Space Truncation Using the Number of Down Spins

QS³‑ED2 constructs the Hilbert space by specifying a cutoff

$$
N_{\downarrow}
$$

for the number of down spins.

A transverse field does not conserve total $S^z$. Limiting the occupation
window therefore computes $P H P$ and is an approximation to the full
problem, even near saturation.

The first numerical task is therefore to determine **how large the cutoff $N_{\downarrow}$ must be** when small transverse perturbations are applied.

!!! note "Figure asset pending"

    The original cutoff-test plot is not included in this documentation
    source tree. The qualitative discussion is retained below, but a
    quantitative comparison requires regenerating and archiving the
    corresponding model data and image.

The reference calculation considers the response of the transverse magnetization when small **uniform** and **staggered** transverse fields are applied at

$$
H/J = 3.7 .
$$

For a finite system, determine the magnetization-sector crossing fields
from its zero-field energies before choosing a field within a sector
interval. The number 3.7 does not by itself identify a plateau center for
every size, and the missing data do not establish a thermodynamic-limit
plateau center at this value.

The original discussion proposed an upper cutoff of

$$
N_{\downarrow}^{\prime} + 1
$$

where $N_{\downarrow}^{\prime}$ is the number of down spins in the ground state when the transverse fields are zero.

A single transverse-spin operator changes the lowering number by one.
This motivates including neighboring sectors for linear response about a
nondegenerate, fixed-sector unperturbed ground state. Finite perturbations
also mix more distant sectors at higher order; increase the cutoff until
energies and the response converge. The proposed cutoff is not a general
accuracy guarantee, especially near level crossings.

Uniform and staggered responses must be measured separately, with the
matching spatial weight in each observable. Their relative magnitudes
cannot be recovered quantitatively from the missing figure.

---

# Extraction of the Order Parameter

The second step is to estimate the **spontaneous staggered magnetization** in the thermodynamic limit.

Because exact diagonalization can only be performed on finite systems, we analyze the dependence of the transverse magnetization on the small staggered field.

!!! note "Figure asset pending"

    The original fitting-function plot is not included in this repository.
    The two analytic fit forms remain specified explicitly below.

Two fitting functions are introduced:

$$
y_1 = a\tanh(g\,\delta h_s/J) + b(\delta h_s/J)
$$

$$
y_2 = y_1 + c(\delta h_s/J)^3 .
$$

These functions do not have a strict theoretical justification; they are introduced as **empirical fitting forms** to test the stability of the extrapolation.

In this empirical fit, the parameter

$$
a
$$

is intended to estimate the nonlinear response amplitude at each finite
size. Interpreting its extrapolation as the spontaneous staggered
magnetization requires stability under changes of fit window, fit form,
occupation cutoff, and system size. Symbolically, the proposed estimate is

$$
m_x = \lim_{L\to\infty} a(L).
$$

The fit parameter alone does not establish the order of the
$L\to\infty$ and $\delta h_s\to0$ limits.

---

# Finite‑Size Scaling

The final step is to analyze the **finite‑size scaling** of the numerical results.

!!! note "Figure asset pending"

    The original finite-size scaling plot is not currently part of the
    source distribution; do not infer numerical data from a missing figure.

Two quantities are examined:

1. **Staggered susceptibility**

$$
\chi_s =
\frac{1}{N\,\delta h_s}
\sum_i \eta_i\langle S_i^x \rangle
$$

Here $\delta h_s^{(i)}=\eta_i\delta h_s$ and $\eta_i=\pm1$ is the
chosen staggered pattern. Without $\eta_i$, the expression measures the
uniform response rather than the staggered response. The displayed ratio
approximates the zero-field derivative only in the linear regime.

2. **Spontaneous staggered magnetization** estimated by extrapolating $a(L)$.

The original, currently unarchived calculation reported the scaling

$$
\chi_s \sim L^4 ,
$$

over its studied sizes. Without the raw data, size definition, fitting
range, and uncertainty analysis, this exponent is not independently
verified and should not be generalized.

The same historical description quotes an extrapolated order parameter

$$
m_x \approx 0.19
$$

at

$$
H/J = 3.79 \pm 0.03 .
$$

Neither this estimate and uncertainty nor its agreement with earlier
literature is verified by the files currently supplied. Add the source
citations and complete numerical analysis before using it as a benchmark.

---

# Significance for QS³‑ED2

A reproducible version of this study requires generated input files for
every size and field, raw outputs, cutoff-convergence tests, the software
revision and build settings, and scripts for all fits and figures.

The implementation provides components for

- efficient calculations **near saturation magnetization**
- controlled truncation using the **number of down spins**
- numerical evaluation of **response functions**
- subsequent **finite-size scaling analyses** outside the solver

for explicitly specified finite-size calculations.

Keep solver verification, truncation convergence, and the physical
extrapolation as separate checks when evaluating the final conclusions.
