#!/bin/sh
set -eu

# Wrapper for strict/relaxed testing.
# - default (make check): strict comparison via test_common_strict.sh
# - LONGTEST=1 (make check-long): relaxed mode (no strict diff; only sanity)

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

# Strict mode: delegate to the original script untouched
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

# Minimal parse check: first token in eigenvalues.dat looks like a number
e0=$(awk 'NR==1{print $1; exit}' "$eig" 2>/dev/null || true)
case "$e0" in
  ""|*[!0-9eE+.-]*)
    echo "ERROR: failed to parse numeric E0 from $eig (got: '$e0')" >&2
    exit 1
    ;;
esac

echo "OK (LONGTEST): $script_dir generated outputs (E0=$e0)"
exit 0
