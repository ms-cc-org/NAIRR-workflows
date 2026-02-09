# JetStream2 Execution Summary
- Repository: [https://github.com/ms-cc-org/NAIRR-workflows](https://github.com/ms-cc-org/NAIRR-workflows)
- Reference commit: 1faf87922c003b1b94a59863df07f665cf9561b7

## What was executed
- A complete ML forecasting workflow: [Forecasting.ipynb](https://github.com/ms-cc-org/NAIRR-workflows/blob/main/forecasting.ipynb)
- Executed using nbconvert
- Environment defined in [js2-forecast.yml](https://github.com/ms-cc-org/NAIRR-workflows/blob/main/env_exports/js2-forecast.yml)

## Where it ran
- JetStream2 (CPU-only allocation)
- No GPU available (verified via nvidia-smi)

## Evidence
- Executed notebook: [forecasting.executed.ipynb](https://github.com/ms-cc-org/NAIRR-workflows/blob/main/outputs/reports/forecasting.executed.ipynb)
- Benchmarks: [results/benchmarks](https://github.com/ms-cc-org/NAIRR-workflows/tree/main/results/benchmarks)
- System snapshot: [js2_env_snapshot.txt](https://github.com/ms-cc-org/NAIRR-workflows/blob/main/results/system/js2_env_snapshot.txt)

## Why this matters
This run establishes a reproducible CPU baseline that can be translated directly to GPU-enabled NAIRR systems for comparison and scaling.
