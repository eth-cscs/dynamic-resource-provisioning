#!/bin/bash
#SBATCH --job-name=dsrp
#SBATCH --time=00:10:00
#SBATCH --partition=normal
#SBATCH --nodes=4
#SBATCH --ntasks-per-core=1
#SBATCH --ntasks-per-node=12
#SBATCH --constraint=mc
#SBATCH packjob
#SBATCH --nodes=1
#SBATCH --ntasks-per-core=1
#SBATCH --ntasks-per-node=1
#SBATCH --constraint=storage

DYN_PRO_ROOT=$HOME/dynamic-resource-provisioning
DYN_PRO_BEEGFS_BENCH=$DYN_PRO_ROOT/benchmarks/beegfs

$DYN_PRO_ROOT/dsrp_deploy.py start $DYN_PRO_BEEGFS_BENCH/dsrp_configs/dsrp_beegfs_dom.yml

srun --pack-group=0 $DYN_PRO_BEEGFS_BENCH/HACC-IO/miniHACC-MPIIO -p 250000 -f 24 -o /scratch/snx3000tds/ftessier/

sleep 360

$DYN_PRO_ROOT/dsrp_deploy.py stop $DYN_PRO_BEEGFS_BENCH/dsrp_configs/dsrp_beegfs_dom.yml
