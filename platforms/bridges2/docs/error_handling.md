# Bridges2 Error Handling

### rsync – No Such File or Directory (Code 23)

**Error**
`rsync: change_dir "/Users/pnara/Desktop/venv/Files/7890488" failed: No such file or directory (2)`

**Cause:** The command was executed from the VM (instead of local), or the source path did not exist on the local system.

**Solution:** Ensure you are on your local machine when transferring local files to Bridges-2. Verify the source path exists before running rsync.

### SLURM GPU Partition – Must Request Full Node

**Error:**
```
sbatch: error: Allocation in partition GPU must request all resources, gpu count 1 is low
sbatch: error: Batch job submission failed: Access/permission denied
```

**Cause:** The GPU partition on Bridges-2 requires full node allocations (8 or 16 GPUs). Requesting only 1 GPU violates that.

**Solution:** Requesting Full Node GPUs. Increase GPU request from 1 to 8.

or

Using Shared GPU Partition
```
#SBATCH -p GPU-shared
#SBATCH --gpus=v100-16:1
```

### CPUs per GPU Exceeded Maximum

**Error:**
```
sbatch: error: Allocation requested cpus-per-gpu higher than maximum of 5/gpu
sbatch: error: Batch job submission failed: Access/permission denied
```

**Cause:** On GPU-shared, each GPU has a maximum CPU allocation (5 CPUs per GPU).
The job requested more than allowed.

**Solution:** Reducing CPU request `#SBATCH --cpus-per-task=4`

### Memory Limit Exceeded on GPU-shared
**Error:** 
`sbatch: error: Allocation requested mem higher than maximum of 22750M/gpu`

**Cause:** On GPU-shared, each GPU has a strict memory cap (~22.75GB per GPU). Requested memory (32G) is over the limit.

**Solution:** Reducing memory allocation:
```
#SBATCH --mem=22G
#SBATCH --gpus=v100-16:1
```

### Conda + Module Conflict (MKL Variable Error)
**Error(SLURM Job Log):** `.../libblas_mkl_activate.sh: line 1: MKL_INTERFACE_LAYER: unbound variable`

**Cause:** 
- `module load anaconda3` and `conda activation` conflicted. 
- Some Conda activation scripts depend on MKL_INTERFACE_LAYER.
- The module environment might not be clean before activation.

**Solution:** Purge modules before activating Conda:
```
module purge
module load anaconda3 || true
module load cuda || true
conda activate bridges2-forecast
```

### Python Module Not Found (tqdm)

**Error(SLURM Log):** `ModuleNotFoundError: No module named 'tqdm'`

**Cause:** tqdm was not installed in the bridges2-forecast Conda environment.

**Solution:**
```
conda activate bridges2-forecast
conda install -y -c conda-forge tqdm
```

