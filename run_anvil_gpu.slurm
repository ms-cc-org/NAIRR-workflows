#!/bin/bash
#SBATCH -A tra250005-ai
#SBATCH -p ai
#SBATCH -N 1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --gres=gpu:1
#SBATCH --mem=32G
#SBATCH --time=04:00:00
#SBATCH -J forecast_gpu
#SBATCH -o results/benchmarks/slurm_%j.out
#SBATCH -e results/benchmarks/slurm_%j.err

set -eo pipefail

echo "START: $(date -Is)"
echo "HOST: $(hostname)"
echo "PWD: $(pwd)"

echo "SLURM_JOB_ID: $SLURM_JOB_ID"
echo "SLURM_JOB_NAME: $SLURM_JOB_NAME"
echo "SLURM_JOB_ACCOUNT: $SLURM_JOB_ACCOUNT"

module purge
module load modtree/gpu
module load anaconda     
module load cuda       

source "$(conda info --base)/etc/profile.d/conda.sh"

conda activate anvil-forecast

echo "CUDA_VISIBLE_DEVICES: $CUDA_VISIBLE_DEVICES"
nvidia-smi

mkdir -p results/benchmarks
nvidia-smi --query-gpu=timestamp,name,utilization.gpu,utilization.memory,memory.used,memory.total \
  --format=csv -l 1 > results/benchmarks/gpu_util_anvil.csv &
GPU_PID=$!

rm -f outputs/reports/forecasting.anvil.executed.ipynb

/usr/bin/time -v jupyter nbconvert --to notebook --execute forecasting.ipynb \
  --ExecutePreprocessor.kernel_name=anvil-forecast \
  --ExecutePreprocessor.timeout=7200 \
  --output outputs/reports/forecasting.anvil.executed.ipynb \
  > results/benchmarks/nbconvert_stdout_anvil.txt \
  2> results/benchmarks/nbconvert_stderr_anvil.txt

kill $GPU_PID

mkdir -p results/system
{
  echo "DATE: $(date -Is)"
  echo "GIT_COMMIT: $(git rev-parse HEAD)"
  echo "HOST: $(hostname)"
  echo "OS: $(uname -a)"
  echo "CPU: $(lscpu)"
  echo "MEM: $(free -h)"
  echo "DISK: $(df -h)"
  echo "CONDA: $(conda --version)"
  echo "ACTIVE_ENV: $CONDA_DEFAULT_ENV"
  echo "PYTHON: $(which python)"
  echo "JUPYTER: $(which jupyter)"
} > results/system/anvil_env_snapshot.txt

echo "Job finished"
date
