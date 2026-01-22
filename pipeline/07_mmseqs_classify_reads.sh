#!/usr/bin/bash -l
#SBATCH -c 64 -N 1 -n 1 --mem 512gb --out logs/mmseqs.%a.log

#-p exfab --gres gpu:1
#--mem 512gb --out logs/mmseqs.%a.log

CPU=$SLURM_CPUS_ON_NODE
if [ -z $CPU ]; then
	CPU=2
fi
N=1
if [ ! -z $SLURM_ARRAY_TASK_ID ]; then
	N=$SLURM_ARRAY_TASK_ID
elif [ ! -z $1 ]; then
	N=$1
fi
module load mmseqs2
which mmseqs

OUT=results/bbsplit_mmseqs_classify
IN=results/bbsplit
mkdir -p $OUT

DB=/srv/projects/db/ncbi/mmseqs/nr
for FILE in $(ls $IN/*.fq.gz | sed -n ${N}p )
do
	ID=$(basename $FILE .fq.gz)
	if [ -s $OUT/${ID}.report.html ]; then
		echo "$OUT/$ID.report.html exists, skipping"
		continue
	fi
	mmseqs createdb $FILE $SCRATCH/${ID}_db 
	taxonomyResult=$OUT/taxonomyResults/$ID
	mmseqs taxonomy $SCRATCH/${ID}_db $DB $taxonomyResult $SCRATCH --threads $CPU
	#--gpu 1 --index-subset 2
	mmseqs taxonomyreport $DB $taxonomyResult $OUT/${ID}.report.txt
	mmseqs taxonomyreport $DB $taxonomyResult $OUT/$ID.report.html --report-mode 1
done
