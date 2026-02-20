#!/bin/sh
set -eu

# Usage:
#   test_common.sh <script_dir_name> <expected_output_relpath1> [<expected_output_relpath2> ...]
#
# Example:
#   test_common.sh script_chain examples/chain/output.dat examples/chain/eigenvalues.dat

SCRIPT_DIR="$1"
shift

# Repo top (where this script lives is <top>/tests/)
TOPDIR=$(cd "$(dirname "$0")/.." && pwd)

# Built executable (do not rely on PATH)
EXE="$TOPDIR/source/QS3ED2"
if [ ! -x "$EXE" ]; then
  echo "ERROR: executable not found: $EXE"
  echo "Hint: run 'make' first."
  exit 1
fi

# Determinism / avoid nested threading
export OMP_NUM_THREADS="${OMP_NUM_THREADS:-1}"
export MKL_NUM_THREADS="${MKL_NUM_THREADS:-1}"
export OPENBLAS_NUM_THREADS="${OPENBLAS_NUM_THREADS:-1}"

# Respect FC if provided by user/build environment
: "${FC:=ifort}"

TMPDIR="$(mktemp -d)"
trap 'rm -rf "$TMPDIR"' EXIT INT TERM

# Prepare sandbox with repo-like layout
mkdir -p "$TMPDIR/ED2"
cp -a "$TOPDIR/$SCRIPT_DIR" "$TMPDIR/ED2/"
cp -a "$TOPDIR/input"       "$TMPDIR/ED2/"

# Run inside sandbox
cd "$TMPDIR/ED2/$SCRIPT_DIR"

ED2_EXE="$EXE" FC="$FC" ./run.sh > test.log 2>&1 || {
  echo "===== ${SCRIPT_DIR}/run.sh failed; last 200 lines ====="
  tail -n 200 test.log || true
  exit 1
}

# Minimal success criteria: expected outputs exist and are non-empty
for f in "$@"; do
  if [ ! -s "$TMPDIR/ED2/$f" ]; then
    echo "ERROR: expected output missing/empty: $f"
    echo "===== log tail ====="
    tail -n 200 test.log || true
    exit 1
  fi
done

echo "OK: ${SCRIPT_DIR} passed."
