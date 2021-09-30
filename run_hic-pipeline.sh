#!/bin/bash

#PBS -l ncpus=2
#PBS -l mem=8G
#PBS -q normal
#PBS -P xl04
#PBS -l walltime=24:00:00
#PBS -l storage=gdata/xl04+scratch/xl04
#PBS -l wd
#PBS -M terry.bertozzi@adelaide.edu.au

module load nextflow/21.04.3

nextflow run main.nf --reference /g/data/xl04/tb3184/assembly/hifiasm_hic/350719.hic.asm.hap2.p_ctg.fa --r1_reads /g/data/xl04/tb3184/data/raw/illumina/hic/350781_AusARG_BRF_HCN7WDRXY_S6_R1.fq.gz --r2_reads /g/data/xl04/tb3184/data/raw/illumina/hic/350781_AusARG_BRF_HCN7WDRXY_S6_R2.fq.gz --enzyme GAATAATC,GAATACTC,GAATAGTC,GAATATTC,GAATGATC,GACTAATC,GACTACTC,GACTAGTC,GACTATTC,GACTGATC,GAGTAATC,GAGTACTC,GAGTAGTC,GAGTATTC,GAGTGATC,GATCAATC,GATCACTC,GATCAGTC,GATCATTC,GATCGATC,GATTAATC,GATTACTC,GATTAGTC,GATTATTC,GATTGATC -resume
