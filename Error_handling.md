# Anvil Error Handling

### Loaded Python but became inactive after loading GPU module

```
x-pnara@login07.anvil:[NAIRR-workflows] $ module load anaconda/2024.02-py311
x-pnara@login07.anvil:[NAIRR-workflows] $ conda --version
conda 24.1.2
x-pnara@login07.anvil:[NAIRR-workflows] $ module load modtree/gpu

Inactive Modules:
  1) anaconda/2024.02-py311
...
x-pnara@login07.anvil:[NAIRR-workflows] $ module load anaconda/2024.02-py311
Lmod has detected the following error: The following module(s) are unknown…
```

**Cause:** When the environment switches to GPU mode, the previously loaded Anaconda module becomes inactive and unavailable. 

**Solution:**
```
module spider anaconda
module load anaconda/2025.06-py313
conda create -n anvil-forecast python=3.10 -y
```

### Error: PyTorch Import Failure – Undefined symbol iJIT_NotifyEvent

`ImportError: …libtorch_cpu.so: undefined symbol: iJIT_NotifyEvent`

**Solution:** Removing existing PyTorch packages:

`conda remove --force pytorch torchvision torchaudio pytorch-cuda -y`

Then installed PyTorch with CUDA:

`pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118`

### Error: CONDA_BACKUP_QT_XCB_GL_INTEGRATION unbound variable in SLURM job

`…/conda/deactivate.d/qt-main_deactivate.sh: line 5: CONDA_BACKUP_QT_XCB_GL_INTEGRATION: unbound variable`

**Solution:** Before activating Conda, source the conda initialization.

`source "$(conda info --base)/etc/profile.d/conda.sh"`

And simply removed the -u flag to make it `set -eo pipefail`

