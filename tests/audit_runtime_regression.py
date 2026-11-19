#!/usr/bin/env python3
"""Bounds-checked wavefunction I/O, representative allocation, and local observables.

Uses the standard library only. Each Fortran driver is built from the selected
source tree in an isolated directory. No installed ED2 binary is required.
"""
import argparse
import json
import math
import os
from pathlib import Path
import shlex
import subprocess


def execute(command, work, log, env=None, input_path=None):
    with (work / log).open('w') as output:
        if input_path is None:
            return subprocess.run(command, cwd=work, env=env, stdout=output,
                                  stderr=subprocess.STDOUT, timeout=120).returncode
        with input_path.open() as inp:
            return subprocess.run(command, cwd=work, env=env, stdin=inp,
                                  stdout=output, stderr=subprocess.STDOUT,
                                  timeout=120).returncode


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--repo', type=Path, default=Path(__file__).resolve().parents[1])
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--fc', default=os.environ.get('FC', 'gfortran'))
    args = parser.parse_args()
    repo = args.repo.resolve()
    root = args.output.resolve()
    root.mkdir(parents=True, exist_ok=False)
    results = []
    for name, sources in (
        ('io', ['source/input_param.f90', 'tests/audit_wavefunction_io.f90']),
        ('basis', ['source/input_param.f90', 'source/state_lists.f90',
                   'tests/audit_basis_driver.f90']),
        ('multivector_lm', ['source/input_param.f90', 'source/state_lists.f90',
                            'source/ham2vec.f90', 'source/get_expectation_values.f90',
                            'tests/audit_multivector_local_mag.f90']),
    ):
        work = root / ('build-' + name)
        work.mkdir()
        compiler = shlex.split(args.fc)
        # GNU's -J/-fcheck flags are not accepted by Intel ifx/ifort.
        # The Intel path uses LP64 sequential MKL for a consistent link ABI.
        intel = Path(compiler[0]).name in ('ifx', 'ifort')
        if intel:
            flags = ['-O0', '-g', '-qopenmp', '-check', 'all',
                     '-traceback', '-module', str(work)]
            libs = ['-qmkl=sequential']
        else:
            flags = ['-O0', '-g', '-fopenmp', '-fcheck=all', '-J', str(work)]
            libs = []
        command = compiler + flags + [str(repo / s) for s in sources] + [
                  '-o', 'driver'] + libs
        status = execute(command, work, 'compile.log')
        if status:
            raise RuntimeError(f'{name} driver compilation failed; see {work}/compile.log')
    for nvec in (3, 12):
        work = root / f'io-{nvec}'
        work.mkdir()
        status = execute([str(root / 'build-io/driver'), str(nvec)], work, 'stdout.log')
        results.append(dict(name=f'io-{nvec}', returncode=status,
                            status='PASS' if status == 0 else 'FAIL'))
    for threads in (1, 4):
        work = root / f'multivector-lm-{threads}-threads'
        work.mkdir()
        env = dict(os.environ, OMP_NUM_THREADS=str(threads), OMP_DYNAMIC='FALSE')
        status = execute([str(root / 'build-multivector_lm/driver')],
                         work, 'stdout.log', env=env)
        results.append(dict(name=f'multivector-lm-{threads}-threads',
                            returncode=status, status='PASS' if status == 0 else 'FAIL'))
    # Burnside's lemma for reversal of 30 spin-1/2 sites and 0..4 deviations:
    # identity fixes sum C(30,k) states; reversal fixes sum C(15,k) for k=0..2.
    expected = (sum(math.comb(30, k) for k in range(5))
                + sum(math.comb(15, k) for k in range(3))) // 2
    canonical_ids = None
    for repeats in (1, 3):
        for threads in (1, 4):
            name = f'basis-{repeats}-generators-{threads}-threads'
            work = root / name
            work.mkdir()
            (work / 'empty.dat').touch()
            (work / 'spins.dat').write_text('0.5\n' * 30)
            (work / 'caps.dat').write_text('1\n' * 30)
            (work / 'reflection.dat').write_text(''.join(f'{i}\n' for i in range(30, 0, -1)))
            periods = ','.join(f'L{i}={2 if i <= repeats else 1}' for i in range(1, 7))
            (work / 'input.dat').write_text(f'''&input_parameters
NOS=30,NODmin=0,NODmax=4,ALG=1,
{periods},M1=0,M2=0,M3=0,M4=0,M5=0,M6=0,
NO_one=0,NO_two=0,wk_dim=0,MNTE=-1,
FILE_xyz_dm_gamma='empty.dat',FILE_hvec='empty.dat',
FILE_spin='spins.dat',FILE_NODmax='caps.dat',
FILE_S1='reflection.dat',FILE_S2='reflection.dat',FILE_S3='reflection.dat',
OUTDIR='./',FILE_wf='./',wr_wf=0,re_wf=0,cal_lm=0,cal_cf=0
/
''')
            env = dict(os.environ, OMP_NUM_THREADS=str(threads), OMP_DYNAMIC='FALSE')
            status = execute([str(root / 'build-basis/driver')], work, 'stdout.log',
                             env=env, input_path=work / 'input.dat')
            result = dict(name=name, returncode=status, expected_dimension=expected)
            try:
                assert status == 0, f'native exit status {status}'
                ids = [int(row.split()[0]) for row in (work / 'representatives.dat').read_text().splitlines()]
                result['actual_dimension'] = len(ids)
                assert len(ids) == expected, (len(ids), expected)
                assert ids == sorted(set(ids)), 'representatives not sorted/unique'
                if canonical_ids is None:
                    canonical_ids = ids
                assert ids == canonical_ids, 'redundant generators changed representatives'
                result['status'] = 'PASS'
            except Exception as error:
                result.update(status='FAIL', error=str(error))
            results.append(result)
    summary = dict(compiler=args.fc, reference='Analytic Burnside count, exact I/O round-trip, and two-state magnetization reference',
                   results=results, passed=sum(x['status'] == 'PASS' for x in results),
                   failed=sum(x['status'] == 'FAIL' for x in results))
    (root / 'summary.json').write_text(json.dumps(summary, indent=2) + '\n')
    print(json.dumps(summary, indent=2))
    return int(summary['failed'] != 0)


if __name__ == '__main__':
    raise SystemExit(main())
