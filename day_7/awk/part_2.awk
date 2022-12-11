BEGIN {
    workdir = "";
    TOTALSPACE = 70000000;
    SPACENEEDED = 30000000;
}
# Assumptions:

# 1) the input always begin wit "cd /".

# 2) the "cd" changes directory by only one level, that is
# it is never "cd a/b" to change directory to "b" jumping
# over "a".

# 3) There is no need to process the "ls" command. The current
#    dir is tracked by 'workdir' so the entries beginning with
#    'dir' and a number are added as children to the 'workdir'.

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
    #printtree("/", 0);
    needtofree = SPACENEEDED - (TOTALSPACE - sizes["/"]);
    found = bsearch(dirsizes, needtofree);
    if (found < 0) {
        found = -found; # found is negative.        
    }

    # the size at position 'found' is either equal or
    # greater than 'needtofree'. In either case we
    # look up for a smaller size that is equal or
    # greater than 'needtofree'.
    currsize = dirsizes[found];
    for (i = found - 1; i >= 1; --i) {
        # if this size is to small then stop.
        if (dirsizes[i] < needtofree) {
            break;
        }
        currsize = dirsizes[i];
    }
    print currsize;
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

function calcdirsizes(dir,   i,n,chld,type,sz) {
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
    insert(dirsizes, sz)
    return sz;
}

function printtree(dir,indent,    i,n,chld,type) {
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

function insertat(arr, e, pos) {
     len = length(arr);
    arr[len + 1] = e;
    # avoid the inserting code, if e needs just
    # to be appended
    if (pos <= len) {
        reverse(arr, pos);
        reverse(arr, pos + 1);
    }
}

function reverse(a,pos,   l,r,t) {
    l = pos;
    r = length(a);

    while (l < r) {
        t = a[l];
        a[l] = a[r];
        a[r] = t;
        l++;
        r--;
    }
}
function insert(a, e,   pos) {
    len = length(a);

    if (len == 0) {
        a[1] = e;
        return;
    }

    pos = bsearch(a, e);
    if (pos < 0) pos = -pos;
    insertat(a, e, pos);
}

# if e is in the array, its index is returned.
# if e is not in the array, the index at which
# it should be inserted is returned, with
# negative sign.
function bsearch(a, e,   len,l,r,mid) {
    
    len = length(a);
    if (len == 0) return -1;
    
    l = 1; r = len; 
    while(l <= r) {
        mid = l + int((r - l)/2);

        if (e < a[mid]) {
            r = mid - 1;
        } else if (e > a[mid]) {
            l = mid + 1;
        } else {
            return mid;
        }
    }
    return -l;
}
