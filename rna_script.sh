#!/bin/bash
#SBATCH --job-name=Tophat2 # Job name
#SBATCH --mail-type=END,FAIL # Mail events (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=your.name@nyulangone.org # Where to send mail
#SBATCH --ntasks=1
#SBATCH --mem=32gb # Job memory request
#SBATCH --time=24:00:00 # Time limit hrs:min:sec
#SBATCH --output=/gpfs/scratch/sb5169/Tophat2_%j.log # Standard output and error log
#SBATCH -p cpu_medium


module load trimgalore/0.5.0
module load python/cpu/2.7.15-ES
module load samtools/1.3
module load tophat/2.1.1
module load bowtie2/2.3.4.1
module load subread/1.6.3
module load igenome

#make sure you cd into your directory with the "file_names.txt" in it and change all paths to match your own paths
cd /gpfs/home/sb5169/sb5169/RNAseq_tutorial/

#this allows us to read in the filename prefix and subtitute it anywhere you see ${sample} and run array jobs
sample=$(awk "NR==${SLURM_ARRAY_TASK_ID} {print \$1}" file_names.txt)

#First trim raw fastq files
#trim_galore --paired --length 30 -o /gpfs/home/sb5169/sb5169/RNAseq_tutorial /gpfs/home/sb5169/sb5169/RNAseq_tutorial/data/${sample}_R1.fastq.gz /gpfs/home/sb5169/sb5169/RNAseq_tutorial/data/${sample}_R2.fastq.gz

#Map using tophat2 (STAR aligner is associated with faster run times)

tophat2 -o /gpfs/home/sb5169/sb5169/RNAseq_tutorial/${sample} -G /gpfs/home/sb5169/sb5169/RNAseq_tutorial/genes.gtf -p 8 --library-type fr-firststrand $IGENOMES_ROOT/Homo_sapiens/UCSC/hg38/Sequence/Bowtie2Index/genome /gpfs/home/sb5169/sb5169/RNAseq_tutorial/${sample}_R1_val_1.fq.gz /gpfs/home/sb5169/sb5169/RNAseq_tutorial/${sample}_R2_val_2.fq.gz

samtools sort -o /gpfs/home/sb5169/sb5169/RNAseq_tutorial/${sample}.sorted.bam ${sample}/accepted_hits.bam


samtools index /gpfs/home/sb5169/sb5169/RNAseq_tutorial/${sample}.sorted.bam

featureCounts -s 2 -p -B -a /gpfs/home/sb5169/sb5169/RNAseq_tutorial/genes.gtf -o /gpfs/home/sb5169/sb5169/RNAseq_tutorial/FeatCount /gpfs/home/sb5169/sb5169/RNAseq_tutorial/${sample}.sorted.bam
