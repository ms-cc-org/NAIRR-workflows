# Delta GPU Execution Workflow

Unlike VM-based systems, execution on Delta must go through Slurm.

**Execution model:**

- *Login node:* pull repo, prepare environment, stage data, submit job

- *Compute node (via Slurm):* execute notebook, capture logs, write artifacts

- Back on *login node*: inspect outputs, commit, push

## Connecting your system

`ssh <user>@login.delta.ncsa.illinois.edu`

## Setting up the repo

```
mkdir -p ~/repos
cd ~/repos
git clone https://github.com/ms-cc-org/NAIRR-workflows.git
cd NAIRR-workflows
git checkout -b delta-run-$(date +%Y%m%d)
```

## Dataset

The notebook expects the dataset at `7890488/` in the repository root.

**On a terminal in your system:**
`rsync -avP /path/to/7890488/ <user>@login.delta.ncsa.illinois.edu:/home/<user>/repos/NAIRR-workflows/7890488/`

**On delta SSH terminal:**
```
cd ~/repos/NAIRR-workflows
grep -n "7890488/" .gitignore || printf "\n# dataset (do not commit)\n7890488/\n" >> .gitignore
```

## Conda and packages setup

```
module purge
module load anaconda3 || true
module load cuda || true

conda create -n delta-forecast python=3.10 -y
conda activate delta-forecast

conda install -y -c conda-forge pandas numpy scikit-learn jupyter nbconvert ipykernel tqdm
conda install -y -c pytorch -c nvidia pytorch pytorch-cuda=12.1 torchvision torchaudio

python -m ipykernel install --user --name delta-forecast --display-name "delta-forecast"
```

## SLURM BATCH script

Use `platforms/delta/slurm/run_delta_gpu.slurm`.

Before submitting, edit this line:

```
#SBATCH -A YOUR_ALLOCATION
```

Confirm the partition, GPU type, CPU count, memory, and time limit match your
allocation.

## Submitting the job and post-submission

Make sure to use your allocation name in the sbatch script.

```
mkdir -p results/benchmarks results/system outputs/reports outputs/metrics outputs/models
sbatch platforms/delta/slurm/run_delta_gpu.slurm
squeue -u $USER
```

**Status codes:**
- PD = Pending
- R = Running

Wait until the job disappears from the queue. Once it disappears, it means the job is completed.

## Checking output

```
ls outputs/reports/forecasting.delta.executed.ipynb #if this says no directory found, the code didn't get executed 
tail -n 40 results/benchmarks/nbconvert_stderr_delta.txt #this shows you the error, and the exit code: 0 --> the job went through, 1 --> the job failed
```

## Commit and Push to github

```
git add outputs/reports/forecasting.delta.executed.ipynb
git add results/system/delta_env_snapshot.txt
git commit -m "Delta forecast execution and environment snapshot"
```
