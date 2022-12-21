BEGIN {
    LEFT   = 0;
    RIGHT  = 1;
    TOP    = 2;
    BOTTOM = 3
}

NR == 1 {
    nx = length($0);
}

## Parses each input line and builds the grid.
## At the end of the processing of the lines, 'nx' will contain the
## number of trees in a row and 'ny' the number rows of trees in the
## grid
{
    ny++
    for (i = 1; i <= nx; ++i) {
        grid[i,ny] = substr($0,i,1);
    }
}

## Calculates the distance of every tree in 'row' in the grid to the next to the left
## and to the right that are of the same or greater height.
## Scans the row simultaneously from left (increasing x starting from 1) and from right
## (decreasing x starting from nx) and stores the "ledt' and right distances into the
## array 'dist' for each tree at 'x', row (coordinates are in 'column major' order).
function distance(row,      x, h, leftmostx, rightmostx, maxh, lastx, lasth, lastxh) {
    hbeg = grid[1, row];
    hend = grid[nx, row];
    
    maxh[LEFT] = hbeg;
    maxh[RIGHT] = hend;
    
    lastxh[LEFT, hbeg] = 1;
    lastxh[RIGHT, hend] = nx;

    lasth[LEFT] = hbeg;
    lasth[RIGHT] = hend;
    
    lastx[LEFT] = 1;
    lastx[RIGHT] = nx;

    for (i = 2; i < nx; ++i) {

        # ## scan from left
        x = i;
        h = grid[x, row];

        if (h > 0) {
            if (h <= lasth[LEFT]) {
                dist[LEFT, x, row] = x - lastx[LEFT];
            } else {
                rightmostx = 1;                
                for (k = h; k <= maxh[LEFT]; ++k) {
                    if (((LEFT,k) in lastxh) && lastxh[LEFT,k] > rightmostx) {
                        rightmostx = lastxh[LEFT,k];
                    }
                }
                dist[LEFT, x, row] = x - rightmostx;
            }
            
            if (h > maxh[LEFT]) {
                maxh[LEFT] = h;
            }
            
            lastxh[LEFT, h] = x;
            lastx[LEFT] = x;
            lasth[LEFT] = h
        } else {
            dist[LEFT, x, row] = 0;
        }

        ## scan from right
        x = nx - i + 1;
        h = grid[x, row];

        if (h > 0) {
            if (h <= lasth[RIGHT]) {
                dist[RIGHT, x, row] = lastx[RIGHT] - x;                
            } else {
                leftmostx = nx;                
                for (k = h; k <= maxh[RIGHT]; ++k) {
                    if (((RIGHT,k) in lastxh) && lastxh[RIGHT,k] < leftmostx) {
                        leftmostx = lastxh[RIGHT,k];
                    }
                }
                dist[RIGHT, x, row] = leftmostx - x;
            }

            if (h > maxh[RIGHT]) {
                maxh[RIGHT] = h;
            }
            
            lastxh[RIGHT, h] = x;
            lastx[RIGHT] = x;
            lasth[RIGHT] = h;
        } else {
            dist[RIGHT, x, row] = 0;
        }
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


## Calculates the pair of distances of all the trees in the grid.
function calcgriddistance(     j) {
    for (j = 2; j < ny; ++j) {
        distance(j);
    }
}

END {
    # Calculates the "left" and "right" distances for all the trees.
    calcgriddistance();


    # transpose the grid, so the columns become the rows. So we can
    # use the calcgriddistance() again.
    transposegrid();

    # Hack: changes the values of LEFT and RIGHT used by calcgriddistance()
    # so the stored distances are indexed by TOP and BOTTOM.
    LEFT = TOP;
    RIGHT = BOTTOM;
    calcgriddistance();
    
    maxscore = 0;

    # End of the Hack: restore the original values.
    LEFT = 0;
    RIGHT = 1;

    # Now, for each tree in the grid there are four distances; because we
    # transposed the grid for calculating the TOP AND BOTTOM distances,
    # the "TOP" and "BOTTOM" distances for tree (x, row) will be the
    # 'dist[TOP, row, x]' and 'dist[BOTTOM, row, x]';
    
    for (j = 2; j < ny; ++j) {
        
        for (i = 2; i < nx; ++i) {
            
            ld = dist[LEFT, i, j];
            rd = dist[RIGHT,i, j];
            td = dist[TOP, j, i];
            bt = dist[BOTTOM, j, i];

            score = ld * rd * td * bt;
            if (score > maxscore) {
                maxscore = score;
            }
            printf("Left DIST[%d,%d]=%4s -- Right DIST[%d,%d]=%4s -- Top DIST[%d,%d]=%4s -- Bottom  DIST[%d,%d]=%4s\n",
                   i,j,ld,i,j,rd,i,j,td,i,j,bt);
        }
    }

    # result
    print maxscore;
}
