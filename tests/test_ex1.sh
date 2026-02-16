#!/bin/sh
set -eu

# Repo top (where this script lives is <top>/tests/)
TOPDIR=$(cd "$(dirname "$0")/.." && pwd)

# Built executable (do not rely on PATH)
EXE="$TOPDIR/source/QS3ED2"
if [ ! -x "$EXE" ]; then
  echo "ERROR: executable not found: $EXE"
  echo "Hint: run 'make' first."
  exit 1
fi

# Make test deterministic and light
export OMP_NUM_THREADS=1
export MKL_NUM_THREADS=1
export OPENBLAS_NUM_THREADS=1

TMPDIR="$(mktemp -d)"
trap 'rm -rf "$TMPDIR"' EXIT INT TERM

# ---------------------------------------------------------------------
# The example scripts assume a repo-like layout:
#   <root>/script_chain
#   <root>/input/input.dat
# and they write outputs under <root>/examples/...
# So we create a minimal sandbox with the same structure.
# ---------------------------------------------------------------------
mkdir -p "$TMPDIR/ED2"
cp -a "$TOPDIR/script_chain" "$TMPDIR/ED2/"
cp -a "$TOPDIR/input"       "$TMPDIR/ED2/"

# Run inside the sandbox
cd "$TMPDIR/ED2/script_chain"

# Use the same compiler family as the build (important)
# (Override if needed: FC=ifort make check)
: "${FC:=ifort}"

ED2_EXE="$EXE" FC="$FC" ./run.sh > test.log 2>&1 || {
  echo "===== run.sh failed; showing last 200 lines of log ====="
  tail -n 200 test.log || true
  exit 1
}

# Minimal success criteria: key outputs exist and are non-empty
test -s "$TMPDIR/ED2/examples/chain/output.dat"
test -s "$TMPDIR/ED2/examples/chain/eigenvalues.dat"

# Light sanity check: first token in eigenvalues.dat looks numeric
head -n 1 "$TMPDIR/ED2/examples/chain/eigenvalues.dat" | grep -E '[-+0-9\.Ee]+' >/dev/null

echo "OK: ex1 smoke test passed."
