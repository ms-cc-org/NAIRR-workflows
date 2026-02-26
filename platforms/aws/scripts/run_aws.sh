#!/bin/bash
# For this you need have an EC2 instance with GPU, conda installed, repo cloned

set -e
REPO_ROOT=~/repos/NAIRR-workflows
cd $REPO_ROOT

echo "=== Step 0: Sanity Checks ==="
pwd
git status
nvidia-smi -L


conda env create -f env_exports/js2-forecast.yml -n aws-forecast || true
conda activate aws-forecast
conda install -y -c conda-forge jupyter nbconvert ipykernel pandas numpy scikit-learn
conda install -y -c pytorch -c nvidia pytorch pytorch-cuda=12.1 torchvision torchaudio
python -m ipykernel install --user --name aws-forecast --display-name "aws-forecast"

mkdir -p ~/data
cd ~/data
git clone --depth 1 https://github.com/radames/dataset-historical-daily-temperature-210-US.git 7890488_src || true
cd $REPO_ROOT
mkdir -p 7890488
rsync -avP ~/data/7890488_src/ ./7890488/
grep -n "7890488/" .gitignore || printf "\n# dataset (do not commit)\n7890488/\n" >> .gitignore

echo "AWS Metadata"
mkdir -p results/system results/benchmarks
TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
AZ=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/placement/availability-zone)
INSTANCE_TYPE=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-type)
echo "AZ=$AZ" | tee results/system/aws_instance.txt
echo "INSTANCE_TYPE=$INSTANCE_TYPE" | tee -a results/system/aws_instance.txt

nvidia-smi --query-gpu=timestamp,name,utilization.gpu,utilization.memory,memory.used,memory.total \
  --format=csv -l 1 > results/benchmarks/gpu_util.csv &
echo $! > results/benchmarks/gpu_util.pid

mkdir -p outputs/reports results/benchmarks
rm -f outputs/reports/forecasting.aws.executed.ipynb
/usr/bin/time -v jupyter nbconvert --to notebook --execute forecasting.ipynb \
  --ExecutePreprocessor.kernel_name=aws-forecast \
  --ExecutePreprocessor.timeout=7200 \
  --output outputs/reports/forecasting.aws.executed.ipynb \
  > results/benchmarks/nbconvert_stdout_aws.txt \
  2> results/benchmarks/nbconvert_stderr_aws.txt

kill "$(cat results/benchmarks/gpu_util.pid)" || true
sleep 1
tail -n 5 results/benchmarks/gpu_util.csv
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

git add .gitignore
git add outputs/reports/forecasting.aws.executed.ipynb
git add outputs/metrics outputs/models 2>/dev/null || true
git add results/benchmarks/nbconvert_*_aws.txt results/benchmarks/gpu_util.csv results/system/aws_*.txt results/system/aws_env_snapshot.txt
git commit -m "AWS GPU run: executed notebook + GPU util + system snapshot"
git push -u origin aws-run-20260211

echo "=== AWS Run Completed ==="