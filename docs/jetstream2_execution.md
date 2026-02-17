# JetStream2 GPU Execution Protocol

This document describes the exact procedure used to execute the forecasting
workflow on a JetStream2 GPU instance.

This branch (`main`) represents the JetStream2 reference execution.

---

## 1. Create GPU Instance (Exosphere)

- Select Ubuntu image
- Choose GPU flavor
- Attach SSH key
- Assign floating IP
- Launch

Verify GPU:

    nvidia-smi

---

## 2. Clone Repository

    mkdir -p ~/repos
    cd ~/repos
    git clone https://github.com/<ORG>/<REPO>.git
    cd <REPO>
    git rev-parse HEAD

---

## 3. Create Environment

    conda env create -f env_exports/js2-forecast.yml
    conda activate js2-gpu-forecast

Verify GPU inside Python:

    import torch
    torch.cuda.is_available()

---

## 4. Upload Dataset

From local machine:

    rsync -avP /path/to/7890488/ ubuntu@<PUBLIC_IP>:~/data/7890488/

Link inside project:

    ln -sfn ~/data/7890488 7890488

---

## 5. Execute Notebook

    /usr/bin/time -v jupyter nbconvert \
      --to notebook \
      --execute forecasting.ipynb \
      --ExecutePreprocessor.kernel_name=js2-gpu-forecast \
      --ExecutePreprocessor.timeout=7200 \
      --output outputs/reports/forecasting.executed.ipynb \
      2> results/benchmarks/time_forecast_gpu.txt

Optional GPU monitoring:

    nvidia-smi --query-gpu=timestamp,name,utilization.gpu,utilization.memory,memory.used,memory.total \
      --format=csv -l 1 > results/benchmarks/gpu_metrics.csv

---

## 6. Capture System Snapshot

    {
      echo "DATE"; date -Is
      echo "GIT_COMMIT"; git rev-parse HEAD
      echo "HOST"; hostname
      echo "OS"; uname -a
      echo "CPU"; lscpu
      echo "MEM"; free -h
      echo "DISK"; df -h
      echo "GPU"; nvidia-smi
      echo "CONDA"; conda --version
      echo "ACTIVE_ENV"; echo $CONDA_DEFAULT_ENV
      echo "PIP_FREEZE"; pip freeze
    } > results/system/jetstream2_gpu_env.txt

---

## 7. Commit Evidence

Commit:

- results/system/*
- results/benchmarks/*
- outputs/metrics/*