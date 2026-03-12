#include <verilated.h>
#include <verilated_fst_c.h>
#include "Vrv32i_cpu.h"

#include <array>
#include <cstdint>
#include <cstdio>

namespace {
constexpr uint32_t kImemBase = 0x10000000u;
constexpr size_t kWords = 1024;

std::array<uint32_t, kWords> imem{};
std::array<uint32_t, kWords> dmem{};

uint64_t g_time = 0;
double sc_time_stamp() { return static_cast<double>(g_time); }

inline uint32_t idx(uint32_t addr) { return (addr >> 2) & (kWords - 1); }

uint32_t read_word(uint32_t addr) {
  if ((addr & 0xF0000000u) == 0x10000000u) return imem[idx(addr)];
  return dmem[idx(addr)];
}

void write_word(uint32_t addr, uint32_t data, uint8_t be) {
  uint32_t &w = dmem[idx(addr)];
  for (int b = 0; b < 4; ++b) {
    if (be & (1u << b)) {
      const uint32_t mask = 0xFFu << (8 * b);
      w = (w & ~mask) | (data & mask);
    }
  }
}

void load_smoke_program() {
  // Core flow for smoke validation:
  // addi/add/sw/lw/beq/jal/jalr and redirected targets.
  imem[idx(kImemBase + 0x00)] = 0x00500093; // addi x1,x0,5
  imem[idx(kImemBase + 0x04)] = 0x00800113; // addi x2,x0,8
  imem[idx(kImemBase + 0x08)] = 0x002081B3; // add  x3,x1,x2
  imem[idx(kImemBase + 0x0C)] = 0x00302023; // sw   x3,0(x0)
  imem[idx(kImemBase + 0x10)] = 0x00002203; // lw   x4,0(x0)
  imem[idx(kImemBase + 0x14)] = 0x00320463; // beq  x4,x3,+8 => 0x1C
  imem[idx(kImemBase + 0x18)] = 0x00100293; // addi x5,x0,1 (flush candidate)
  imem[idx(kImemBase + 0x1C)] = 0x0080036F; // jal  x6,+8 => 0x24
  imem[idx(kImemBase + 0x20)] = 0x00100393; // addi x7,x0,1 (flush candidate)

  // Build x10 = 0x10000140 then jalr x9,x10,0 => 0x140
  imem[idx(kImemBase + 0x24)] = 0x10000537; // lui  x10,0x10000
  imem[idx(kImemBase + 0x28)] = 0x14050513; // addi x10,x10,0x140
  imem[idx(kImemBase + 0x2C)] = 0x000504E7; // jalr x9,x10,0
  imem[idx(kImemBase + 0x30)] = 0x00300593; // addi x11,x0,3 (flush candidate)

  imem[idx(kImemBase + 0x140)] = 0x00400613; // addi x12,x0,4
  imem[idx(kImemBase + 0x144)] = 0x00000013; // nop
}

void apply_comb(Vrv32i_cpu &top) {
  top.inst = read_word(top.pc);
  top.MemRData = read_word(top.MemAddr);
}

void tick(Vrv32i_cpu &top, VerilatedFstC &tfp) {
  top.clk = 0;
  apply_comb(top);
  top.eval();
  tfp.dump(g_time++);

  top.clk = 1;
  apply_comb(top);
  top.eval();
  if (top.MemWrite) write_word(top.MemAddr, top.MemWData, top.ByteEnable);
  tfp.dump(g_time++);
}
}  // namespace

int main(int argc, char **argv) {
  Verilated::commandArgs(argc, argv);
  Verilated::traceEverOn(true);

  Vrv32i_cpu top;
  VerilatedFstC tfp;
  top.trace(&tfp, 99);
  tfp.open("sim/verilator/wave_rv32i_pipeline.fst");

  imem.fill(0x00000013); // nop
  dmem.fill(0);
  load_smoke_program();
  top.reset = 1;
  top.clk = 0;
  top.MemRData = 0;
  top.inst = 0;

  for (int i = 0; i < 8; ++i) tick(top, tfp);
  top.reset = 0;

  bool seen_branch_target = false;
  bool seen_jal_target = false;
  bool seen_jalr_target = false;

  for (int cycle = 0; cycle < 600; ++cycle) {
    tick(top, tfp);
    if (top.pc == (kImemBase + 0x1C)) seen_branch_target = true;
    if (top.pc == (kImemBase + 0x24)) seen_jal_target = true;
    if (top.pc == (kImemBase + 0x140)) {
      seen_jalr_target = true;
      break;
    }
  }

  const bool mem_ok = (dmem[0] == 13u);
  const bool pass = mem_ok && seen_branch_target && seen_jal_target && seen_jalr_target;

  std::printf("[TB] done. pc=%08x Mem[0]=%08x\n", top.pc, dmem[0]);
  std::printf("[TB] checks: mem_ok=%d branch=%d jal=%d jalr=%d\n",
              mem_ok, seen_branch_target, seen_jal_target, seen_jalr_target);
  std::printf("[TB] fst: sim/verilator/wave_rv32i_pipeline.fst\n");

  tfp.close();
  top.final();

  if (!pass) {
    std::fprintf(stderr, "[TB][FAIL] Smoke self-check failed.\n");
    return 1;
  }

  std::printf("[TB][PASS] Smoke self-check passed.\n");
  return 0;
}
