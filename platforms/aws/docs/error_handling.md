# AWS Error handling

### Incorrect SSH Username When Connecting to VM

**Error:** SSH connection failed due to using the wrong default username for the AMI.

**Solution:** 
| AMI Type     |	Username |
|--------------|-----------|
| Ubuntu AMI   |	ubuntu   |
| Amazon Linux |	ec2-user |


### Git LFS Downloaded Pointer Files Instead of Actual CSV Data

**Error:** Cloning the dataset repository:

git clone --depth 1 https://github.com/radames/dataset-historical-daily-temperature-210-US.git 7890488_src

**Resulted in:** .csv files that were not actual data files, files were Git LFS pointer files.

**Solution:**
- Replaced the LFS-based dataset with a non-LFS source
- Used rsync for direct and reliable data transfer

### Miniconda Not Installed in VM
**Error:** Conda was not available in the fresh VM environment.

**Solution:** Download Miniconda `wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh`

**Run Installer:** `Miniconda3-latest-Linux-x86_64.sh`

**Installation steps:**
- Press Enter
- Type yes
- Accept default install location

### Broken or Corrupted Conda Packages
**Error:** Environment issues due to corrupted or incomplete package installations.

**Solution:**

Clean Conda and remove cache:
```
conda clean --all -y
rm -rf ~/miniconda3/pkgs/*
```

