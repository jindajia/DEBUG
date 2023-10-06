#!/bin/bash
#SBATCH -N 2
#SBATCH -p GPU
#SBATCH -t 00:05:00
#SBATCH --gpus=v100-16:16
#SBATCH --job-name=nccl-test
#SBATCH --output=nccl-test_%j.txt


#https://guiesbibtic.upf.edu/recerca/hpc/multi-node-multi-gpu

module load gcc
module load cuda
module load openmpi/4.0.5-gcc10.2.0
source ~/.bashrc

set -x 

srun --version

cd /ocean/projects/asc200010p/jjia1/Developer/nccl-tests/build

export LD_LIBRARY_PATH=/ocean/projects/asc200010p/jjia1/Developer/nccl/build/lib:$LD_LIBRARY_PATH

echo $LD_LIBRARY_PATH

nvidia-smi

# Get the hostnames
HOSTNAMES=$(scontrol show hostnames | sort | uniq)

# Construct the hostlist as a comma-separated list
HOSTLIST=""
for HOST in $HOSTNAMES; do
  HOSTLIST="${HOSTLIST}${HOST},"
done

# Remove the trailing comma
HOSTLIST=${HOSTLIST%,}

env
mpirun --version
mpirun -H $HOSTLIST echo "Hello"
mpirun -H $HOSTLIST all_reduce_perf -b 512M -e 1024M -f 2 -g 8 -d half
