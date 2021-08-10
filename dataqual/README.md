# Pre-requisite
- EEGLAB installed with the following plugins
  - Default plugins (firfilt, clean_rawdata, ICAlabel)
  - bids-matlab-tools plugin
  - picard plugin to run ICA

# Pipeline to determine data quality

Run these functions in the folder containing the BIDS dataset.

- bids_meta.m: Import BIDS data only
- bids_dataqual.m: Import, uses clean_rawdata and ICA. 
  - Save modified data in the folder ../xxxxxx-processed/ (xxxxx being the current folder name)
  - Save in the folder ../results/ a text file with the results.
- bids_checkdatasets.m: Check which files have been processed
- bids_chaninfo.m: Check channel information. Do not use.

Meta files
- bash_create_slurm: Bash file to create slurm script to run at SDSC
- job_openneuro.slurm: Template slurm script to run at SDSC
- opennneuro.txt: commands to download data
- opennneuro.xls: results 
- showresults: Bash command to see results (call function below)
- showresults.m: Matlab function to see results on all datasets
