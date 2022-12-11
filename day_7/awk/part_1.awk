BEGIN {
    workdir = "";
}
# Assumptions:

# 1) the input always begin wit "cd /".

# 2) the "cd" changes directory by only one level, that is
# it is never "cd a/b" to change directory to "b" jumping
# over "a".

# 4) There is no need to process the entry beginning with "dir".
# The directory is relevant only if contains files, and we
# know that only when the directory is entered with "cd".

/^\$/{
    cmd = $2;
    if (cmd == "cd") {
        dir = $3;
        
        if (dir == "/") {
            workdir = "/";
        } else if (dir == "..") {
            workdir = dirname(workdir);
        } else {
            workdir = makepath(workdir,dir);
        }
    }
}

/^[0-9]/{
    addchild(workdir, $2, "f", $1);
}

/^dir/{
    addchild(workdir, $2, "d", 0);
}

END {
    calcdirsizes("/");
    printtree("/", 0);
    for (k in sizes) {
        if (types[k] == "d" && sizes[k] <= 100000) {
            totalsize += sizes[k];
        }
    }
    print totalsize;
}

function makepath(parent,child) {
    if (parent == "") {
        return "/";
    }
    if (parent == "/") {
        return child parent;
    }
    return child "/" parent;
}

function basename(dir) {
    if (dir != "/") {
        return substr(dir, 1, index(dir, "/") - 1);
    }
    return "/";
}

function dirname(dir) {
    if (dir != "/") {
        dir = substr(dir, index(dir, "/") + 1);
        if (dir == "") dir = "/";
    }
    return dir;
}

function addchild(parent, child, type, size,   k) {
    k = makepath(parent, child);
    if (!(k in parentship)) {
        parentship[k] = 1;
        nchildren[parent] += 1;
        children[parent, nchildren[parent]] = child;
        types[k] = type;
        sizes[k] = size;
    }
}

function calcdirsizes(dir,   i,n,chld,type,sz,parent) {
    n = nchildren[dir];
    sz = 0;
    for (i = 1; i <= n; ++i) {
        chld = children[dir, i];
        type = types[makepath(dir,chld)];
        if (type ==  "d") {
            sz += calcdirsizes(makepath(dir,chld));
        } else {
            sz += sizes[makepath(dir,chld)];
        }
    }
    sizes[dir] = sz;
    return sz;
}

function printtree(dir,indent,    i,j,n,chld,type,name,parent) {
    printf("%*s- %s (dir, size=%d)\n", indent, "", basename(dir), sizes[dir]);    
    n = nchildren[dir];
    for (i = 1; i <= n; ++i) {
        chld = children[dir, i];
        type = types[makepath(dir,chld)];
        if (type ==  "d") {
            printtree(makepath(dir,chld), indent + 4);
        } else {
            printf("%*s- %s (file, size=%d)\n", indent + 4, "", chld, sizes[makepath(dir,chld)]);
        }
    }
}
