#!/bin/sh
set -eu
exec "$(dirname "$0")/test_common.sh" \
  script_kagome \
  examples/kagome/output.dat \
  examples/kagome/eigenvalues.dat
