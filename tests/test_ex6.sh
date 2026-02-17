#!/bin/sh
set -eu
exec "$(dirname "$0")/test_common.sh" \
  script_honeycomb \
  examples/honeycomb/output.dat \
  examples/honeycomb/eigenvalues.dat
