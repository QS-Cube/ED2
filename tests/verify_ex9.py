#!/usr/bin/env python3
"""Validate archived or freshly computed ED2 N=1000 cubic three-magnon outputs.

This checker does not run ex9. An archive-only pass is NOT a fresh reproduction.
Uses Python's standard library; fails on partial/appended/NaN/Inf output.
"""
import argparse
import json
import math
from pathlib import Path

TABLES = {
    "energy": ("eigenvalues.dat", 1, 2),
    "mag": ("local_mag.dat", 1000, 4),
    "xyz": ("two_body_cf_xyz.dat", 9, 11),
    "zpm": ("two_body_cf_z+-.dat", 9, 20),
}


def read_table(folder, file_name, count, width):
    path = folder / file_name
    rows = []
    with path.open(encoding="utf-8") as stream:
        for line_no, line in enumerate(stream, 1):
            if not line.strip():
                continue
            fields = line.split()
            if len(fields) != width:
                raise ValueError(f"{path}:{line_no}: expected {width} columns, got {len(fields)}")
            try:
                row = [float(v.replace("D", "E").replace("d", "e")) for v in fields]
            except ValueError as error:
                raise ValueError(f"{path}:{line_no}: invalid numeric value") from error
            if not all(math.isfinite(v) for v in row):
                raise ValueError(f"{path}:{line_no}: NaN or Inf")
            rows.append(row)
    if len(rows) != count:
        raise ValueError(f"{path}: expected exactly {count} rows, got {len(rows)} (partial/append?)")
    return rows


def read_results(folder):
    return {key: read_table(folder, *spec) for key, spec in TABLES.items()}


def cartesian_from_ladder(row):
    # Fortran's nine column-major complex <A_i B_j>, A,B ordered (z,-,+).
    z = [complex(row[2 + 2*k], row[3 + 2*k]) for k in range(9)]
    return [
        (z[8] + z[7] + z[5] + z[4]).real * .25,        # xx
        ((z[8] - z[7] + z[5] - z[4]) * (-.25j)).real,  # yx
        ((z[6] + z[3]) * .5).real,                      # zx
        ((z[8] + z[7] - z[5] - z[4]) * (-.25j)).real,  # xy
        ((z[8] - z[7] - z[5] + z[4]) * (-.25)).real,   # yy
        ((z[6] - z[3]) * (-.5j)).real,                 # zy
        ((z[2] + z[1]) * .5).real,                      # xz
        ((z[2] - z[1]) * (-.5j)).real,                 # yz
        z[0].real,                                     # zz
    ]


def check_physics(data, tolerance=2e-7):
    energy, mag, xyz, zpm = (data[k] for k in ("energy", "mag", "xyz", "zpm"))
    if energy[0][0] != 1:
        raise ValueError("Expected one ground-state energy with state index 1")
    for i, row in enumerate(mag, 1):
        if row[0] != i:
            raise ValueError(f"Local-magnetization site index error at {i}")
        if any(abs(x) > .5 + tolerance for x in row[1:]):
            raise ValueError(f"Spin-1/2 local-magnetization bound violated at site {i}")
        if abs(row[1]) > tolerance or abs(row[2]) > tolerance:
            raise ValueError(f"Fixed Sz sector has transverse magnetization at {i}")
    sz = math.fsum(row[3] for row in mag)
    if abs(sz - 497.0) > 1000.0 * tolerance:
        raise ValueError(f"Total Sz must be 1000/2-3=497, got {sz}")
    largest_identity_error = 0.0
    for i, (car, lad) in enumerate(zip(xyz, zpm), 2):
        if (car[:2] != [1.0, float(i)] or lad[:2] != [1.0, float(i)]):
            raise ValueError(f"Pair {i} must be (1,{i}) in both outputs")
        if any(abs(v) > .25 + tolerance for v in car[2:]):
            raise ValueError(f"Spin-1/2 Cartesian correlator bound violated at pair {i}")
        predicted = cartesian_from_ladder(lad)
        largest_identity_error = max(
            largest_identity_error,
            max(abs(x - y) for x, y in zip(car[2:], predicted)))
    if largest_identity_error > tolerance:
        raise ValueError(f"Ladder/Cartesian consistency discrepancy {largest_identity_error}")
    return {"ground_energy": energy[0][1], "total_Sz": sz,
            "max_ladder_cartesian_error": largest_identity_error}


def compare(actual, reference, energy_atol, observable_atol):
    differences = {}
    for name in TABLES:
        start = 1 if name in ("energy", "mag") else 2
        error = max(abs(a[k] - b[k])
                    for a, b in zip(actual[name], reference[name])
                    for k in range(start, len(a)))
        limit = energy_atol if name == "energy" else observable_atol
        differences[name] = {"max_abs_error": error, "atol": limit}
        if error > limit:
            raise ValueError(f"{name}: computed/archive difference {error} exceeds {limit}")
    return differences


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--reference", type=Path,
                        default=Path(__file__).resolve().parents[1] /
                        "examples/ref_data/cubic_sp_HB")
    parser.add_argument("--actual", type=Path,
                        help="Completed ex9 output directory; omit for archive-only validation")
    parser.add_argument("--energy-atol", type=float, default=1e-7)
    parser.add_argument("--observable-atol", type=float, default=1e-5)
    parser.add_argument("--json-out", type=Path)
    args = parser.parse_args()
    report = {"mode": "archive_only", "reference": str(args.reference.resolve())}
    try:
        if not (math.isfinite(args.energy_atol) and args.energy_atol > 0
                and math.isfinite(args.observable_atol) and args.observable_atol > 0):
            raise ValueError("Positive, finite tolerances required")
        ref = read_results(args.reference)
        report["reference_checks"] = check_physics(ref)
        if args.actual is not None:
            observed = read_results(args.actual)
            report["mode"] = "computed_vs_archive"
            report["actual"] = str(args.actual.resolve())
            report["observed_checks"] = check_physics(observed)
            report["comparison"] = compare(observed, ref, args.energy_atol, args.observable_atol)
        report["status"] = "PASS"
    except (OSError, ValueError) as error:
        report.update(status="FAIL", error=str(error))
    print(json.dumps(report, indent=2, sort_keys=True))
    if args.json_out is not None:
        args.json_out.parent.mkdir(parents=True, exist_ok=True)
        args.json_out.write_text(json.dumps(report, indent=2, sort_keys=True) + "\n")
    return 0 if report["status"] == "PASS" else 1


if __name__ == "__main__":
    raise SystemExit(main())
