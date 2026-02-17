#!/bin/sh
set -eu
exec "$(dirname "$0")/test_common.sh" \
  script_cubic \
  examples/cubic/output.dat \
  examples/cubic/eigenvalues.dat
