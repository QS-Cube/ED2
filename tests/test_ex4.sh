#!/bin/sh
set -eu
exec "$(dirname "$0")/test_common.sh" \
  script_square \
  examples/square/output.dat \
  examples/square/eigenvalues.dat
