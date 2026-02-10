# JetStream2 Execution Summary

**Repository:** [NAIRR-workflows](https://github.com/ms-cc-org/NAIRR-workflows/tree/main)  
**Reference commit:** 1faf87922c003b1b94a59863df07f665cf9561b7

## What was executed

A complete machine learning forecasting workflow (`forecasting.ipynb`) was executed end-to-end using non-interactive execution --> `nbconvert` on JetStream2.

The workflow includes time-series feature engineering, multi-target regression (maximum temperature, minimum temperature, precipitation), model training and validation.

The execution environment is fully defined in `env_exports/js2-forecast.yml` for reproducibility.

## Where and how it ran

- **Platform:** JetStream2
- **Allocation type:** CPU-only
- **GPU availability:** None  
  (confirmed via `nvidia-smi`, see `results/benchmarks/gpu_metrics.csv` and `nvidia_smi.txt`)

This run therefore represents a **CPU-based baseline execution** on NAIRR-supported cyberinfrastructure.

## Observed behavior

Training converged steadily over 10 epochs:
- Training loss decreased from **~10.16 --> ~2.35**
- Validation loss decreased from **~3.26 --> ~2.43**

This shows:
- a stable optimization behavior
- no divergence
- diminishing returns toward final epochs (this is normal for CPU-limited training)

This suggests that the model is capacity-appropriate but training speed is constrained by `CPU-only execution`.

## Test performance

Final evaluation metrics on the test set [Link](https://github.com/ms-cc-org/NAIRR-workflows/blob/main/outputs/metrics/test_metrics.json):
- **Maximum temperature (tmax):**
  - MAE ~ **4.37**
  - RMSE ~ **6.51**
- **Minimum temperature (tmin):**
  - MAE ~ **3.59**
  - RMSE ~ **5.33**
- **Precipitation (prcp):**
  - MAE ~ **0.156**
  - RMSE ~ **0.315**

These results show:
- reasonable predictive accuracy for temperature variables
- higher relative uncertainty for precipitation (because rain varies highly in spans of time)
- the model is learning meaningful temporal patterns even under CPU constraints

The goal of this run is to set up a execution reference, **not** to gain peak accuracy.

## Execution cost and system impact

From the [execution logs](https://github.com/ms-cc-org/NAIRR-workflows/blob/main/results/benchmarks/nbconvert_stderr.txt):

- **CPU utilization:** across 1000%+
- **Peak memory usage:** ~2.7 GB
- **No GPU acceleration available**

This shows that:
- training is bound on CPU
- the workflow is viable but slow at scale
- longer training runs or larger datasets would significantly increase turnaround time

## What this tells us about the environment

JetStream2, even with a `CPU-only allocation`, is effective for:
- onboarding researchers to national CI
- validating correctness and reproducibility
- establishing execution discipline
- capturing system-level evidence

However, CPU-only execution:
- limits iteration speed
- constrains model complexity
- makes hyperparameter exploration expensive

This environment therefore serves as a **development and baseline validation layer**, not the final scaling target.

## Implications for GPU-enabled NAIRR systems

Because the workflow is now frozen and validated, the same notebook, dataset, and metrics can be executed on GPU-enabled systems (such as Anvil AI, AWS, GCP) with minimal changes.

On GPU-based environments, we can expect:
- significantly reduced training time
- improved throughput for larger datasets
- ability to scale model complexity
- clearer insights into memory vs compute bottlenecks
