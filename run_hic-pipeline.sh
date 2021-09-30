#!/bin/bash

#PBS -l ncpus=2
#PBS -l mem=8G
#PBS -q normal
#PBS -P xl04
#PBS -l walltime=24:00:00
#PBS -l storage=gdata/xl04+scratch/xl04
#PBS -l wd
#PBS -M terry.bertozzi@adelaide.edu.au


module load bwa/0.7.17
module load samtools/1.12
module load bedtools/2.28.0
module load pythonpackages/3.7.4
module load python2packages/2.7.17
module load salsa/v0.1
module load nextflow/21.04.3

nextflow run main.nf --reference 350719.hic.asm.hap2.p_ctg.fa --r1_reads 350781_AusARG_BRF_HCN7WDRXY_S6_R1.fq.gz --r2_reads 350781_AusARG_BRF_HCN7WDRXY_S6_R2.fq.gz --enzyme GAATAATC,GAATACTC,GAATAGTC,GAATATTC,GAATGATC,GACTAATC,GACTACTC,GACTAGTC,GACTATTC,GACTGATC,GAGTAATC,GAGTACTC,GAGTAGTC,GAGTATTC,GAGTGATC,GA
TCAATC,GATCACTC,GATCAGTC,GATCATTC,GATCGATC,GATTAATC,GATTACTC,GATTAGTC,GATTATTC,GATTGATC -resume
