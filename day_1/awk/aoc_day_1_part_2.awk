BEGIN {
    top3[1] = 0;
    top3[2] = 0;
    top3[3] = 0;
}

/^[0-9]+$/ {
    elfcalories += $0;
}

/^$/ {
    sort();
    elfcalories = 0;
}

END {
    # last elf
    sort();
    print top3[1] + top3[2] + top3[3];
}

function sort() {
    if (elfcalories > top3[1]) {

        top3[3] = top3[2];
        top3[2] = top3[1];
        top3[1] = elfcalories;
        
    } else if (elfcalories > top3[2]) {
        top3[3] = top3[2];
        top3[2] = elfcalories;
        
    } else if (elfcalories > top3[3]) {
        top3[3] = elfcalories;
    }
}
