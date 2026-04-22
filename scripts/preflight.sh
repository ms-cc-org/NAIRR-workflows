#!/usr/bin/env bash
set -euo pipefail

platform="${1:-}"

if [ -z "$platform" ]; then
  echo "Usage: bash scripts/preflight.sh <jetstream2|aws|bridges2|delta|anvil>"
  exit 2
fi

case "$platform" in
  jetstream2|aws|bridges2|delta|anvil) ;;
  *)
    echo "Unknown platform: $platform"
    echo "Expected one of: jetstream2, aws, bridges2, delta, anvil"
    exit 2
    ;;
esac

echo "== Repository =="
git rev-parse --show-toplevel
git status --short

echo
echo "== Dataset =="
if [ -f "7890488/city_info.csv" ]; then
  csv_count="$(find 7890488 -maxdepth 1 -name '*.csv' | wc -l | tr -d ' ')"
  echo "Found 7890488/city_info.csv and ${csv_count} CSV files."
else
  echo "Missing 7890488/city_info.csv"
  echo "Stage the dataset before running the notebook."
fi

echo
echo "== Conda =="
if command -v conda >/dev/null 2>&1; then
  conda --version
else
  echo "conda not found on PATH"
fi

echo
echo "== Python and notebook tools =="
command -v python || true
command -v jupyter || true

echo
echo "== GPU =="
if command -v nvidia-smi >/dev/null 2>&1; then
  nvidia-smi -L || true
else
  echo "nvidia-smi not found; this is expected on CPU-only tests."
fi

if [ "$platform" = "bridges2" ] || [ "$platform" = "delta" ] || [ "$platform" = "anvil" ]; then
  echo
  echo "== Slurm =="
  command -v sbatch || true
  command -v squeue || true
  echo "Remember to edit #SBATCH -A YOUR_ALLOCATION before submitting."
fi
