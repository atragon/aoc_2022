
/^[0-9]+$/ {
    elfcalories += $0;
}

/^$/ {
    if (elfcalories > maxcal) {
        maxcal = elfcalories;
    }
    elfcalories = 0;
}

END {
    # last elf
    if (elfcalories > maxcal) {
        maxcal = elfcalories;
    }
    
    print maxcal;
}
