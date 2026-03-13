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

void load_x0_program() {
  // x0 protection test
  // addi x0,x0,5 must be ignored.
  // Insert 2 nops before stores to separate x0 protection from store-data timing.
  imem[idx(kImemBase + 0x00)] = 0x00500013; // addi x0,x0,5   (must be ignored)
  imem[idx(kImemBase + 0x04)] = 0x00100093; // addi x1,x0,1   -> x1 = 1
  imem[idx(kImemBase + 0x08)] = 0x00100133; // add  x2,x0,x1  -> x2 = 1
  imem[idx(kImemBase + 0x0C)] = 0x00000013; // nop
  imem[idx(kImemBase + 0x10)] = 0x00000013; // nop
  imem[idx(kImemBase + 0x14)] = 0x00002023; // sw   x0,0(x0)  -> dmem[0] = 0
  imem[idx(kImemBase + 0x18)] = 0x00102223; // sw   x1,4(x0)  -> dmem[1] = 1
  imem[idx(kImemBase + 0x1C)] = 0x00202423; // sw   x2,8(x0)  -> dmem[2] = 1
  imem[idx(kImemBase + 0x20)] = 0x00000013; // nop
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
  tfp.open("sim/verilator/wave_x0.fst");

  imem.fill(0x00000013); // nop
  dmem.fill(0);
  load_x0_program();

  top.reset = 1;
  top.clk = 0;
  top.MemRData = 0;
  top.inst = 0;

  for (int i = 0; i < 8; ++i) tick(top, tfp);
  top.reset = 0;

  for (int cycle = 0; cycle < 100; ++cycle) {
    tick(top, tfp);
  }

  const bool pass =
      (dmem[0] == 0u) &&
      (dmem[1] == 1u) &&
      (dmem[2] == 1u);

  std::printf("[TB] done. pc=%08x dmem[0]=%08x dmem[1]=%08x dmem[2]=%08x\n",
              top.pc, dmem[0], dmem[1], dmem[2]);
  std::printf("[TB] fst: sim/verilator/wave_x0.fst\n");

  tfp.close();
  top.final();

  if (!pass) {
    std::fprintf(stderr, "[TB][FAIL] x0 protection self-check failed.\n");
    return 1;
  }

  std::printf("[TB][PASS] x0 protection self-check passed.\n");
  return 0;
}
