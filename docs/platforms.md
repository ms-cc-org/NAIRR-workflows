# Platform guides

For a participant-facing walkthrough, start with:

- `WORKSHOP.md`

Pick your platform and follow the execution guide:

- JetStream2 (CPU smoke test): `platforms/jetstream2/docs/execution.md`
- AWS (GPU VM): `platforms/aws/docs/execution.md`
- Bridges-2 (HPC GPU, Slurm): `platforms/bridges2/docs/execution.md`
- Delta (HPC GPU, Slurm): `platforms/delta/docs/execution.md`
- Anvil (HPC GPU, Slurm): `platforms/anvil/docs/execution.md`

Quick command index:

```bash
bash scripts/run.sh
bash platforms/jetstream2/scripts/run_jetstream2.sh
bash platforms/aws/scripts/run_aws.sh
sbatch platforms/bridges2/slurm/run_forecasting_b2.slurm
sbatch platforms/delta/slurm/run_delta_gpu.slurm
sbatch platforms/anvil/slurm/run_anvil_gpu.slurm
```

Before running, stage the dataset at `7890488/` and create the platform Conda
environment from `platforms/<platform>/env_exports/`.

## Evidence (runs)

Completed executions are archived under:

`runs/<platform>/<YYYY-MM-DD>/`

Examples:
- `runs/aws/2026-03-04/`
- `runs/bridges2/2026-03-04/`
- `runs/delta/2026-03-04/`
- `runs/anvil/2026-03-04/`
