#!/bin/bash
#SBATCH --job-name=dsrp
#SBATCH --time=00:30:00
#SBATCH --partition=normal
#SBATCH --nodes=10
#SBATCH --ntasks-per-core=1
#SBATCH --ntasks-per-node=36
#SBATCH --constraint=mc
#SBATCH packjob
#SBATCH --nodes=2
#SBATCH --ntasks-per-core=1
#SBATCH --ntasks-per-node=1
#SBATCH --constraint=storage

ARGS="-v -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"
COMPUTE_NODE=`hostlist -e $SLURM_JOB_NODELIST_PACK_GROUP_0 | head -n 1`
STORAGE_NODE=`hostlist -e $SLURM_JOB_NODELIST_PACK_GROUP_1 | head -n 1`

ssh $COMPUTE_NODE hostname > ssh.res 2>&1
sleep 10
echo >> ssh.res
echo "================" >> ssh.res
echo >> ssh.res
ssh $STORAGE_NODE hostname >> ssh.res 2>&1

sleep 10

ssh $ARGS $COMPUTE_NODE hostname > ssh_args.res 2>&1
sleep 10
echo >> ssh_args.res
echo "================" >> ssh_args.res
echo >> ssh_args.res
ssh $ARGS $STORAGE_NODE hostname >> ssh_args.res 2>&1


