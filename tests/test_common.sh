#!/bin/sh
set -eu

# Wrapper for isolated and in-tree example execution checks.
# Both modes check files and finite energy syntax, not reference accuracy.

script_dir="$1"
out_rel="$2"
eig_rel="$3"

# Resolve repository top (cwd-independent)
if [ -n "${TOPDIR:-}" ]; then
  top="$TOPDIR"
else
  top=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
fi

# Resolve ED2 executable (PATH-independent)
if [ -n "${ED2_EXE:-}" ]; then
  ed2="$ED2_EXE"
else
  ed2="$top/source/QS3ED2"
fi

# Default mode: delegate to the isolated example runner.
if [ "${LONGTEST:-0}" != "1" ]; then
  exec "$(dirname "$0")/test_common_strict.sh" "$@"
fi

# -------------------- relaxed mode for check-long --------------------
# Run the example
( cd "$top/$script_dir" && TOPDIR="$top" ED2_EXE="$ed2" ./run.sh )

out="$top/$out_rel"
eig="$top/$eig_rel"

# Sanity checks: files exist and are non-empty
[ -s "$out" ] || { echo "ERROR: missing/empty output file: $out" >&2; exit 1; }
[ -s "$eig" ] || { echo "ERROR: missing/empty eigenvalues file: $eig" >&2; exit 1; }

awk -f "$top/tests/check_eigenvalues.awk" "$eig" || exit 1
e0=$(awk 'NR==1{print $2; exit}' "$eig")

echo "OK (LONGTEST): $script_dir generated outputs (E0=$e0)"
exit 0
