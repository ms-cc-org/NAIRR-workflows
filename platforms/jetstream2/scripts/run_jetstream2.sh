#!/usr/bin/env bash
set -e

echo "Activating conda..."
source $(conda info --base)/etc/profile.d/conda.sh
conda activate js2-gpu-forecast

mkdir -p outputs/reports results/system results/benchmarks

echo "Running notebook..."
/usr/bin/time -v jupyter nbconvert \
  --to notebook \
  --execute forecasting.ipynb \
  --ExecutePreprocessor.kernel_name=js2-gpu-forecast \
  --ExecutePreprocessor.timeout=7200 \
  --output outputs/reports/forecasting.executed.ipynb \
  2> results/benchmarks/time_forecast_gpu.txt

echo "Done."