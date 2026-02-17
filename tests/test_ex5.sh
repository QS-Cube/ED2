#!/bin/sh
set -eu
exec "$(dirname "$0")/test_common.sh" \
  script_triangular \
  examples/triangular/output.dat \
  examples/triangular/eigenvalues.dat
