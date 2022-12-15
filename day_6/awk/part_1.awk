BEGIN {
    
    LEN = 4;
    if (getline buf > 0) {

        # use a four character buffer to keep the current
        # LEN characters to process. The buffer is changed
        # by removing the oldest character and inserting the
        # new one. Achieve this by using an always-full circular
        # queue where the tail points at both the oldest character
        # and at the position where the new one needs to be put.

        # keep a counting map of the characters in the queue; if
        # the count of a character goes to zero then remove the
        # character from the map. As soon as the length of the map
        # reaches LEN the queue contains all different characters.
        
        tail = 1;
        for (bufpos = tail; bufpos <= LEN; bufpos++) {
            ch = substr(buf, bufpos, 1);
            charset[ch]++;
            queue[bufpos] = ch;
        }
        
        print queuechars() "   " charsetchars();
        
        n = length(buf);
        while (bufpos <= n && length(charset) < LEN) {

            # remove oldest character
            deletion = queue[tail];
            charset[deletion]--;
            if (charset[deletion] == 0) delete charset[deletion];

            # insert new character
            ch = substr(buf, bufpos++, 1);            
            queue[tail] = ch;
            charset[ch]++;

            # wrap queue tail
            if (++tail > LEN) tail = 1;

            print queuechars() "   " charsetchars();
        }
        
        # that's the result, one less the counter of the buf.
        print bufpos - 1;
    }
}

function queuechars(  i,s) {
    for (i = tail; i <= LEN; ++i) {
        s = s queue[i];
    }
    for (i = 1; i < tail; ++i) {
        s = s queue[i];
    }
   return s;
}

function charsetchars(  i,s) {
    for (k in charset) {
        s = s " " sprintf("%s=%d", k, charset[k]);
    }
    return s;
}
