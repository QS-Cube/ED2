#!/bin/sh
set -eu
exec "$(dirname "$0")/test_common.sh" \
  script_mixed_spin_chain \
  examples/mixed_spin_chain/output.dat \
  examples/mixed_spin_chain/eigenvalues.dat
