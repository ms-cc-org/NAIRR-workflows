# **NAIRR Forecasting Benchmark**

One PyTorch forecasting notebook runs on CPU baseline and four GPU systems. 

JetStream2 16 vCPU \| AWS T4 \| Bridges-2 V100 \| Delta A100 \| Anvil H100

## **Comparisons to CPU baselines** 

### **Throughput: Relative to JetStream2 CPU**

| Platform | CPU/GPU | Relative Training throughput |
| :---: | :---: | :---: |
| JetStream2 | CPU | x1.0 |
| AWS | GPU \- T4 | x13.6 |
| Bridges-2 | GPU \- V100 | x24.1 |
| Delta | GPU \- A100 | x39.9 |
| Anvil | GPU \- H100 | x38.1 |

Speedup \= training samples per second / CPU samples per second. Throughput is used because each platform trained on a slightly different number of rows.

### **Average GPU Utilization (Training)**

| Platform | GPU | Avg GPU Util |
| :---: | :---: | :---: |
| AWS | T4 | 90% |
| Bridges-2 | V100 | 62% |
| Delta | A100 | 51% |
| Anvil | H100 | 31% |

Utilization falls as the GPU gets faster. On H100 the CPU-side data loader can’t keep the GPU fed.

### **Few things \- numbers support**

* Moving to GPU is best win  
  * The entry level T4 cuts 2.5 hr CPU training to 11 mins. Next each GPU switch saves minutes, not hours.  
* Delta (A100) and Anvil (H100) are tied  
  * The A100 and H100 differ by 4.5% in throughput.   
* The fastest GPUs wait on the data loader  
  * The H100 was busy only 31% of the time. If used, batched indexing or more loaders would let it pull ahead of A100.  
* Cost per run is negligible everywhere  
  * For AWS, the cost was under \$0.15 and for NAIRR systems, 0.15 GPU hours. 

### **Workload Comparison**

Projected from each platform’s measured throughput for the same job: 50 epochs over 2.4 million training rows.

| Platform | Throughput (samples/s) | Time/epoch (s) | 50-epoch training (min) | Speedup vs CPU | Speedup vs T4 |
| :---- | :---- | :---- | :---- | :---- | :---- |
| **JetStream2** 16 vCPU | 12,636 | 182.0 | 151.7 | 1.0x | 0.07x |
| **AWS** NVIDIA T4 16 GB | 172,109 | 13.4 | 11.1 | 13.6x | 1.0x |
| **Bridges2** NVIDIA V100 32 GB | 304,031 | 7.6 | 6.3 | 24.1x | 1.8x |
| **Delta** NVIDIA A100 40 GB | 503,688 | 4.6 | 3.8 | 39.9x | 2.9x |
| **Anvil** NVIDIA H100 80 GB | 481,976 | 4.8 | 4.0 | 38.1x | 2.8x |

### **Measured results, as per run**

Each platform’s final run values. All runs used the same model: a 7.4 M parameter MLP (width 1024, depth 8, 37 features, seed 42). 

| Platform | Epochs | Batch | Train rows | Avg time / epochs (s) | Training (min) | Notebook wall clock (min) | Peak GPU memory (MIB) | GPU Utilization |
| :---- | :---- | :---- | :---- | :---- | :---- | :---- | :---- | :---- |
| **JetStream2** CPU | 25 | 4096 | 1,958,581 | 155.01 | 64.59 | 64.98 | \- | \- |
| **AWS** T4 | 50 | 8192 | 2,169,453 | 12.61 | 10.51 | 10.86 | 1,655 | 90% |
| **Bridges2** V100 | 50 | 8192 | 2,477,703 | 8.16 | 6.8 | 7.21 | 1,902 | 62% |
| **Delta** A100 | 50 | 8192 | 2,420,843 | 4.82 | 4.02 | 4.45 | 2,009 | 51% |
| **Anvil** H100 | 50 | 8192 | 2,292,375 | 4.78 | 3.99 | 4.3 | 2,703 | 31% |

GPU Utilization is the mean of nvidia-smi samples, where the utilization is above 5%.

### **Cost and Allocation usage**

AWS bills in dollars. NAIRR systems charge in GPU hours against a NAIRR or ACCESS allocation, and JetStream2 charges SUs.

| Platform | Charged as  | Per run |
| :---: | :---: | :---: |
| **JetStream2** CPU, 16 VCPU instance | SU | 17.3 SU |
| **AWS** G4dn.2xlarge, \$0.752/h | USD | \$0.14 |
| **Bridges2** V100 | GPU-hours | 0.12 |
| **Delta** A100 | GPU-hours | 0.07 |
| **Anvil** H100 | GPU-hours | 0.07 |
