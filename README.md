# NAIRR ML Workflows

This repository demonstrates a **reproducible machine learning workflow** designed to run across multiple compute environments, including CPU-based development systems and GPU-enabled national AI infrastructure.

The primary goal is to establish a **CPU baseline** and then compare performance across GPU platforms such as cloud providers and NAIRR-supported supercomputing systems.

## Workshop quickstart

If you are using this repository in a workshop, start with:

- [WORKSHOP.md](WORKSHOP.md)
- [docs/platforms.md](docs/platforms.md)

The workshop path is:

1. Clone the repository on your assigned platform.
2. Stage the dataset in `7890488/`.
3. Create the platform Conda environment from `platforms/<platform>/env_exports/`.
4. Run the platform script or Slurm job.
5. Check `outputs/` and `results/` for the executed notebook, metrics, logs, and benchmark row.

---

## Relationship to NAIRR

The National AI Research Resource (NAIRR) is designed to:

- Broaden access to advanced AI compute resources
- Reduce barriers to entry for researchers and students
- Enable reproducible and portable AI workflows
- Support training and experimentation across heterogeneous systems

However, many researchers begin their work on:

- Laptops
- Campus servers
- Cloud notebooks (such as Colab, jupyterhub)

Moving these workflows onto national AI infrastructure introduces new challenges:

- Different hardware architectures
- Batch scheduling environments
- Resource constraints
- Reproducibility requirements
- Performance scaling considerations

This repository supports the NAIRR mission by:

- Providing a **portable, end-to-end ML workflow**
- Establishing a **CPU baseline execution**
- Capturing **reproducible execution evidence**
- Enabling **direct performance comparisons** across NAIRR and cloud GPU systems

---

## Purpose of this repository

This project demonstrates how a single ML workflow can:

1. Run reproducibly on a CPU-only system
2. Be migrated unchanged to GPU-enabled environments
3. Produce measurable performance improvements
4. Support cross-platform benchmarking

The focus is not on model accuracy, but on **execution performance across systems**.

---

## Platform structure

This repository is organized as a single workflow with platform-specific execution packs.

Start here:
- `WORKSHOP.md`
- `docs/platforms.md`

Platform-specific assets live under:
- `platforms/<platform>/`
  - `docs/` execution guide
  - `env_exports/` environment export
  - `scripts/` or `slurm/` run wrappers or Slurm job scripts

Execution evidence (executed notebooks + benchmarks + system snapshots) is archived under:
- `runs/<platform>/<YYYY-MM-DD>/`

and contains:
- outputs/ (models, metrics, executed notebooks)
- results/ (benchmarks, system logs, execution evidence)

## Benchmarking approach

The workflow is designed to run identically across:

1. **JetStream2 (CPU baseline)**
2. **AWS GPU instances**
3. **NAIRR GPU systems** (Anvil, Delta, Bridges-2)

Each run uses:

- The same dataset
- The same notebook
- The same environment definition
- The same training configuration

This enables direct comparison of:

- Time per epoch
- Total training time
- Resource utilization
- Cost per run
- Speedup between CPU and GPU environments

---

## What has been executed so far

The workflow has been executed across five platforms to establish reproducible cross-platform benchmarking.

### JetStream2: CPU Baseline
- **Platform:** JetStream2
- **Allocation:** CPU-only
- **Execution:** Non-interactive via nbconvert

This run establishes the reference CPU baseline for performance comparison.

### AWS: GPU Execution
- **Platform:** AWS EC2 (g4dn.xlarge, NVIDIA T4)
- **Execution:** Non-interactive via nbconvert

This run demonstrates CUDA-enabled execution with GPU utilization logging, system snapshot capture, and benchmark evidence.

### Bridges-2: NAIRR GPU Execution
- **Platform:** Bridges-2 (PSC)
- **Execution:** Batch + nbconvert

### Anvil: NAIRR GPU Execution
- **Platform:** Anvil (Purdue)
- **Execution:** Batch + nbconvert

### Delta: NAIRR GPU Execution
- **Platform:** Delta (NCSA)
- **Execution:** Batch + nbconvert

These runs validate portability to NAIRR-supported GPU systems with scheduler-based execution and reproducibility artifacts.

---

## Core components of the workflow

### Reproducible environments
**Folder:** `platforms/<platform>/env_exports/`

Defines the Python and ML dependencies captured during platform execution.
If an export is too platform-specific for a new allocation, use the minimal
package install shown in `WORKSHOP.md`.

---

### Machine learning workflow
**File:** `forecasting.ipynb`

This notebook contains the full ML pipeline:

- Data loading
- Feature engineering
- Model training
- Evaluation

It is designed for **non-interactive, automated execution**.

---

### Executed notebook proof
**File:** `outputs/reports/*.executed.ipynb`

This file is produced by a completed notebook execution.

---

## Execution evidence

### Benchmark logs
**Folder:** `results/benchmarks/`

Contains:

- Runtime logs
- Resource utilization data
- System execution traces

This provides **measured system performance**, not estimates.

---

### CPU-only confirmation
**File:** `results/benchmarks/nvidia_smi.txt`

Confirms that the JetStream2 run executed without GPU acceleration, establishing the CPU baseline.

---

### System snapshot
**File:** `results/system/*_env_snapshot.txt`

Captures:
- OS version
- CPU configuration
- Memory
- Installed tools
- Environment state

This ensures full reproducibility.

---

## Reusable outputs

The workflow exports artifacts for cross-platform comparison.

### Metrics
`outputs/metrics/`

### Trained models
`outputs/models/`

These allow evaluation without rerunning the training process.

---

## How to reproduce the JetStream2 run

1. Launch a JetStream2 instance.
2. Clone the repository.
3. Create and activate the environment:
```
    conda env create -f platforms/jetstream2/env_exports/jetstream2-forecast.yml
    conda activate js2-gpu-forecast
```
4. Execute:
```
   bash platforms/jetstream2/scripts/run_jetstream2.sh
```

---

## How to Reproduce the AWS Run

1. Launch an AWS GPU instance (e.g., `g4dn.xlarge`).
2. Clone the repository.
3. Create and activate the environment:
```
   conda env create -f platforms/aws/env_exports/aws-forecast.yml
   conda activate aws-forecast
```
4. Execute:
```
   bash platforms/aws/scripts/run_aws.sh
```

---

## How to Reproduce the Bridges-2 Run
1. Log into Bridges-2.
2. Clone the repository.
3. Create and activate the environment:
```
   conda env create -f platforms/bridges2/env_exports/bridges2-forecast.yml
   conda activate bridges2-forecast
```
4. Submit the batch job:
```
   sbatch platforms/bridges2/slurm/run_forecasting_b2.slurm
```

---

## How to Reproduce Delta and Anvil Runs

Use the platform guide, update the `#SBATCH -A YOUR_ALLOCATION` line, and submit:

```
sbatch platforms/delta/slurm/run_delta_gpu.slurm
sbatch platforms/anvil/slurm/run_anvil_gpu.slurm
```

See `WORKSHOP.md` for the participant workflow and `docs/platforms.md` for all
platform-specific guides.

---

## Expected outcome

This repository will produce a **simple, reproducible performance comparison** across:

- CPU-based development environments
- Cloud GPU systems
- NAIRR-supported AI supercomputing resources

The result will be:

- A clear scaling story from CPU to national AI systems
- Evidence-based guidance for researchers choosing NAIRR resources
- A reusable benchmark framework for onboarding new users

## Choose your platform

Start here:

- `WORKSHOP.md`
- `docs/platforms.md`

Platform-specific scripts, environment exports, and Slurm job files are under:
`platforms/<platform>/`

Execution evidence (executed notebooks + benchmarks + system snapshots) is archived under:
`runs/<platform>/<date>/`
