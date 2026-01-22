#!/usr/bin/bash -l
#SBATCH -c 48 --mem 128gb --out logs/bbsplit_masso_RNA.%a.log -a 1

module load BBMap
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

GENOMES=genome
HOSTURL=https://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/011/326/945/GCA_011326945.2_ASM1132694v2/GCA_011326945.2_ASM1132694v2_genomic.fna.gz
FUNGUSURL=https://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/022/478/985/GCA_022478985.1_UCR_MCPNR19_1.0/GCA_022478985.1_UCR_MCPNR19_1.0_genomic.fna.gz
RNADIR=rnaseq

for url in $HOSTURL $FUNGUSURL
do
	file=$(basename $url)
	if [ ! -f $GENOMES/$file ]; then
		curl -o $GENOMES/$file $url
	fi
done
BUILDNUM=1
if [ ! -d ref/index/$BUILDNUM ]; then
	bbsplit.sh build=$BUILDNUM ref_Host=$GENOMES/$(basename $HOSTURL) ref_Fungus=$GENOMES/$(basename $FUNGUSURL)
fi

SAMPFILE=samples.csv
OUT=results/bbsplit
mkdir -p $OUT
IFS=,
tail -n +2 $SAMPFILE | sed -n ${N}p | while read ID FILEBASE HOST SEX DATE LOCATION
do
	LEFT=$RNADIR/${FILEBASE}_L001_R1_001.fastq.gz
	RIGHT=$RNADIR/${FILEBASE}_L001_R2_001.fastq.gz
	bbsplit.sh build=$BUILDNUM in=$LEFT in2=$RIGHT basename=$OUT/${ID}_%.fq.gz outu=$OUT/${ID}_unmapped.fq.gz threads=$CPU
done
