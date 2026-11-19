# Require a positive state index and a finite, ordinary real energy on each row.
# This is a format/finite-value check, not a numerical reference comparison.
BEGIN { rows = 0 }
NF {
    if (NF != 2 || $1 !~ /^[1-9][0-9]*$/ ||
        $2 !~ /^[+-]?([0-9]+([.][0-9]*)?|[.][0-9]+)([eEdD][+-]?[0-9]+)?$/) {
        print "ERROR: invalid eigenvalue row " NR ": " $0 > "/dev/stderr"
        bad = 1
        exit 1
    }
    rows++
}
END { if (bad || rows == 0) exit 1 }
