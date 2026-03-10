#!/bin/bash
#SBATCH -A tra250023p *REPLACE YOUR ALLOCATION NAME HERE*
#SBATCH -N 1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=5
#SBATCH --mem=22G
#SBATCH --time=04:00:00
#SBATCH -J b2_forecast
#SBATCH -o results/benchmarks/slurm_%j.out
#SBATCH -e results/benchmarks/slurm_%j.err

#SBATCH -p GPU-shared
#SBATCH --gpus=v100-32:1

set -euo pipefail
echo "START: $(date -Is)"
echo "HOST: $(hostname)"
echo "PWD:  $(pwd)"

module purge
module load anaconda3 || true
module load cuda/12.6.1 || true

export MKL_INTERFACE_LAYER=LP64

conda activate bridges2-forecast

python -c "import torch; print(torch.cuda.is_available())"

export PLATFORM_LABEL="Bridges2"
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


nvidia-smi > results/benchmarks/nvidia_smi_b2.txt 2>&1 || true

nvidia-smi --query-gpu=timestamp,name,utilization.gpu,utilization.memory,memory.used,memory.total \
  --format=csv -l 1 > results/benchmarks/gpu_util_b2.csv 2>/dev/null &

GPU_PID=$!

rm -f outputs/reports/forecasting.executed.ipynb

/usr/bin/time -v jupyter nbconvert --to notebook --execute forecasting.ipynb \
  --ExecutePreprocessor.kernel_name=b2-forecast \
  --ExecutePreprocessor.timeout=7200 \
  --output outputs/reports/forecasting.b2.executed.ipynb \
  > results/benchmarks/nbconvert_stdout_b2.txt \
  2> results/benchmarks/nbconvert_stderr_b2.txt

kill $GPU_PID 2>/dev/null || true

{
  echo "DATE"; date -Is
  echo "GIT_COMMIT"; git rev-parse HEAD
  echo "HOST"; hostname
  echo "OS"; uname -a
  echo "CPU"; lscpu
  echo "MEM"; free -h
  echo "DISK"; df -h
  echo "NVIDIA_SMI"; cat results/benchmarks/nvidia_smi_b2.txt
  echo "CONDA"; conda --version
  echo "ACTIVE_ENV"; echo $CONDA_DEFAULT_ENV
  echo "PYTHON"; which python
  echo "JUPYTER"; which jupyter
} > results/system/b2_env_snapshot.txt

jobs -p | xargs -r kill 2>/dev/null || true

echo "END: $(date -Is)"

