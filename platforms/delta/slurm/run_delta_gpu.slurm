#!/bin/bash
#SBATCH -A bgii-delta-gpu *REPLACE YOUR ALLOCATION NAME HERE*
#SBATCH -p gpuA100x4
#SBATCH -N 1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --time=04:00:00
#SBATCH -J delta_forecast
#SBATCH -o results/benchmarks/slurm_%j.out
#SBATCH -e results/benchmarks/slurm_%j.err
#SBATCH --gres=gpu:1

set -euo pipefail
echo "START: $(date -Is)"
echo "HOST: $(hostname)"
echo "PWD:  $(pwd)"

# Check SLURM environment
echo "SLURM Job ID: $SLURM_JOB_ID"
echo "SLURM Job Name: $SLURM_JOB_NAME"
echo "SLURM Allocation: $SLURM_JOB_ACCOUNT"

module purge
module load cuda/12.8

source /u/pnara/miniconda3/etc/profile.d/conda.sh

conda activate delta-forecast || { echo "Failed to activate the environment"; exit 1; }

echo "Activated env: $CONDA_DEFAULT_ENV"
echo "Python path: $(which python)"
echo "Conda path: $(which conda)"

echo "GPU Info:"
nvidia-smi

python - <<EOF
import torch
print("Torch:", torch.__version__)
print("CUDA available:", torch.cuda.is_available())
if torch.cuda.is_available():
    print("GPU:", torch.cuda.get_device_name(0))
EOF

# Log GPU usage
nvidia-smi > results/benchmarks/nvidia_smi_delta.txt 2>&1 || true
nvidia-smi --query-gpu=timestamp,name,utilization.gpu,utilization.memory,memory.used,memory.total \
  --format=csv -l 1 > results/benchmarks/gpu_util_delta.csv 2>/dev/null &
GPU_PID=$!

rm -f outputs/reports/forecasting.delta.executed.ipynb

nvidia-smi -L || true
echo "CUDA_VISIBLE_DEVICES=$CUDA_VISIBLE_DEVICES"

python - <<'PY'
import sys, torch
print("python:", sys.executable)
print("torch:", torch.__version__)
print("torch.version.cuda:", torch.version.cuda)
print("torch.cuda.is_available:", torch.cuda.is_available())
if torch.cuda.is_available():
    print("gpu:", torch.cuda.get_device_name(0))
PY

export PLATFORM_LABEL="Delta"
export N_CITIES=210
export EPOCHS=50
export BATCH_SIZE=8192

export WIDTH=1024
export DEPTH=8
export DROPOUT=0.1

export LAGS="1,3,7,14,30,60"
export ROLLS="7,30"

export NUM_WORKERS=${SLURM_CPUS_PER_TASK:-8}
export PREFETCH_FACTOR=4
export SEED=42

# Run Jupyter Notebook
/usr/bin/time -v jupyter nbconvert --to notebook --execute forecasting.ipynb \
  --ExecutePreprocessor.kernel_name=delta-forecast \
  --ExecutePreprocessor.timeout=7200 \
  --output outputs/reports/forecasting.delta.executed.ipynb \
  > results/benchmarks/nbconvert_stdout_delta.txt \
  2> results/benchmarks/nbconvert_stderr_delta.txt

kill $GPU_PID 2>/dev/null || true
wait $GPU_PID 2>/dev/null || true

# System snapshot
{
  echo "DATE"; date -Is
  echo "GIT_COMMIT"; git rev-parse HEAD
  echo "HOST"; hostname
  echo "OS"; uname -a
  echo "CPU"; lscpu
  echo "MEM"; free -h
  echo "DISK"; df -h
  echo "NVIDIA_SMI"; cat results/benchmarks/nvidia_smi_delta.txt
  echo "CONDA"; conda --version
  echo "ACTIVE_ENV"; echo $CONDA_DEFAULT_ENV
  echo "PYTHON"; which python
  echo "JUPYTER"; which jupyter
} > results/system/delta_env_snapshot.txt

echo "END: $(date -Is)"
