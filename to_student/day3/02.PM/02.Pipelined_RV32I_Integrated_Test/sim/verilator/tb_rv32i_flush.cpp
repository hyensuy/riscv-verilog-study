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

void load_flush_program() {
  // Flush verification test using JAL
  // jal must redirect to 0x10000010
  // instructions at 0x08 and 0x0C must be flushed and not commit.
  imem[idx(kImemBase + 0x00)] = 0x00100093; // addi x1,x0,1
  imem[idx(kImemBase + 0x04)] = 0x00C002EF; // jal  x5,+12 -> 0x10
  imem[idx(kImemBase + 0x08)] = 0x00900113; // addi x2,x0,9  (flush candidate)
  imem[idx(kImemBase + 0x0C)] = 0x00900193; // addi x3,x0,9  (flush candidate)
  imem[idx(kImemBase + 0x10)] = 0x00300213; // addi x4,x0,3
  imem[idx(kImemBase + 0x14)] = 0x00102023; // sw   x1,0(x0)
  imem[idx(kImemBase + 0x18)] = 0x00202223; // sw   x2,4(x0)
  imem[idx(kImemBase + 0x1C)] = 0x00302423; // sw   x3,8(x0)
  imem[idx(kImemBase + 0x20)] = 0x00402623; // sw   x4,12(x0)
  imem[idx(kImemBase + 0x24)] = 0x00000013; // nop
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
  tfp.open("sim/verilator/wave_flush.fst");

  imem.fill(0x00000013); // nop
  dmem.fill(0);
  load_flush_program();

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
      (dmem[0] == 1u) &&
      (dmem[1] == 0u) &&
      (dmem[2] == 0u) &&
      (dmem[3] == 3u);

  std::printf("[TB] done. pc=%08x dmem[0]=%08x dmem[1]=%08x dmem[2]=%08x dmem[3]=%08x\n",
              top.pc, dmem[0], dmem[1], dmem[2], dmem[3]);
  std::printf("[TB] fst: sim/verilator/wave_flush.fst\n");

  tfp.close();
  top.final();

  if (!pass) {
    std::fprintf(stderr, "[TB][FAIL] Flush self-check failed.\n");
    return 1;
  }

  std::printf("[TB][PASS] Flush self-check passed.\n");
  return 0;
}
