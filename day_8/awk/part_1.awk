## Parses each input line and builds the grid.
{
    nx = length($0);
    ny++
    for (i = 1; i <= nx; ++i) {
        grid[i,ny] = substr($0,i,1);
    }
}

END {
    #printgrid();
    
    # first find the trees that are visible either from the left or from the right.
    findvisibletrees();

    # then, find the trees that are visible either from the top or from the bottom.
    # to do that, transpose the grid and run call 'findvisibletrees' again.
    # the 'swapxy' is set to make the functions 'maketreevisible' and maketreehidden'
    # aware whether they are using the original grid or its transpose.
    transposegrid();
    swapxy = 1;
    findvisibletrees();
    
    alreadyvisible = (nx + ny - 2) * 2;
    print alreadyvisible;
    print length(visible);

    # this is the solution.
    print alreadyvisible + length(visible);
}

## Makes the tree at position 'x' and 'y' visible by increasing its
## visibility count by one.
function maketreevisible(x,y,     a,b) {
    if (swapxy) {
        b = x;
        a = y;
    } else {
        a = x;
        b = y;
    }
    visible[a,b]++;
}

## Decreases the visibility count of the tree at position 'x' and 'y' by one;
## it the count goes to 0 or below, then it is deleted from the array, making
## the tree hidden.
function maketreehidden(x,y,    a,b) {
    if (swapxy) {
        b = x;
        a = y;
    } else {
        a = x;
        b = y;
    }
    visible[a,b]--;
    if (visible[a,b] <= 0) {
        delete visible[a,b];
    }
}

## Finds the visible trees in the whole grid.
function findvisibletrees() {
    for (row = 2; row < ny; ++row) {
        for (x = 2; x < nx; ++x) {
            insert(treeheights, x, row)
        }
        findvisibletreesinarow(treeheights, row, 1, nx);
        delete treeheights;
    }
}


## Finds the visible trees in the row of the grid specified by 'y'.
## 'x1' and 'x2' is the interval to search, and 'treeheights' is an
## array containing the heights of the trees in the interval, in
## descending order.
## Algorithm:
## 1) take the first element of the 'treeheights' array, which is the
##    'x' grid coordinate of line 'y' of the tallest tree in the interval.
## 
## 2) Split the 'treeheight' array into two arrays, 'left' and 'right';
##    left containing the tree heights of the interval to the left of 'x'
##    and right containing the tree heights to the right of 'x'.
##
## 3) If the height 'h' of the tree at position 'x' is "potentially" visible
##    from the left edge (its height is greater than the one of the leftmost
##    tree) mark it visible. If 'h' is greater than the height of the tree
##    at position 'x2' (the tree at the right end of the interval) then mark
##    the tree at position 'x2' hidden. The tree at position 'x2' will be
##    the righmost tree, which is always visible, if this is the first call
##    to the function for the grid line; This does not affect the calculation
##    of the total number of visible trees because the trees at the edges can
##    only be made hidden and so they will not included in the total count.
##    The tree at 'x' can be "potentially" visible because there could be
##    another tree on its left that has the same height (cannot be taller
##    because the heights in 'treeheights' are in descending order) that hides
##    the tree at 'x', in which case the tree at 'x' will be hidden in the
##    next call to the fuction.
##
## 4) Call the function recursively by passing the 'left' array of tree
##    heights with the interval narrowed to 'x1' 'x'.
##
## 5) and 6) are the same processing as for 3) and 4) applied to the interval
##    to the right of 'x'.
##
##    The algorithm stops when there are no more tree heights to process.
##
##    The visibility of a tree is tracked by the 'visible' associative array;
##    each time a tree is discovered to be visible from some direction, its
##    visibility count is increased by 1. If a tree is discovered to be
##    hidden, then its visibility count is decreased by one; if the count
##    reaches 0 or below, it is removed from the array. At the end, the
##    length of the array will give the number of the visible trees (excluding
##    the trees on the edge).

function findvisibletreesinarow(treeheights, y, x1, x2,    n,i,x,h,left,right) {
    
    n = length(treeheights);
    if (n > 0) {

        x = treeheights[1];
        h = grid[x,y];

        for (i = from + 1; i <= n; ++i) {
            if (treeheights[i] < x) {
                insert(left, treeheights[i], y);
            } else if (treeheights[i] > x) {
                insert(right, treeheights[i], y);
            }
        }
        
        if (h > grid[x1, y]) {
            maketreevisible(x,y);
            if (h == grid[x2, y]) {
                maketreehidden(x2,y);
            }
            findvisibletreesinarow(left, y, x1, x);
            delete left;
        }
        
        if (h > grid[x2, y]) {
            maketreevisible(x,y);
            if (h == grid[x1, y]) {
                maketreehidden(x1,y);
            }
            findvisibletreesinarow(right, y, x, x2);
            delete right;
        }
    }    
}

## Prints the whole grid
function printgrid() {
    for(y = 1; y <= ny; ++y) {
        for (x = 1; x <= nx; ++x) {
            printf(" %s", grid[x,y]);
        }
        print "";
    }
}

## Transpose the grid, so the same code that processes the grid
## by row can be used to process the columns.
function transposegrid(   x,y,startx,tmp) {
    startx = 0;
    if (nx == ny) {
        for (y = 1; y<= ny; ++y) {
            for (x = ++startx; x <= nx; ++x) {
                tmp = grid[x,y];
                grid[x,y] = grid[y,x];
                grid[y,x] = tmp;
            }
        }
    }
}

## Here is code for inserting into an associative array in sorted, descending order.
## It is used to build an array of the tree heights of a single grid line, from the
## tallest to the shorter.
function insertat(a, key,  pos) {
    len = length(a);
    a[len + 1] = key;
    # avoid the inserting code, if e needs just
    # to be appended
    if (pos <= len) {
        reverse(a, pos);
        reverse(a, pos + 1);
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

function insert(a, x, y,   pos) {
    len = length(a)

    if (len == 0) {
        a[1] = x;
        return;
    }

    pos = bsearch(a, x, y);
    if (pos < 0) pos = -pos;
    insertat(a, x, pos);
}

function bsearch(a, x, y,   len,l,r,mid,e,v) {
    
    len = length(a);
    if (len == 0) return -1;
    
    l = 1; r = len;
    e = grid[x, y];
    while(l <= r) {
        mid = l + int((r - l)/2);
        v = grid[a[mid], y];
        if (e > v) {
            r = mid - 1;
        } else if (e < v) {
            l = mid + 1;
        } else {
            return mid;
        }
    }
    return -l;
}

