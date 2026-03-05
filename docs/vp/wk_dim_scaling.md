
# Performance: Dependence of Computational Time on `wk_dim`

## Overview

One distinctive feature of **QS³‑ED2** is the ability to **cache Hamiltonian matrix elements in memory**.  
This functionality was not present in the original QS³‑ED code. By storing matrix elements within the available memory, repeated evaluations of the Hamiltonian action can be avoided, potentially leading to substantial acceleration of the Lanczos iterations.

To demonstrate this effect, we investigate how the **computation time depends on the parameter `wk_dim`**, which controls how many Hamiltonian matrix elements are cached.

The benchmark is performed using the calculation conditions of **Example 9 (`cubic_sp_HB`)**, except that the calculation of local magnetization and correlation functions is disabled.


---

# Benchmark model

The `cubic_sp_HB` example corresponds to an **antiferromagnetic Heisenberg model on a cubic lattice** of size

$$
10 \times 10 \times 10
$$

with the following quantum-number sector:

- total magnetization sector  
  $$
  S^z = M_s - 3
  $$

- momentum  
  $$
  \mathbf{k} = \Gamma \;(k=0)
  $$

- even parity with respect to reflections about the XY, YZ, and ZX planes

In the input file this corresponds to

```
M1 = M2 = M3 = M4 = M5 = M6 = 0
```

The Hilbert-space dimension of the magnetization sector is

$$
\binom{1000}{3} = 166,167,000 .
$$

After symmetry reduction, the working Hilbert space becomes

$$
D = 23,719 ,
$$

which corresponds to a reduction of approximately

$$
\sim 1/7000 .
$$


---

# Optimal value of MNTE

Before tuning `wk_dim`, an appropriate value of **MNTE** must be specified.

For this model, when the system size is sufficiently large, it is straightforward to determine that

```
MNTE = 19
```

is optimal.

This can be understood by considering how the Hamiltonian acts on a configuration with **three down spins that are far apart**.

When the Hamiltonian acts once, each spin can hop to its nearest neighbors.  
Since the cubic lattice has coordination number

$$
z = 6 ,
$$

the possible transitions are

- hopping processes:  
  $$
  6 \times 3 = 18
  $$

- diagonal term  
  $$
  \hat S^z_r \hat S^z_{r'}
  $$

Therefore

$$
MNTE = 18 + 1 = 19 .
$$


---

# Computational cost with and without caching

Let

```
NO_one + NO_two ~ O(N)
```

denote the cost of applying the Hamiltonian once to a representative state.

The cost of computing

$$
\hat H |a\rangle
$$

depends on whether the matrix elements are cached.

### With matrix-element caching

$$
O(N)
$$

### Without caching

$$
O\!\left(
N \times
\left(\prod_{m=1}^{6} L_m \right)
\times
NOD_{max}
\times
\log(NOD_{max})
\right)
$$

The additional cost arises because the program must determine **which representative state the new configuration belongs to after a transition**.  
This requires additional symmetry searches over the translational group.

Therefore, **when memory allows, storing matrix elements is strongly recommended.**


---

# Cost of each computational step

A rough estimate of the computational complexity of each stage is

### Selection of representative states

$$
O\!\left(
D \times N^2 \times NOD_{max} \times \log(NOD_{max})
\right)
$$

### Storing matrix elements

$$
O\!\left(
wk\_dim \times N \times NOD_{max} \times \log(NOD_{max})
\right)
$$

### Lanczos iteration

$$
O\!\left(
N_{itr}
\left[
wk\_dim +
(D-wk\_dim)
\times
N \times NOD_{max} \times \log(NOD_{max})
\right]
\right)
$$

where

$$
N_{itr} \sim O(10-100)
$$

is the number of Lanczos iterations.

Since

$$
\prod_{m=1}^{6} L_m \sim O(N),
$$

and

$$
D \sim O\!\left(\binom{N}{NOD_{max}}/N\right),
$$

the dominant computational cost becomes


### Case 1: `wk_dim = 0`

$$
O\!\left(
N_{itr} \times D \times N^2 \times NOD_{max} \times \log(NOD_{max})
\right)
$$


### Case 2: `wk_dim = D`

$$
O\!\left(
D \times N^2 \times NOD_{max} \times \log(NOD_{max})
+
N_{itr} \times N \times D
\right)
$$


---

# Expected speedup

The ratio between the two limits is approximately

$$
R =
O\!\left(
N_{itr}^{-1}
+
(N \times NOD_{max} \times \log NOD_{max})^{-1}
\right)
$$

For typical QS³ calculations the first term dominates, giving a theoretical speedup of roughly

$$
\sim O(N_{itr})
$$

which corresponds to **up to about two orders of magnitude**.


---

# Benchmark result

The measured dependence of the runtime on

```
wk_dim / D
```

is shown in the figure below.

![wk_dim scaling](wk_dim_scaling.svg)


The computation time decreases approximately **linearly** as a function of

$$
wk\_dim / D .
$$

In this benchmark

- runtime was reduced by roughly **17×**
- memory usage increased by about **8×**


---

# Practical recommendation

When sufficient memory is available, increasing `wk_dim` is an effective way to accelerate the calculation.

However, caution is required for models **without U(1) symmetry**, where

- `MNTE` becomes larger
- memory consumption grows significantly

and the caching strategy may become memory‑limited.

