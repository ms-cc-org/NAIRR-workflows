#!/usr/bin/env bash
set -euo pipefail

echo "NAIRR-workflows: choose a platform"
echo
echo "Platform guides: docs/platforms.md"
echo
echo "Quick commands:"
echo "  JetStream2:  bash platforms/jetstream2/scripts/run_jetstream2.sh"
echo "  AWS:         bash platforms/aws/scripts/run_aws.sh"
echo "  Bridges2:    sbatch platforms/bridges2/slurm/run_forecasting_b2.slurm"
echo "  Delta:       sbatch platforms/delta/slurm/run_delta_gpu.slurm"
echo "  Anvil:       sbatch platforms/anvil/slurm/run_anvil_gpu.slurm"
echo
echo "Evidence is archived under: runs/<platform>/<date>/"
