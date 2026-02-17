#!/bin/sh
set -eu
exec "$(dirname "$0")/test_common.sh" \
  script_chain \
  examples/chain/output.dat \
  examples/chain/eigenvalues.dat
