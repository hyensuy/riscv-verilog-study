#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT_DIR"

verilator -Wall -Wno-fatal --cc --exe --build -O2 \
  --trace-fst \
  --top-module rv32i_cpu \
  -f sim/verilator/run.f \
  sim/verilator/tb_rv32i_pipeline.cpp

./obj_dir/Vrv32i_cpu
