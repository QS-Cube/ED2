#!/bin/sh
set -eu
exec "$(dirname "$0")/test_common.sh" \
  script_cubic_sp_HB \
  examples/cubic_sp_HB/output.dat \
  examples/cubic_sp_HB/eigenvalues.dat
