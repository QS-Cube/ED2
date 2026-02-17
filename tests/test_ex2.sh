#!/bin/sh
set -eu
exec "$(dirname "$0")/test_common.sh" \
  script_j1j2_chain \
  examples/j1j2_chain/output.dat \
  examples/j1j2_chain/eigenvalues.dat
