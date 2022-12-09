BEGIN {
    readstack = 1;
}


readstack == 1 {
    #collect the first part describing the initial stacks
    stacklines[NR] = $0;
}

/^$/ {
    readstack = 0;
    # the line NR - 1 is the one including the numbering
    # of the stacks. Use it to know how many they are.
    numberline = stacklines[NR-1];
    split(numberline, a, " ");
    nstacks = length(a);
    maxdepth = NR - 2;

    # fill up the stacks; starts from the line just above
    # the numbers. The  elements of the first stack are
    # two spaces from the beginning of the line, the rest
    # are spaced every four spaces.
    for (l = 0; l < maxdepth; l++) {
        pos = 2;
        line = stacklines[maxdepth - l];
        for (i = 1; i <= nstacks; i++) {
            elem = substr(line, pos, 1);
            if (elem != " ") {
                top = l + 1;
                stacks[i, top] = elem;
                stacktops[i] = top;
            }
            pos += 4;
        }
    }
    printstacks();
    next;
}

readstack == 0 {
    nelems = $2;
    src = $4;
    dst = $6;

    for (n = 0; n < nelems; n++) {
        srctop = stacktops[src];
        e = stacks[src, srctop];
        
        dsttop = stacktops[dst] + 1;
        stacks[dst, dsttop] = e;
        stacktops[src] = srctop - 1;
        stacktops[dst] = dsttop;
        
        delete stacks[src, srctop];
    }
    printstacks();

    #printf("Move %d from %d to %d\n", n, from, to);
}


function printstacks(    i,depth,row) {

    # build the output from the bottom to the
    # top  Stop when a complete empty line is
    # built. Print the lines in the reverse order.
    depth = 0;

    do {
        row = "";
        depth++;        
        for (i = 1; i < nstacks; i++) {
            if ((i,depth) in stacks) {
                row = row "[" stacks[i,depth] "]";
            } else {
                row = row "   ";
            }
            row = row " ";
        }

        if ((i,depth) in stacks) {
            row = row "[" stacks[i,depth] "]";
        } else {
            row = row "   ";
        }
        outputlines[depth] = row;

    } while(match(row, /[A-Z]/) != 0);

    for (i = depth - 1; i >= 1; i--) {
        print outputlines[i];
    }
    print numberline;
    print "";
}

function printstacktops() {
    for (i = 1; i <= nstacks && stacktops[i] > 0; i++) {
        output = output  stacks[i, stacktops[i]];
    }
    print output;
}

END {
    print "";
    printstacks();
    printstacktops();
}
      
