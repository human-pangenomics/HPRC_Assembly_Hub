table SegDups
"SEDEF Segmental Dups"
    (
    string chrom;    "Genomic sequence name mate 1"
    uint chromStart;     "Start in genomic sequence mate 1"
    uint chromEnd;       "End in genomic sequence mate 1"
    string name;     "SD name"
    uint score;       "Total alignment error"
    char[1] strand;     "1st SD mate strand"
    string chrom2;   "Genomic sequence name mate 2"
    uint chromStart2;     "Start in genomic sequence mate 2"
    uint chromEnd2;     "End in genomic sequence mate 2"
    char[1] strand2;      "2nd SD mate strand"
    )