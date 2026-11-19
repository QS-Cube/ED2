#!/usr/bin/env python3
"""Independent small-system ED2 spectrum and observable audit.

Requires Python 3 and NumPy. The reference is assembled from Kronecker
products of textbook spin matrices; no ED2 row-generator code is reused.
Run against a *built* QS3ED2 executable. Each run gets a fresh directory.
This checks finite models and does not certify all user inputs or solvers.
"""
import argparse
import itertools
import json
import os
from pathlib import Path
import struct
import subprocess

import numpy as np


def spin_ops(s):
    m = s - np.arange(round(2 * s + 1))
    plus = np.zeros((len(m), len(m)), dtype=complex)
    for col in range(1, len(m)):
        plus[col - 1, col] = np.sqrt(s * (s + 1) - m[col] * (m[col] + 1))
    minus = plus.T.conj()
    return ((plus + minus) / 2, (plus - minus) / (2j), np.diag(m))


def reference(case):
    spins = case['spins']
    dims = [round(2 * s + 1) for s in spins]
    size = int(np.prod(dims))
    ops = []
    for site, s in enumerate(spins):
        axes = []
        for op in spin_ops(s):
            full = np.array([[1.0]], dtype=complex)
            for j, d in enumerate(dims):
                full = np.kron(full, op if j == site else np.eye(d))
            axes.append(full)
        ops.append(axes)
    ham = np.zeros((size, size), dtype=complex)
    for site, vector in case['fields']:
        for axis, h in enumerate(vector):
            ham += h * ops[site - 1][axis]
    for i, j, values in case['bonds']:
        exchange, dm, gamma = np.reshape(values, (3, 3))
        for a in range(3):
            b, c = (a + 1) % 3, (a + 2) % 3
            ham += exchange[a] * (ops[i - 1][a] @ ops[j - 1][a])
            ham += dm[a] * (ops[i - 1][b] @ ops[j - 1][c]
                           - ops[i - 1][c] @ ops[j - 1][b])
            ham += gamma[a] * (ops[i - 1][b] @ ops[j - 1][c]
                              + ops[i - 1][c] @ ops[j - 1][b])
    occupations = list(itertools.product(*[range(d) for d in dims]))
    lo, hi = case.get('window', (0, sum(d - 1 for d in dims)))
    keep = [i for i, state in enumerate(occupations) if lo <= sum(state) <= hi]
    basis = np.eye(size, dtype=complex)[:, keep]
    if 'translation' in case:
        permutation, period, momentum = case['translation'][:3]
        # Build the permutation representation independently in product basis.
        translation = np.zeros((size, size), dtype=complex)
        lookup = {tuple(state): i for i, state in enumerate(occupations)}
        for col, state in enumerate(occupations):
            target = [0] * len(spins)
            for site, value in enumerate(state):
                target[permutation[site] - 1] = value
            translation[lookup[tuple(target)], col] = 1
        projector = np.zeros_like(translation)
        power = np.eye(size, dtype=complex)
        for p in range(period):
            projector += np.exp(-2j * np.pi * momentum * p / period) * power / period
            power = translation @ power
        evals, evecs = np.linalg.eigh(basis.conj().T @ projector @ basis)
        basis = basis @ evecs[:, evals > .5]
        if np.max(abs(ham @ translation - translation @ ham)) > 1e-12:
            raise AssertionError('Reference symmetry does not commute with H')
    projected = basis.conj().T @ ham @ basis
    assert np.max(abs(projected - projected.conj().T)) < 1e-12
    energies, vectors = np.linalg.eigh(projected)
    ground = basis @ vectors[:, 0]
    expectation = lambda op: np.vdot(ground, op @ ground)
    magnetization = np.array([[expectation(op).real for op in axes] for axes in ops])
    pairs = case.get('pairs', [(1, len(spins)), (len(spins), 1)])
    xyz = np.array([[expectation(ops[i - 1][a] @ ops[j - 1][b]).real
                     for b in range(3) for a in range(3)] for i, j in pairs])
    ladder = [[axes[2], axes[0] - 1j * axes[1], axes[0] + 1j * axes[1]] for axes in ops]
    zpm = np.array([[expectation(ladder[i - 1][a] @ ladder[j - 1][b])
                     for b in range(3) for a in range(3)] for i, j in pairs])
    return energies, magnetization, xyz, zpm


def write_deck(work, case, algorithm, cache, mode, threads=1):
    work.mkdir(parents=True, exist_ok=False)
    spins = case['spins']
    caps = [round(2 * s) for s in spins]
    lo, hi = case.get('window', (0, sum(caps)))
    (work / 'spins.dat').write_text(''.join(f'{s:.17g}\n' for s in spins))
    (work / 'caps.dat').write_text(''.join(f'{n}\n' for n in caps))
    (work / 'fields.dat').write_text(''.join(
        f'{i} ' + ' '.join(f'{h:.17g}' for h in hvec) + '\n'
        for i, hvec in case['fields']))
    (work / 'bonds.dat').write_text(''.join(
        f'{i} {j} ' + ' '.join(f'{v:.17g}' for v in values) + '\n'
        for i, j, values in case['bonds']))
    pairs = case.get('pairs', [(1, len(spins)), (len(spins), 1)])
    (work / 'pairs.dat').write_text(''.join(f'{i} {j}\n' for i, j in pairs))
    period, momentum, slot = 1, 0, 1
    if 'translation' in case:
        permutation, period, momentum = case['translation'][:3]
        slot = case['translation'][3] if len(case['translation']) > 3 else 1
        (work / 'translation.dat').write_text(''.join(f'{i}\n' for i in permutation))
    text = f'''&input_parameters
NOS={len(spins)},NODmin={lo},NODmax={hi},ALG={algorithm},
{','.join(f'L{k}={period if k == slot else 1}' for k in range(1, 7))},
{','.join(f'M{k}={momentum if k == slot else 0}' for k in range(1, 7))},
NO_one={len(case['fields'])},NO_two={len(case['bonds'])},
wk_dim={cache},MNTE=-1,
FILE_xyz_dm_gamma='bonds.dat',FILE_hvec='fields.dat',
FILE_spin='spins.dat',FILE_NODmax='caps.dat',FILE_S{slot}='translation.dat',
OUTDIR='./',FILE_wf='./',wr_wf=0,re_wf=0,cal_lm=1,cal_cf=1,
NO_two_cf={len(pairs)},FILE_two_cf='pairs.dat'
/
&input_lancz
lnc_ene_conv=1d-13,minitr=5,maxitr=300,itrint=5
/
&input_TRLan
NOE=2,NOK=4,NOM=24,maxitr=100,lnc_ene_conv=1d-12,
i_vec_min=1,i_vec_max=2
/
'''
    (work / 'input.dat').write_text(text)
    env = dict(os.environ)
    for key in list(env):
        if key.startswith('ED2_'):
            del env[key]
    env.update(OMP_NUM_THREADS=str(threads), OMP_DYNAMIC='FALSE',
               OPENBLAS_NUM_THREADS='1', MKL_NUM_THREADS='1')
    env.update(mode)
    return env


def run(exe, root, name, case, algorithm=3, cache=-1, mode=None, timeout=60, threads=1):
    mode = mode or {}
    work = root / name
    expected = reference(case)
    env = write_deck(work, case, algorithm, cache, mode, threads)
    with (work / 'input.dat').open() as inp:
        p = subprocess.run([str(exe)], cwd=work, stdin=inp, env=env,
                           stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                           text=True, timeout=timeout, check=False)
    (work / 'stdout.log').write_text(p.stdout)
    result = dict(name=name, algorithm=algorithm, cache=cache, mode=mode, threads=threads,
                  expected_dimension=len(expected[0]), exit_code=p.returncode)
    try:
        if p.returncode:
            raise AssertionError(f'native exit status {p.returncode}')
        actual = np.loadtxt(work / 'eigenvalues.dat', ndmin=2)[:, 1]
        expected_count = len(expected[0]) if algorithm == 3 else (1 if algorithm == 1 else 2)
        assert len(actual) == expected_count, (len(actual), expected_count)
        actual_mag = np.loadtxt(work / 'local_mag.dat', ndmin=2)[:, 1:4]
        actual_xyz = np.loadtxt(work / 'two_body_cf_xyz.dat', ndmin=2)[:, 2:11]
        ladder_rows = np.loadtxt(work / 'two_body_cf_z+-.dat', ndmin=2)[:, 2:]
        assert ladder_rows.shape == (len(expected[3]), 18), ladder_rows.shape
        actual_zpm = ladder_rows[:, 0::2] + 1j * ladder_rows[:, 1::2]
        result.update(
            actual_ground_energy=float(actual[0]),
            reference_ground_energy=float(expected[0][0]),
            max_energy_error=float(np.max(abs(actual - expected[0][:len(actual)]))),
            max_magnetization_error=float(np.max(abs(actual_mag - expected[1]))),
            max_xyz_error=float(np.max(abs(actual_xyz - expected[2]))),
            max_ladder_error=float(np.max(abs(actual_zpm - expected[3]))))
        # Eigenvalues alone can miss wrong eigenvectors, signs and column order.
        tolerance = 2e-11 if algorithm == 3 else 2e-7
        assert np.all(np.isfinite(actual))
        for key in ('max_energy_error', 'max_magnetization_error', 'max_xyz_error', 'max_ladder_error'):
            assert result[key] <= tolerance, (key, result[key], tolerance)
        result['status'] = 'PASS'
    except Exception as exc:
        result.update(status='FAIL', error=str(exc))
    (work / 'comparison.json').write_text(json.dumps(result, indent=2) + '\n')
    return result


def cases():
    spins = [.5, 1, .5, 1]
    bonds = [(1, 2, [.82, .66, 1.05, .13, -.07, .12, -.08, .09, .11]),
             (2, 3, [.72, .60, 1.13, -.06, .08, -.12, .05, -.03, .04]),
             (3, 4, [.81, .65, 1.06, .09, .06, .1, .03, -.04, -.05])]
    fields = [(1, [.075, -.041, .205]), (2, [-.045, .027, .135]),
              (3, [.065, .033, .187]), (4, [-.055, -.019, .143])]
    mixed = dict(spins=spins, bonds=bonds, fields=fields)
    yield 'mixed_tensor', mixed
    yield 'fields_reordered', dict(mixed, fields=[fields[i] for i in [2, 0, 3, 1]])
    yield 'field_sparse_site4', dict(mixed, fields=[fields[3]])
    yield 'fields_duplicate', dict(mixed, fields=[fields[0], (1, fields[1][1]), fields[2]])
    yield 'fields_duplicate_combined', dict(mixed, fields=[(1, [a + b for a, b in zip(fields[0][1], fields[1][1])]), (2, [0., 0., 0.]), fields[2], (4, [0., 0., 0.])])
    reversed_bonds = [(j, i, v[:3] + [-x for x in v[3:6]] + v[6:]) for i, j, v in bonds]
    yield 'bonds_reversed', dict(mixed, bonds=reversed_bonds)
    yield 'projected_nod_window', dict(mixed, window=(1, 2))
    yield 'heisenberg_dimer', dict(spins=[.5, .5], bonds=[(1, 2, [1, 1, 1, 0, 0, 0, 0, 0, 0])], fields=[])
    yield 'field_sign_and_sy', dict(spins=[.5, 1], bonds=[], fields=[(1, [.31, -.27, .43]), (2, [-.19, .23, .17])])
    ring = dict(spins=[.5] * 4,
                bonds=[(i + 1, (i + 1) % 4 + 1, [.73, .53, .91, .0, .0, .21, .0, .0, .04]) for i in range(4)],
                fields=[(i + 1, [.13, .07, .19]) for i in range(4)],
                translation=([2, 3, 4, 1], 4, 0))
    yield 'translation_gamma', ring
    for slot in (4, 5, 6):
        yield f'translation_gamma_slot{slot}', dict(ring, translation=([2, 3, 4, 1], 4, 0, slot))


def zero_hamiltonian(exe, root, algorithm, threads):
    """Analytic degenerate case; eigenvectors need not match a chosen basis."""
    name = f'zero_h_alg{algorithm}'
    work = root / name
    case = dict(spins=[.5, 1, .5, 1], fields=[], bonds=[])
    env = write_deck(work, case, algorithm, -1, {}, threads)
    inp = work / 'input.dat'
    inp.write_text(inp.read_text().replace('wr_wf=0', 'wr_wf=1').replace(
        'cal_lm=1,cal_cf=1', 'cal_lm=0,cal_cf=0'))
    with inp.open() as stream:
        native = subprocess.run([str(exe)], cwd=work, env=env, stdin=stream,
                                stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                                text=True, timeout=60, check=False)
    (work / 'stdout.log').write_text(native.stdout)
    result = dict(name=name, algorithm=algorithm, threads=threads,
                  exit_code=native.returncode, expected_dimension=36)
    try:
        if algorithm == 2:
            # The current TRLan implementation does not recover a complete
            # degenerate invariant subspace. It must fail explicitly instead
            # of reporting a successful NaN/incorrect eigenpair.
            assert native.returncode != 0
            assert 'TRLan Krylov breakdown' in native.stdout
            assert not (work / 'eigenvalues.dat').exists()
            result['behavior'] = 'controlled rejection; ALG=3 recommended'
        else:
            assert native.returncode == 0
            energies = np.loadtxt(work / 'eigenvalues.dat', ndmin=2)[:, 1]
            assert len(energies) == (1 if algorithm == 1 else 36)
            assert np.all(np.isfinite(energies))
            result['max_energy_error'] = float(np.max(abs(energies)))
            assert result['max_energy_error'] <= 1e-13
            vectors = []
            for index in range(1, len(energies) + 1):
                raw = (work / f'wf{index}.bin').read_bytes()
                nbytes = struct.unpack('=i', raw[:4])[0]
                assert nbytes == 36 * 16 and len(raw) == nbytes + 8
                assert struct.unpack('=i', raw[-4:])[0] == nbytes
                vector = np.frombuffer(raw[4:-4], dtype=np.complex128)
                assert np.all(np.isfinite(vector))
                vectors.append(vector)
            vectors = np.column_stack(vectors)
            orthogonality_error = float(np.max(abs(
                vectors.conj().T @ vectors - np.eye(len(energies)))))
            result['max_orthonormality_error'] = orthogonality_error
            assert orthogonality_error <= 2e-12
            result['behavior'] = 'finite zero eigenvalues and normalized wavefunctions'
        result['status'] = 'PASS'
    except Exception as exc:
        result.update(status='FAIL', error=str(exc))
    (work / 'comparison.json').write_text(json.dumps(result, indent=2) + '\n')
    return result


def iteration_limit(exe, root, algorithm, threads):
    """A deliberately inadequate iteration budget must not publish results."""
    name = f'iteration_limit_alg{algorithm}'
    work = root / name
    case = dict(cases())['mixed_tensor']
    env = write_deck(work, case, algorithm, -1, {}, threads)
    inp = work / 'input.dat'
    text = inp.read_text()
    text = text.replace('maxitr=300', 'maxitr=1') if algorithm == 1 else text.replace('maxitr=100,', 'maxitr=1,')
    inp.write_text(text)
    with inp.open() as stream:
        native = subprocess.run([str(exe)], cwd=work, env=env, stdin=stream,
                                stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                                text=True, timeout=60, check=False)
    (work / 'stdout.log').write_text(native.stdout)
    result = dict(name=name, algorithm=algorithm, threads=threads,
                  exit_code=native.returncode,
                  behavior='controlled rejection of unconverged iteration-limited solve')
    try:
        expected = ('Lanczos iteration limit reached before convergence' if algorithm == 1
                    else 'TRLan restart limit reached before convergence')
        assert native.returncode != 0
        assert expected in native.stdout
        assert not (work / 'eigenvalues.dat').exists()
        assert not (work / 'local_mag.dat').exists()
        assert not (work / 'two_body_cf_xyz.dat').exists()
        result['status'] = 'PASS'
    except Exception as exc:
        result.update(status='FAIL', error=str(exc))
    (work / 'comparison.json').write_text(json.dumps(result, indent=2) + '\n')
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--exe', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--case', action='append', help='Only named dense cases; repeatable')
    parser.add_argument('--threads', type=int, default=1)
    parser.add_argument('--with-iterative', action='store_true')
    parser.add_argument('--field-cache-variants', action='store_true', help='Exercise sparse/reordered/duplicate fields through each cache path')
    args = parser.parse_args()
    if args.threads < 1:
        parser.error('--threads must be positive')
    exe = args.exe.resolve(strict=True)
    root = args.output.resolve()
    root.mkdir(parents=True, exist_ok=False)
    results = []
    for name, case in cases():
        if not args.case or name in args.case:
            result = run(exe, root, name, case, threads=args.threads)
            results.append(result)
            print(json.dumps(result), flush=True)
    for algorithm in (1, 2, 3):
        if not args.case or f'zero_h_alg{algorithm}' in args.case:
            result = zero_hamiltonian(exe, root, algorithm, args.threads)
            results.append(result)
            print(json.dumps(result), flush=True)
    for algorithm in (1, 2):
        if not args.case or f'iteration_limit_alg{algorithm}' in args.case:
            result = iteration_limit(exe, root, algorithm, args.threads)
            results.append(result)
            print(json.dumps(result), flush=True)
    if args.with_iterative:
        mixed = dict(cases())['mixed_tensor']
        modes = [
            ('padded', -1, {}), ('on_demand', 0, {}), ('partial', 1, {}),
            ('coeff_bound', -1, {'ED2_CACHE_COEFF_BOUND': '1'}),
            ('csr', -1, {'ED2_CSR_COMPLEX_CACHE': '1'}),
            ('csr_release', -1, {'ED2_CSR_COMPLEX_CACHE': '1', 'ED2_CSR_RELEASE_PADDED_CACHE': '1'}),
            ('csr_direct', -1, {'ED2_CSR_COMPLEX_CACHE': '1', 'ED2_CSR_RELEASE_PADDED_CACHE': '1', 'ED2_CSR_DIRECT_BUILD': '1'})]
        selected = [('mixed_tensor', mixed)]
        if args.field_cache_variants:
            selected += [(name, case) for name, case in cases() if name in ('fields_reordered', 'field_sparse_site4', 'fields_duplicate')]
        for case_name, case in selected:
            for mode, cache, env in modes:
                result = run(exe, root, case_name + '_lanczos_' + mode, case, algorithm=1, cache=cache, mode=env, threads=args.threads)
                results.append(result)
                print(json.dumps(result), flush=True)
        result = run(exe, root, 'thick_restart', mixed, algorithm=2, threads=args.threads)
        results.append(result)
        print(json.dumps(result), flush=True)
    summary = dict(reference='Independent NumPy spin matrices and explicit tensor products',
                   numpy_version=np.__version__, executable=str(exe), results=results,
                   passed=sum(r['status'] == 'PASS' for r in results),
                   failed=sum(r['status'] == 'FAIL' for r in results))
    (root / 'summary.json').write_text(json.dumps(summary, indent=2) + '\n')
    return 1 if summary['failed'] else 0


if __name__ == '__main__':
    raise SystemExit(main())
