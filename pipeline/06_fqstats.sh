#!/usr/bin/bash -l
#SBATCH -p short -c 16 -N 1 -n 1 --mem 4gb --out logs/fqstats.log

module load BBMap
mkdir -p results/stats
parallel -j 16 stats.sh in={} out=results/stats/{/.}.stats.txt  ::: $(ls results/bbsplit/*.gz)
