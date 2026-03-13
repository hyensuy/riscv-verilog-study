#!/usr/bin/env bash
set -e

tests=(
  sim/verilator/run_forwarding.f
  sim/verilator/run_load_use.f
  sim/verilator/run_flush.f
  sim/verilator/run_branch_not_taken.f
  sim/verilator/run_x0.f
  sim/verilator/run_jalr_lsb.f
  sim/verilator/run_store_timing.f
  sim/verilator/run_full_regress.f
)

for t in "${tests[@]}"; do
  echo "===== $t ====="
  verilator -Wall -Wno-fatal --cc --exe --build -O2 --trace-fst \
    --top-module rv32i_cpu \
    -f "$t"
  ./obj_dir/Vrv32i_cpu
done
