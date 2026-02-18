# NAIRR ML Workflows

This repository demonstrates a **reproducible machine learning workflow** designed to run across multiple compute environments, including CPU-based development systems and GPU-enabled national AI infrastructure.

The primary goal is to establish a **CPU baseline** and then compare performance across GPU platforms such as cloud providers and NAIRR-supported supercomputing systems.

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
- Cloud notebooks (e.g., Colab)

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

## Branch Structure

This repository contains platform-specific execution branches:

- `main` → JetStream2 CPU baseline
- `aws-run-20260211` → AWS GPU execution
- `bridges2-run-20260216` → Bridges-2 GPU execution

Each branch contains:

- The same ML workflow
- Platform-specific execution evidence
- Benchmark logs
- System metadata

---

## Benchmarking approach

The workflow is designed to run identically across:

1. **JetStream2 (CPU baseline)**
2. **AWS GPU instances**
3. **NAIRR GPU systems** (e.g., Delta, Bridges-2)

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

### CPU baseline run

The workflow was executed end-to-end on:

- **Platform:** JetStream2
- **Allocation type:** CPU-only
- **Execution mode:** Non-interactive via `nbconvert`

This run establishes the **reference baseline** for later GPU comparisons.

---

## Core components of the workflow

### Reproducible environment
**File:** `env_exports/js2-forecast.yml`

Defines the exact Python and ML dependencies used during execution.  
This environment can be recreated on other platforms to ensure consistent results.

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

### Executed notebook (proof of run)
**File:** `outputs/reports/forecasting.executed.ipynb`

Generated automatically using: jupyter nbconvert –execute forecasting.ipynb

This provides a full, auditable record of the completed run.

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
**File:** `results/system/js2_env_snapshot.txt`

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

## How to run the workflow

1. Create the environment: `conda env create -f env_exports/js2-forecast.yml`
2. Place the dataset in the expected location.
3. Execute the notebook non-interactively: `jupyter nbconvert –execute forecasting.ipynb`
4. Review outputs:
- `outputs/`
- `results/`

---

## How to reproduce the JetStream2 run

1. Launch a JetStream2 instance.
2. Clone the repository.
3. Create the environment:
    conda env create -f env_exports/js2-forecast.yml

4. Activate:
   conda activate js2-gpu-forecast

5. Execute:
   bash scripts/run_jetstream2.sh

---

## Next steps: GPU benchmarking across NAIRR resources

The CPU baseline has been established on JetStream2.

The next phase is to execute the **same workflow** on:

- AWS GPU instances (e.g., T4, A10G)
- NAIRR GPU systems (e.g., Delta, Bridges-2)

Each run will be compared using:

- Time per epoch
- Total training time
- Resource utilization
- Cost per run
- Speedup relative to CPU baseline

---

## JetStream2 Reference Run

The `main` branch contains the CPU baseline execution performed on JetStream2.

This run establishes the reference performance for comparison with GPU-enabled platforms.

Full execution protocol:
    docs/jetstream2_execution.md

To rerun on an existing JetStream2 GPU instance:

    conda env create -f env_exports/js2-forecast.yml
    conda activate js2-gpu-forecast
    bash scripts/run_jetstream2.sh

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