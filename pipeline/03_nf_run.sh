#!/usr/bin/bash -l
#SBATCH -p epyc -n 1 -N 1 -c 24 --mem 192gb --out logs/nf.newloc_eviann.log --time 3-0:0:0

module load singularity

nextflow run nf-core/rnaseq \
    --input samplesheet.csv  -resume -c ucr_hpcc.config \
    --outdir results/nf_rnaseq_newannot/ \
    --gtf genome/Massospora_cicadina.masked.fasta.new_label.gtf \
    --fasta genome/GCA_022478985.1_UCR_MCPNR19_1.0_genomic.fna \
    -profile singularity \
    --star_rsem --bam_csi_index --save_unaligned
    #--gff genome/Massospora_cicadina_MCPNR19.gff.gz \

#--gtf genome/GCA_022478985.1_UCR_MCPNR19_1.0_genomic.gtf \


