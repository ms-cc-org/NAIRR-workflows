# Delta GPU Execution Workflow

Unlike VM-based systems, execution on Delta must go through SLURM/SBATCH script.

**Execution model:**

- *Login node:* pull repo, prepare environment, stage data, submit job

- *Compute node (via Slurm):* execute notebook, capture logs, write artifacts

- Back on *login node*: inspect outputs, commit, push

## Connecting your system

`ssh <user>@login.delta.ncsa.illinois.edu`

- You will be prompted to enter your password, and DUO security code.

## Setting up the repo

```
mkdir -p ~/repos
cd ~/repos
git clone https://github.com/ms-cc-org/NAIRR-workflows.git
cd NAIRR-workflows
git checkout -b delta-run-$(date +%Y%m%d)
```

## Dataset

**On a terminal in your system:**
`rsync -avP /path/to/7890488/  <user>@login.delta.ncsa.illinois.edu:/home/<user>/repos/NAIRR-workflows/7890488/`

**On Delta SSH terminal:**
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

Refer to [run_delta_gpu.slurm](https://github.com/ms-cc-org/NAIRR-workflows/blob/delta-run-20260218/run_delta_gpu.slurm)

## Submitting the job and post-submission

```
sbatch run_delta_gpu.slurm
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
#git add -A for the updated files, but make sure you setup your .gitignore to make sure not to upload larger and temp files
git commit -m "Delta forecast execution and environment snapshot"
git push
```
