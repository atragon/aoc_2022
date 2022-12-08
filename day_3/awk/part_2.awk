
BEGIN {
    prio = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
    count = 1;
}

count >= 1 && count <= 3 {
    racksack[count] = $0;
    count++;
}

count > 3 {
    # build a map of the first racksack
    for (i = 1; i <= length(racksack[1]); i++) {
        itemset[substr(racksack[1],i,1)] = 1;
    }    

    # find the intersection between the first and second racksack
    for(i = 1; i <= length(racksack[2]); i++) {
        c = substr(racksack[2],i,1);
        if (itemset[c] == 1 && index(matches, c) == 0) {
            matches = matches c;
        }
    }
    # if there is only one item in common between the first two
    # racksacs, then it is the one in common for all the three
    # (each group of three racksacks contains one and only one item.
    if (length(matches) == 1) {
        totprio += index(prio, matches);
    } else {
        # otherwise, find the intesection between racksack 3
        # and matches, stop at the first match as the definition
        # of the problem says that each group of three racksacks
        # share one and only one item.
        for(i = 1; i <= length(racksack[3]); i++) {
            c = substr(racksack[3],i,1);
            if (index(matches, c) != 0) {
                 totprio += index(prio, c);
                break;
            }
        }
    }
    
    count = 1;
    matches = "";
    delete racksack;
    delete itemset;
}

END{
    print totprio;
}
