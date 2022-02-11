table rmskBed
"RepeatMasker"
    (
    string contig;    "Genomic sequence name"
    uint start;     "Start in genomic sequence"
    uint end;       "End in genomic sequence"
    string family;     "TE Family Name"
    uint score;       "Raw score from RepeatMasker"
    char[1] strand;     "Relative orientation + or -"
    string class;   "RepeatMasker Class"
    string subclass;     "RepeatMasker subclass or undefined"
    float divergence;     "Kimura divergence from *.align file"
    int linkageId;      "linkage id from repeatmaster"
    )