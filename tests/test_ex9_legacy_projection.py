#!/usr/bin/env python3
"""Unit-test the historical ex9 ladder-symmetry projection without new compute.

The mock 'actual' tables are derived from the archived tables and must never
be confused with a genuine ex9 recomputation. Full-run evidence is separate.
"""
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile

root = Path(__file__).resolve().parents[1]
original = root / "examples/ref_data/cubic_sp_HB"
validator = root / "tests/verify_ex9.py"
files = ("eigenvalues.dat", "local_mag.dat", "two_body_cf_xyz.dat",
         "two_body_cf_z+-.dat")


def run(folder, projected):
    command = [sys.executable, str(validator), "--actual", str(folder)]
    if projected:
        command.append("--legacy-ex9-symmetry-projection")
    return subprocess.run(command, capture_output=True, text=True)


with tempfile.TemporaryDirectory(prefix="ed2_ex9_projection_test_") as temp:
    target = Path(temp)
    for name in files:
        shutil.copyfile(original / name, target / name)
    ladder = target / "two_body_cf_z+-.dat"
    out = []
    for line in ladder.read_text().splitlines():
        columns = line.split()
        real = (float(columns[12]) + float(columns[16])) / 2
        columns[12] = str(real)
        columns[16] = str(real)
        columns[13] = "0.0"
        columns[17] = "0.0"
        out.append(" ".join(columns))
    ladder.write_text("\n".join(out) + "\n")
    assert run(target, projected=False).returncode != 0, "raw archive incorrectly accepted"
    result = run(target, projected=True)
    assert result.returncode == 0, result.stdout + result.stderr
    # Perturb a physical ladder correlator without violating +-/-+ symmetry.
    bad = [line.split() for line in ladder.read_text().splitlines()]
    for index in (12, 16):
        bad[0][index] = str(float(bad[0][index]) + 1e-4)
    ladder.write_text("\n".join(" ".join(line) for line in bad) + "\n")
    assert run(target, projected=True).returncode != 0, "tampered data accepted"
print("EX9_LEGACY_HERMITIAN_PROJECTION_TEST_PASS")
