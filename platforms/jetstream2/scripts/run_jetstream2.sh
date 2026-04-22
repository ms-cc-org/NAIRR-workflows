#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../../.." && pwd)"
cd "$REPO_ROOT"

echo "Activating conda..."
source "$(conda info --base)/etc/profile.d/conda.sh"
conda activate js2-gpu-forecast

mkdir -p outputs/reports results/system results/benchmarks

export PLATFORM_LABEL="${PLATFORM_LABEL:-JetStream2}"
export N_CITIES="${N_CITIES:-210}"
export EPOCHS="${EPOCHS:-25}"
export BATCH_SIZE="${BATCH_SIZE:-4096}"
export WIDTH="${WIDTH:-1024}"
export DEPTH="${DEPTH:-8}"
export DROPOUT="${DROPOUT:-0.1}"
export LAGS="${LAGS:-1,3,7,14,30,60}"
export ROLLS="${ROLLS:-7,30}"
export NUM_WORKERS="${NUM_WORKERS:-8}"
export PREFETCH_FACTOR="${PREFETCH_FACTOR:-4}"
export SEED="${SEED:-42}"

echo "Running notebook..."
/usr/bin/time -v jupyter nbconvert \
  --to notebook \
  --execute forecasting.ipynb \
  --ExecutePreprocessor.kernel_name=js2-forecast \
  --ExecutePreprocessor.timeout=7200 \
  --output outputs/reports/forecasting.executed.ipynb \
  > results/benchmarks/nbconvert_stdout_jetstream2.txt \
  2> results/benchmarks/nbconvert_stderr_jetstream2.txt

{
  echo "DATE"; date -Is
  echo "GIT_COMMIT"; git rev-parse HEAD
  echo "HOST"; hostname
  echo "OS"; uname -a
  echo "CPU"; lscpu
  echo "MEM"; free -h
  echo "DISK"; df -h
  echo "NVIDIA_SMI"; nvidia-smi || true
  echo "CONDA"; conda --version
  echo "ACTIVE_ENV"; echo "$CONDA_DEFAULT_ENV"
  echo "PYTHON"; which python
  echo "JUPYTER"; which jupyter
} > results/system/jetstream2_env_snapshot.txt

echo "Done."
