# JetStream2 Execution Summary

**Repository:** [NAIRR-workflows](https://github.com/ms-cc-org/NAIRR-workflows/tree/main)  
**Reference commit:** 0e34e9abbf14d280da024e8dc2232cef8854adc4

## What was executed

A complete machine learning forecasting workflow (`forecasting.ipynb`) was executed end-to-end using non-interactive execution (`nbconvert`) on JetStream2.

The workflow includes:
- time-series feature engineering  
- multi-target regression (maximum temperature, minimum temperature, precipitation)  
- model training and validation  
- export of metrics and trained artifacts  

The execution environment is fully defined in `env_exports/js2-forecast.yml` for reproducibility.

This run establishes a **CPU baseline** for future GPU and accelerator comparisons.

## Where and how it ran

- **Platform:** JetStream2  
- **Instance:** nairr-proposal  
- **Allocation type:** CPU-only  
- **GPU availability:** None  
  (confirmed via `nvidia-smi`, see `results/benchmarks/gpu_metrics.csv` and `nvidia_smi.txt`)

This represents a **CPU-only baseline execution** on NAIRR-supported cyberinfrastructure.

## Training Performance (Measured)

Unlike earlier logs that relied on shell timing, this run captures **true in-training timing** directly from the training loop.

From `epoch_timing.csv` and `run_summary.json`:

- **Epochs:** 10  
- **Average time per epoch:** ~20.58 seconds  
- **Total training time:** ~205.84 seconds (~3.43 minutes)  
- **Average throughput:** ~98,807 samples/second  

Training loss decreased from **~10.16 → ~2.35**  
Validation loss decreased from **~3.26 → ~2.43**

This confirms:
- stable optimization
- consistent per-epoch compute time
- no divergence
- compute-bound behavior on CPU

This timing now becomes the **official baseline reference** for comparison.

## CPU Baseline Benchmark

| Platform     | Instance        | CPU/GPU | Time per Epoch (sec) | Total Training Time (min) | Peak Memory (MB) | GPU Utilization | Cost per Run | Speedup vs CPU |
|-------------|----------------|---------|-----------------------|----------------------------|------------------|----------------|--------------|----------------|
| JetStream2 | nairr-proposal | CPU     | 20.58                | 3.43                       | ~2700*          | N/A (CPU)     | TBD          | 1.0x |

\*Peak memory derived from system logs (~2.7 GB max resident set size).

This table is designed to be extended with GPU-enabled runs.

## Test Performance

Final evaluation metrics on the test set:  
[outputs/metrics/test_metrics.json](https://github.com/ms-cc-org/NAIRR-workflows/blob/main/outputs/metrics/test_metrics.json)

- **Maximum temperature (tmax):**
  - MAE ~ 4.37
  - RMSE ~ 6.51
- **Minimum temperature (tmin):**
  - MAE ~ 3.59
  - RMSE ~ 5.33
- **Precipitation (prcp):**
  - MAE ~ 0.156
  - RMSE ~ 0.315

These results demonstrate:
- meaningful predictive learning on CPU
- expected variability in precipitation modeling
- correctness and convergence of the pipeline

The objective of this run is **not peak accuracy**, but reproducible execution and baseline benchmarking.

## What This Means for Platform Comparison

This CPU-only run provides:

- Verified execution correctness
- Measured epoch time and throughput
- Memory footprint
- Full system fingerprint

Because the workflow is now frozen and instrumented, it can be executed on:

- GPU-enabled NAIRR systems (e.g., Anvil AI)
- Cloud GPU instances (AWS, GCP)
- Batch-scheduled HPC environments

On GPU-based environments, we expect:

- Reduced time per epoch
- Increased throughput
- Improved scaling for larger datasets
- Clear speedup vs CPU baseline

Once a GPU run is completed, the benchmark table will be extended with:

- GPU time/epoch
- GPU memory utilization
- Measured speedup factor
- Cost-normalized comparison
