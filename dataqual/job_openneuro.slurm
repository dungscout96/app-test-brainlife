#!/bin/bash
#SBATCH --job-name="xxx"
#SBATCH --output="xxx_%j.%N.out"
#SBATCH --partition=shared
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=zzz
#SBATCH --mem=yyyGb
#SBATCH --export=ALL
#SBATCH -t 10:00:00
#SBATCH --mail-user=adelorme@ucsd.edu
#SBATCH --mail-type=begin
#SBATCH --mail-type=end
#SBATCH -A csd403
source ~/.bashrc
cd /home/arno/nemar/openneuro/xxx
module load matlab
matlab -nodisplay -nosplash -nodesktop < /home/arno/nemar/openneuro/dataqual/bids_meta.m
