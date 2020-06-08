#!/bin/bash
#SBATCH --job-name=dsrp
#SBATCH --time=00:30:00
#SBATCH --partition=normal
#SBATCH --nodes=2
#SBATCH --ntasks-per-core=1
#SBATCH --ntasks-per-node=36
#SBATCH --constraint=mc
#SBATCH packjob
#SBATCH --nodes=2
#SBATCH --ntasks-per-core=1
#SBATCH --ntasks-per-node=1
#SBATCH --constraint=storage

DYN_PRO_ROOT=$HOME/dynamic-resource-provisioning
DYN_PRO_BEEGFS_BENCH=$DYN_PRO_ROOT/benchmarks/beegfs

LUSTRE_OUTPUT=$SCRATCH/DYN_PRO/
BEEGFS_OUTPUT=$HOME/beegfs/

PART=2500000
NPF=36
ARGS="-p $PART -f $NPF -i -s"

LUSTRE_RES=$DYN_PRO_BEEGFS_BENCH/experiments/lustre.res
BEEGFS_RES=$DYN_PRO_BEEGFS_BENCH/experiments/beegfs.res
DYNPRO_RES=$DYN_PRO_BEEGFS_BENCH/experiments/dyn_pro.res

$DYN_PRO_ROOT/dsrp_deploy.py -s $SLURM_JOB_NODELIST_PACK_GROUP_1 -c $SLURM_JOB_NODELIST_PACK_GROUP_0 -t daint start minio > $DYNPRO_RES 2>&1

sleep 180

# for RUN in {0..4}
# do
#     echo "srun --pack-group=0 $DYN_PRO_BEEGFS_BENCH/HACC-IO/miniHACC-MPIIO $ARGS -o $LUSTRE_OUTPUT" >> $LUSTRE_RES
#     srun --pack-group=0 $DYN_PRO_BEEGFS_BENCH/HACC-IO/miniHACC-MPIIO $ARGS -o $LUSTRE_OUTPUT >> $LUSTRE_RES 2>&1
#     sleep 10
#     echo "srun --pack-group=0 $DYN_PRO_BEEGFS_BENCH/HACC-IO/miniHACC-MPIIO $ARGS -o $BEEGFS_OUTPUT" >> $BEEGFS_RES
#     srun --pack-group=0 $DYN_PRO_BEEGFS_BENCH/HACC-IO/miniHACC-MPIIO $ARGS -o $BEEGFS_OUTPUT >> $BEEGFS_RES 2>&1
#     sleep 10
# done

# sleep 120

$DYN_PRO_ROOT/dsrp_deploy.py -s $SLURM_JOB_NODELIST_PACK_GROUP_1 -c $SLURM_JOB_NODELIST_PACK_GROUP_0 -t daint stop minio >> $DYNPRO_RES 2>&1

sleep 30
