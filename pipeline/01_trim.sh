#!/usr/bin/bash -l
#SBATCH -p short -c 16 --mem 16gb --out logs/trim.%a.log

module load workspace/scratch
module load fastp
INPUT=rnaseq
SAMPFILE=samples.csv
WORK=working
mkdir -p $WORK
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
    LEFT=$INPUT/${FILEBASE}_L001_R1_001.fastq.gz
    RIGHT=$INPUT/${FILEBASE}_L001_R2_001.fastq.gz
    echo "$LEFT and $RIGHT for sample $ID -> $INPUT/$FILEBASE"
    if [ ! -s $WORK/${ID}_R1.fq.gz ]; then
        fastp -w $CPU --trim_poly_g --trim_poly_x -j logs/$ID.json -h logs/$ID.html \
            -i $LEFT -I $RIGHT -o $WORK/${ID}_R1.fq.gz --out2 $WORK/${ID}_R2.fq.gz \
            --unpaired1 $WORK/${ID}_U1.fq.gz --unpaired2 $WORK/${ID}_U2.fq.gz --overrepresentation_analysis
    fi
done
