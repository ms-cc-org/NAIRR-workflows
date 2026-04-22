#!/usr/bin/env bash
# Run from an AWS GPU instance after cloning the repo and installing Conda.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../../.." && pwd)"
cd "$REPO_ROOT"

echo "=== Step 0: Sanity Checks ==="
pwd
git status
nvidia-smi -L || true

source "$(conda info --base)/etc/profile.d/conda.sh"
conda env create -f platforms/aws/env_exports/aws-forecast.yml || true
conda activate aws-forecast
python -m ipykernel install --user --name aws-forecast --display-name "aws-forecast"

if [ ! -f "7890488/city_info.csv" ]; then
  echo "Dataset not found at 7890488/. Mirroring public dataset into the repo."
  mkdir -p ~/data
  if [ ! -d ~/data/7890488_src/.git ]; then
    git clone --depth 1 https://github.com/radames/dataset-historical-daily-temperature-210-US.git ~/data/7890488_src
  fi
  mkdir -p 7890488
  rsync -avP ~/data/7890488_src/ ./7890488/
fi

echo "AWS Metadata"
mkdir -p results/system results/benchmarks
TOKEN=$(curl -fsS -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600" || true)
AZ=$(curl -fsS -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/placement/availability-zone || echo "unknown")
INSTANCE_TYPE=$(curl -fsS -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-type || echo "unknown")
echo "AZ=$AZ" | tee results/system/aws_instance.txt
echo "INSTANCE_TYPE=$INSTANCE_TYPE" | tee -a results/system/aws_instance.txt

export PLATFORM_LABEL="${PLATFORM_LABEL:-AWS}"
export N_CITIES="${N_CITIES:-210}"
export EPOCHS="${EPOCHS:-50}"
export BATCH_SIZE="${BATCH_SIZE:-8192}"
export WIDTH="${WIDTH:-1024}"
export DEPTH="${DEPTH:-8}"
export DROPOUT="${DROPOUT:-0.1}"
export LAGS="${LAGS:-1,3,7,14,30,60}"
export ROLLS="${ROLLS:-7,30}"
export NUM_WORKERS="${NUM_WORKERS:-8}"
export PREFETCH_FACTOR="${PREFETCH_FACTOR:-4}"
export SEED="${SEED:-42}"

nvidia-smi --query-gpu=timestamp,name,utilization.gpu,utilization.memory,memory.used,memory.total \
  --format=csv -l 1 > results/benchmarks/gpu_util.csv &
GPU_PID=$!
echo "$GPU_PID" > results/benchmarks/gpu_util.pid

mkdir -p outputs/reports results/benchmarks
rm -f outputs/reports/forecasting.aws.executed.ipynb
/usr/bin/time -v jupyter nbconvert --to notebook --execute forecasting.ipynb \
  --ExecutePreprocessor.kernel_name=aws-forecast \
  --ExecutePreprocessor.timeout=7200 \
  --output outputs/reports/forecasting.aws.executed.ipynb \
  > results/benchmarks/nbconvert_stdout_aws.txt \
  2> results/benchmarks/nbconvert_stderr_aws.txt

kill "$GPU_PID" 2>/dev/null || true
wait "$GPU_PID" 2>/dev/null || true
sleep 1
tail -n 5 results/benchmarks/gpu_util.csv || true
{
  echo "DATE"; date -Is
  echo "GIT_COMMIT"; git rev-parse HEAD
  echo "HOST"; hostname
  echo "OS"; uname -a
  echo "CPU"; lscpu
  echo "MEM"; free -h
  echo "DISK"; df -h
  echo "NVIDIA_SMI"; nvidia-smi
  echo "CONDA"; conda --version
  echo "ACTIVE_ENV"; echo $CONDA_DEFAULT_ENV
  echo "PYTHON"; which python
  echo "JUPYTER"; which jupyter
  echo "AWS_INSTANCE"; cat results/system/aws_instance.txt
} > results/system/aws_env_snapshot.txt

echo "=== AWS Run Completed ==="
echo "Review outputs/ and results/. Commit evidence only if your workshop workflow asks for it."
