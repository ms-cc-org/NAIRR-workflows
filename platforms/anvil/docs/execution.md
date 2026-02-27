# Anvil GPU Execution flow

## Prerequisites

- Setting up anvil account, and ready to use with SSH

Remember, that any HPC has 2 different nodes: 
- **Login node:** This is the front-end node where you log in. We edit files, compile code, manage data, and submit jobs to the scheduler on this node. It is not meant for running heavy computations.

- **Compute node:** This is the back-end node where the actual computations run. When you submit a job, it is sent to a compute node, which has the CPU, GPU, and memory resources needed to perform the task given.

---

## Login

From your system:

`ssh username@anvil.rcac.purdue.edu`

---
## Setting up your HPC

```
mkdir -p ~/repos
cd ~/repos
git clone https://github.com/ms-cc-org/NAIRR-workflows.git
cd NAIRR-workflows
git checkout -b anvil-gpu-run-$(date +%Y%m%d)
```

---

## Module setup

As HPCs use module command.

```
module avail

module load anaconda
or
module load anaconda/2025.06-py313

If CUDA modules exist:
module avail cuda
module load cuda
```
---
## Conda

```
conda create -n anvil-forecast python=3.10 -y
conda activate anvil-forecast

conda install -y pandas numpy scikit-learn jupyter nbconvert ipykernel

conda install -y -c pytorch -c nvidia pytorch pytorch-cuda=12.1 torchvision torchaudio
```

---
## Dataset (Can be different based on your dataset)

From your system. To do this you have to have :
```
rsync -avP /path/to/7890488/ <username>@anvil.rcac.purdue.edu:~/repos/NAIRR-workflows/7890488/
```

## Sbatch script

**On HPC:**

```
cd ~/repos/NAIRR-workflows
mkdir -p results/system results/benchmarks outputs/reports
```

create a file: 

`nano file_name.slurm`

then, paste `run_anvil_gpu.slurm`. Make changes for allocation name, gpu, memory usage, time as you see fit.

Save it.

## Job scheduling

Enter command to submit a job: `sbatch file_name.slurm`

You'll get something like `Submitted batch job <job_id>`

You can track the job with `squeue -u $USER`

## Git Commit
```
conda env export > env_exports/anvil-forecast.yml
git add .gitignore
git add outputs/reports/forecasting.anvil.executed.ipynb
git add results/benchmarks/*anvil*
git add results/system/anvil_env_snapshot.txt

git commit -m "Anvil GPU execution: notebook + benchmarks + system snapshot"
git push -u origin anvil-gpu-run-$(date +%Y%m%d)
```
