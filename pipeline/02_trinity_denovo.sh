#!/usr/bin/bash -l
#SBATCH -p epyc --mem 256gb -N 1 -n 1 -c 32 --out logs/trinity.%a.log -a 1

MEM=256G
module load trinity-rnaseq
module load workspace/scratch
INPUT=rnaseq
SAMPFILE=samples.csv
WORK=working
OUT=results/trinity

mkdir -p $OUT
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
    LEFT=$WORK/${ID}_R1.fq.gz
    RIGHT=$WORK/${ID}_R2.fq.gz

    if [ ! -f $OUT/${ID} ]; then
        Trinity --CPU $CPU --jaccard_clip  --seqType fq --SS_lib_type RF \
        --left $LEFT --right $RIGHT --max_memory $MEM --output $OUT/trinity_out_${ID}
    fi
done