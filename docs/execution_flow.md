# Bridges-2 GPU Execution Workflow

Unlike VM-based systems, execution on Bridges-2 must go through Slurm.

**Execution model:**

- *Login node:* pull repo, prepare environment, stage data, submit job

- *Compute node (via Slurm):* execute notebook, capture logs, write artifacts

- Back on *login node*: inspect outputs, commit, push

## Connecting your system

`ssh <user>@bridges2.psc.edu`

## Setting up the repo

```
mkdir -p ~/repos
cd ~/repos
git clone https://github.com/ms-cc-org/NAIRR-workflows.git
cd NAIRR-workflows
git checkout -b bridges2-run-$(date +%Y%m%d)
```

## Dataset

**On a terminal in your system:**
`rsync -avP /path/to/7890488/ <user>@bridges2.psc.edu:/home/<user>/repos/NAIRR-workflows/7890488/`

**On Bridges2 SSH terminal:**
```
cd ~/repos/NAIRR-workflows
grep -n "7890488/" .gitignore || printf "\n# dataset (do not commit)\n7890488/\n" >> .gitignore
```

## Conda and packages setup

```
module purge
module load anaconda3 || true
module load cuda || true

conda create -n bridges2-forecast python=3.10 -y
conda activate bridges2-forecast

conda install -y -c conda-forge pandas numpy scikit-learn jupyter nbconvert ipykernel tqdm
conda install -y -c pytorch -c nvidia pytorch pytorch-cuda=12.1 torchvision torchaudio

python -m ipykernel install --user --name b2-forecast --display-name "b2-forecast"
```

## SLURM BATCH script

Refer to (run_forecasting_b2.slurm)[https://github.com/ms-cc-org/NAIRR-workflows/blob/bridges2-run-20260216/run_forecasting_b2.slurm]

## Submitting the job and post-submission

```
sbatch run_forecasting_b2.slurm
squeue -u $USER
```

**Status codes:**
- PD = Pending
- R = Running

Wait until the job disappears from the queue. Once it disappears, it means the job is completed.

## Checking output

```
ls outputs/reports/forecasting.b2.executed.ipynb #if this says no directory found, the code didn't get executed 
tail -n 40 results/benchmarks/nbconvert_stderr_b2.txt #this shows you the error, and the exit code: 0 --> the job went through, 1 --> the job failed
```

## Commit and Push to github

```
git add outputs/reports/forecasting.b2.executed.ipynb
git add results/system/b2_env_snapshot.txt
#git add -A for the updated files, but make sure you setup your .gitignore to make sure not to upload larger and temp files
git commit -m "Bridges-2 forecast execution and environment snapshot"
git push
```