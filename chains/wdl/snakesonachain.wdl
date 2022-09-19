version 1.0

workflow create_browser_chains {
    input {
        File hal
        File input_pairs_tsv
    }

    Array[Array[String]] input_pairs = read_tsv(input_pairs_tsv)

    scatter (pair in input_pairs) {
        call create_bigchain {
            input:
                hal = hal,
                src_hap = pair[0],
                dst_hap = pair[1]
        }
    }

   output {
        Array[File] browser_bigchains  = create_bigchain.bigchain
        Array[File] browser_biglinks   = create_bigchain.biglink
    }

    meta {
        author: "Julian Lucas"
        email: "juklucas@ucsc.edu"
        description: "Produces n x n bigchains from a HAL for the UCSC browser"
    }

    parameter_meta {
        hal: "HAL file produced by CAT."
    }    
}


task create_bigchain {
    input {
        File hal
        String src_hap
        String dst_hap

        Int memSizeGB   = 16
        Int threadCount = 1
        Int addldisk    = 50
        Int preempts    = 2
    }

    # Estimate disk size required
    Int input_read_size  = ceil(size(hal, "GB"))       
    Int final_disk_dize   = input_read_size + addldisk

    # Create output file name
    String output_bigchain = "${src_hap}-to-${dst_hap}.bigChain.bb"
    String output_biglink  = "${src_hap}-to-${dst_hap}.bigLink.bb"

    command <<<
        set -eux -o pipefail


        ## Following: https://github.com/ComparativeGenomicsToolkit/hal/blob/chaining-doc/doc/chaining-mapping.md

        ## Extract the 2bit format sequences...
        hal2fasta \
            ~{hal} \
            ~{src_hap} \
            | faToTwoBit stdin ~{src_hap}.2bit

        hal2fasta \
            ~{hal} \
            ~{dst_hap} \
            | faToTwoBit stdin ~{dst_hap}.2bit

        ## Extract the source bed to liftover
        halStats --bedSequences \
            ~{src_hap} \
            ~{hal} \
            > ~{src_hap}.bed

        ## Actually perform the liftover (takes around 45min)
        halLiftover --outPSL \
            ~{hal} \
            ~{src_hap} \
            ~{src_hap}.bed \
            ~{dst_hap} \
            /dev/stdout \
            | pslPosTarget \
            stdin \
            ~{src_hap}-on-~{dst_hap}.psl  


        ## Chain the alignments together
        axtChain -psl \
            -linearGap=loose \
            ~{src_hap}-on-~{dst_hap}.psl \
            ~{dst_hap}.2bit \
            ~{src_hap}.2bit \
            ~{src_hap}-on-~{dst_hap}.chain


        ## create chrom.sizes file for destination genome
        twoBitInfo ~{dst_hap}.2bit stdout | sort -k2rn > ~{dst_hap}.chrom.sizes


        ## creates chain.tab and link.tab
        hgLoadChain \
            -noBin \
            -test \
            ~{src_hap} \
            bigChain \
            ~{src_hap}-on-~{dst_hap}.chain

        ## random rewrite
        sed 's/\.000000//' chain.tab \
            | awk 'BEGIN {OFS="\t"} {print $2, $4, $5, $11, 1000, $8, $3, $6, $7, $9, $10, $1}' \
            > ~{src_hap}-on-~{dst_hap}.bigChain


        ## update autosql file
        sed 's/uint chainScore/bigint chainScore/' /opt/bigChain.as > bigChain.as


        ## Create final bigChain file
        bedToBigBed \
            -type=bed6+6 \
            -as=bigChain.as \
            -tab ~{src_hap}-on-~{dst_hap}.bigChain \
            ~{dst_hap}.chrom.sizes \
            ~{output_bigchain}


        awk 'BEGIN {OFS="\t"} {print $1, $2, $3, $5, $4}' link.tab \
            | sort -k1,1 -k2,2n > bigChain.bigLink
        

        ## Create final bigLink file
        bedToBigBed \
            -type=bed4+1 \
            -as=/opt/bigLink.as \
            -tab bigChain.bigLink \
            ~{dst_hap}.chrom.sizes \
            ~{output_biglink} 

    >>>

    output {
        File bigchain = output_bigchain
        File biglink = output_biglink
    }

    runtime {
        memory: memSizeGB + " GB"
        cpu: threadCount
        disks: "local-disk " + final_disk_dize + " SSD"
        docker: "juklucas/snakesonachain:latest"
        preemptible: preempts
    }
}
