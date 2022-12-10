BEGIN {
    workdir = "";
    pardir = "";
}
# Assumptions:

# 1) the input always begin wit "cd /".

# 2) the "cd" changes directory by only one level, that is
# it is never "cd a/b" to change directory to "b" jumping
# over "a".

# 3) There is no need to process the "ls" command because the
# current dir is tracked and so we know that the list of
# lines beginning with a number belong to the current dir.

# 4) There is no need to process the entry beginning with "dir".
# The directory is relevant only if contains files, and we
# know that only when the directory is entered with "cd".

# Simulate the tree by storing the directories that are leaves
# and storing the parent of each directory, so to form paths
# from each leave to the "/".

/^\$/{
    cmd = $2;
    if (cmd == "cd") {
        dir = $3;
        if (dir == "/") {
            workdir = "/";
            leaves[workdir] = 1;
        } else if (dir == "..") {
            # no need to store the dir because we must have already
            # "cd-ed" into it before.
            workdir = substr(workdir, index(workdir,SUBSEP) + 1);
        } else {
            pardir = workdir;
            # store the path in the reverse order.            
            workdir = dir SUBSEP workdir;
            parentdirs[workdir] = pardir;
            leaves[workdir] = 1;
            # pardir is not a leave anymore
            delete leaves[pardir];
        }
    }
}

/^[0-9]/ {
    sizes[workdir] += $1;
}

END {
    # from each directory leave, traverse the parent links
    # adding up the directory sizes.
    for (l in leaves) {
        sz = sizes[l];
        while ((pdir = parentdirs[l]) != "") {
            sizes[pdir] += sz;
            sz = sizes[pdir];
            l = pdir;
        }
    }
    for (s in sizes) {
        sz = sizes[s];
        if (sz <= 100000) {
            totsize += sz;
        }
    }
    print totsize;
}
