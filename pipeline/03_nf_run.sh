#!/usr/bin/bash -l
#SBATCH -p epyc -n 1 -N 1 -c 24 --mem 32gb --out logs/nf.log --time 3-0:0:0

module load singularity

nextflow run nf-core/rnaseq \
    --input samplesheet.csv \
    --outdir results/nf_rnaseq/$ID \
    --gtf genome/GCA_022478985.1_UCR_MCPNR19_1.0_genomic.gtf \
    --fasta genome/GCA_022478985.1_UCR_MCPNR19_1.0_genomic.fna \
    -profile singularity


