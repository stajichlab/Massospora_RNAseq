#!/usr/bin/bash -l
#SBATCH -p short -c 16 --mem 16gb --out logs/transdecoder.%a.log -a 1 

module load transdecoder

module load workspace/scratch
module load diamond
module load db-diamond

INPUT=results/trinity
OUT=results/transdecoder
OUTB=results/BUSCO
SAMPFILE=samples.csv

mkdir -p $OUT $OUTB
CPU=2
if [ $SLURM_CPUS_ON_NODE ]; then
    CPU=$SLURM_CPUS_ON_NODE
fi
N=${SLURM_ARRAY_TASK_ID}
if [ -z $N ]; then
    N=$1
fi
if [ -z $N ]; then
    echo "cannot run without a number provided either cmdline or --array in sbatch"
    exit
fi
IFS=,
tail -n +2 $SAMPFILE | sed -n ${N}p | while read ID FILEBASE HOST SEX DATE LOCATION
do
    TRINITY=$INPUT/trinity_out_${ID}.Trinity.fasta
    TRINITY_MAP=$TRINITY.gene_trans_map
    BLASTP=$OUT/${ID}/longest_orfs.nr_cluster.BLASTP.tab
    mkdir -p $OUT/${ID}
    if [ ! -s $OUT/${ID}/longest_orfs.pep ]; then
        TransDecoder.LongOrfs -t $TRINITY --output_dir $OUT/${ID}
    fi
    if [ ! -d $OUTB/${ID} ]; then
	module load busco
    	busco -m prot -i $OUT/${ID}/longest_orfs.pep -o $OUTB/${ID} -c $CPU -l fungi_odb12
	module unload busco
    fi

    #if [[ -s $OUT/${ID}/longest_orfs.pep && ! -s $BLASTP ]]; then
    #    diamond blastp --db $DIAMOND_DB/nr_cluster --out $BLASTP \
    #    --query $OUT/${ID}/longest_orfs.pep \
    #    --mid-sensitive --max-target-seqs 2 --evalue 1e-5 --threads $CPU \
    #    --outfmt 6 qcovhsp scovhsp sscinames sskingdoms sphylums stitle     
    #fi
    #if [[ -s $BLASTP ]]; then
    #    TransDecoder.Predict -t $TRINITY --retain_blastp_hits $BLASTP --output_dir $OUT/${ID}
    #fi
done
