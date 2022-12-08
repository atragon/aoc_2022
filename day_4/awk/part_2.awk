{
    split($0, a, ",");
    split(a[1], b, "-");
    split(a[2], c, "-");

    # to calculate all the overlappint pairs, it is easier to calculate
    # those that don't overlap at all and substract their number from
    # the total number of pairs.
    if (b[1] < c[1] && b[2] < c[1] || c[1] < b[1] && c[2] < b[1]) {
        nooverlap += 1;
    }
}

END {
    print NR - nooverlap
}
