#!/usr/bin/env nextflow

params.reference = 'contigs.fa'
params.r1_reads = 'HiC-reads_R1.fastq.gz'
params.r2_reads = 'HiC-reads_R2.fastq.gz'
params.enzyme = 'GATC'

reference_file = file(params.reference)
r1_reads = file(params.r1_reads)
r2_reads = file(params.r2_reads)

reads_channel = Channel.from(r1_reads, r2_reads)

process bwa_index {
    module 'bwa/0.7.17'
    clusterOptions '-l ncpus=4 -l mem=16G -l storage=gdata/xl04+scratch/xl04 -l jobfs=20GB'
    time '1h'

    publishDir 'bwa_index'

    input:
    file reference from reference_file

    output:
    file "${reference}.*" into genome_index

    """
    bwa index ${reference}
    """
}

process fasta_index {
    module 'samtools/1.12'
    clusterOptions '-l ncpus=2 -l mem=8G -l storage=gdata/xl04+scratch/xl04 -l jobfs=10GB'
    time '30m'

    input:
    file reference from reference_file

    output:
    file "${reference}.fai" into faidx

    "samtools faidx ${reference}"
}

process bwa_mem {
    module 'bwa/0.7.17:samtools/1.12:pythonpackages/3.7.4'
    clusterOptions '-l ncpus=16 -l mem=64G -l storage=gdata/xl04+scratch/xl04 -l jobfs=100GB'
    time '12h'

    input:
    file ref from reference_file
    file index from genome_index
    file reads from reads_channel

    output:
    file 'out.bam' into mapped

    """
    bwa mem -t 16 ${ref} ${reads} | samtools view -bh - | \
        filter_chimeras.py - > out.bam
    """
}

filtered_pairs = mapped.buffer(size: 2)

process combine {
    module 'samtools/1.12:pythonpackages/3.7.4'
    clusterOptions '-l ncpus=2 -l mem=8G -l storage=gdata/xl04+scratch/xl04 -l jobfs=20GB'
    time '1h'
    publishDir 'alignments'

    input:
    file 'r?.bam' from filtered_pairs

    output:
    file 'combined.bam' into combinedbam

    """
    combine_ends.py r1.bam r2.bam | samtools fixmate -m - - \
        | samtools sort - | samtools markdup -r - combined.bam
    """
}

process bam2bed {
    module 'bedtools/2.28.0'
    clusterOptions '-l ncpus=2 -l mem=8G -l storage=gdata/xl04+scratch/xl04 -l jobfs=20GB'
    time '1h'
    publishDir 'alignments'

    input:
    file 'combined.bam' from combinedbam

    output:
    file 'combined.bed' into combinedbed

    """
    bedtools bamtobed -i combined.bam | sort -k 4 > combined.bed
    """
}

process salsa {
    module 'python2packages/2.7.17:salsa/v0.1'
    clusterOptions '-l ncpus=4 -l mem=16G -l storage=gdata/xl04+scratch/xl04 -l jobfs=50GB'
    time '6h'
    publishDir 'salsa_out', mode: 'move'

    input:
    file 'ref.fa' from reference_file
    file 'ref.fa.fai' from faidx
    file 'combined.bed' from combinedbed

    output:
    file 'salsa/*' into salsa_out

    """
    python2 run_pipeline.py -a ref.fa -l ref.fa.fai \
        -b combined.bed -e ${params.enzyme} -o salsa -m yes -i 10 -p yes
    """
}
