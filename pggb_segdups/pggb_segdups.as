table PGGB_SegDups
"Segmental Duplications Called In PGGB Pangenome"
    (
    string chrom;    "Genomic sequence name"
    uint chromStart;     "Start in genomic sequence"
    uint chromEnd;       "End in genomic sequence"
    char[1] strand;     "Relative orientation + or -"
    string target;       "CHM13 chromosome call aligns to"
    uint targetStart;     "CHM13 start of alignment"
    uint targetEnd;   "CHM13 end of alignment"
    float copy;     "Approximate number of copies of the SD in sample"
    float identity;     "Identity jaccard"
    )