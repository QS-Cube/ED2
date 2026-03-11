
# Performance Example: Response Analysis with Fictitious Symmetry-Breaking Fields

This performance example demonstrates how **QS³-ED2** can be used to perform numerical analyses of quantum spin systems in the presence of **small fictitious symmetry-breaking fields**.

The goal of this example is **not to introduce new physics**, but rather to show that the numerical procedure proposed in previous studies can be **practically executed using QS³-ED2** for relatively large system sizes.

In particular, this benchmark illustrates that QS³-ED2 enables

- calculations close to **saturation magnetization**
- systematic analysis of **symmetry-breaking responses**
- **finite-size scaling** of susceptibilities

for lattice sizes that are difficult to treat using conventional exact-diagonalization approaches.

---

# Model

As a benchmark system we consider the **antiferromagnetic Heisenberg model on the square lattice**

$$
\hat H
=
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

- $J>0$ is the exchange coupling
- $H$ is the longitudinal magnetic field
- $\delta h_u$ is a **uniform transverse field**
- $\delta h_s^{(i)}$ is a **staggered transverse field**

The fictitious fields $\delta h_u$ and $\delta h_s$ are introduced as small perturbations to probe symmetry-breaking tendencies of the ground state.

---

# Numerical Procedure

The numerical procedure consists of the following steps.

1. Introduce a **cutoff $N_{\downarrow}$** for the number of down spins.
2. Choose the longitudinal magnetic field $H$ such that the system is located at the **center of the magnetization plateau**.
3. Apply small perturbative transverse fields.
4. Measure the response of local spin observables.

Two susceptibilities are defined:

$$
\chi_u
=
\frac{1}{N \, \delta h_u}
\sum_i \langle S_i^x \rangle
$$

$$
\chi_s
=
\frac{1}{N \, \delta h_s}
\sum_i \langle S_i^x \rangle
$$

evaluated in the limit

$$
\delta h_u ,\; \delta h_s \rightarrow 0 .
$$

The divergence of the staggered susceptibility

$$
\chi_s
$$

with system size indicates the presence of spontaneous symmetry breaking.

---

# Fitting Analysis

To analyze the response quantitatively, the following fitting functions are introduced:

$$
y_1 = a \tanh(g \delta h_s / J) + b (\delta h_s / J)
$$

$$
y_2 = y_1 + c (\delta h_s / J)^3 .
$$

These functions allow the extraction of the **offset magnetization**

$$
m_x
$$

in the limit of vanishing perturbation.

---

# Finite-Size Scaling

The staggered susceptibility exhibits the scaling behavior

$$
\chi_s \sim L^4 ,
$$

where $L$ is the linear system size.

Using QS³-ED2, calculations can be performed for lattice sizes up to

$$
N = L^2 = 81
$$

in this benchmark example.

The extrapolated spontaneous transverse magnetization is

$$
m_x \approx 0.19
$$

at

$$
H/J \approx 3.79 .
$$

---

# Benchmark Figures

The numerical results obtained with QS³-ED2 are summarized in the figures below.

- response of local magnetization to fictitious fields
- fitting analysis of the offset magnetization
- finite-size scaling of the susceptibility

These calculations demonstrate that the full analysis procedure can be carried out within the QS³-ED2 framework.

---

# Significance for QS³-ED2

This benchmark highlights that QS³-ED2 enables numerical studies that require

- exact diagonalization near **saturation magnetization**
- control of the **number of down spins**
- systematic evaluation of **response functions**
- **finite-size scaling analysis**

Such calculations typically require system sizes that are difficult to access with conventional ED methods.

QS³-ED2 therefore provides a practical numerical platform for investigating symmetry-breaking phenomena in quantum spin systems.
