
BEGIN {
    val["X"] = 1;
    val["Y"] = 2;
    val["Z"] = 3;

    score["A","Z"] = score["B","X"] = score["C","Y"] = 0;
    score["A","X"] = score["B","Y"] = score["C","Z"] = 3;
    score["A","Y"] = score["B","Z"] = score["C","X"] = 6;
}

{ tot += val[$2] + score[$1,$2]; }

END { print tot; }
      

