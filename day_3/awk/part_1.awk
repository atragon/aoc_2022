
BEGIN {
    prio = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
}

{
    len = length($0);
    mid = len/2;
    for (i = 1; i <= mid; i++) {
        itemset[substr($0,i,1)] = 1;
    }

    for(i = mid + 1; i <= len; i++) {
        c = substr($0,i,1);
        if (itemset[c] == 1) {
            totprio += index(prio, c);
            break;
        }
    }
    delete itemset;
}

END{
    print totprio;
}
