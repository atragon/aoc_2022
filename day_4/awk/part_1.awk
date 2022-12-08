{
    split($0, a, ",");
    split(a[1], b, "-");
    split(a[2], c, "-");
    # print b[1] " " b[2] " " c[1] " " c[2];
    
    if (b[1] <= c[1] && b[2] >= c[2] || c[1] <= b[1] && c[2] >= b[2]) {
        overlap += 1;
    }
}

END {
    print overlap
}
