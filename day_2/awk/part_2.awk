
BEGIN {
    val["X"] = 1;
    val["Y"] = 2;
    val["Z"] = 3;

    score["A","Z"] = score["B","X"] = score["C","Y"] = 0;
    score["A","X"] = score["B","Y"] = score["C","Z"] = 3;
    score["A","Y"] = score["B","Z"] = score["C","X"] = 6;

    map["A", "Y"] = map["B", "X"] = map["C", "Z"] = "X";
    map["A", "Z"] = map["B", "Y"] = map["C", "X"] = "Y";
    map["A", "X"] = map["B", "Z"] = map["C", "Y"] = "Z";
}

{ tot += val[map[$1,$2]] + score[$1,map[$1,$2]]; }

END { print tot; }



