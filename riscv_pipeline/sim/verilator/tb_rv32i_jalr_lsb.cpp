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

void load_jalr_program() {
  imem.fill(0x00000013);
  dmem.fill(0);

  // x1 = 0x10000015 (홀수 주소)
  imem[idx(kImemBase + 0x00)] = 0x100000B7; // lui  x1,0x10000
  imem[idx(kImemBase + 0x04)] = 0x01508093; // addi x1,x1,21

  // hazard 제거용 nop
  imem[idx(kImemBase + 0x08)] = 0x00000013;
  imem[idx(kImemBase + 0x0C)] = 0x00000013;
  imem[idx(kImemBase + 0x10)] = 0x00000013;
  imem[idx(kImemBase + 0x14)] = 0x00000013;

  // jalr target = 0x10000015, 실제 PC는 0x10000014 여야 함
  imem[idx(kImemBase + 0x18)] = 0x000082E7; // jalr x5,x1,0

  // 관찰용 nop
  imem[idx(kImemBase + 0x1C)] = 0x00000013;
  imem[idx(kImemBase + 0x20)] = 0x00000013;
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
  tfp.open("sim/verilator/wave_jalr_lsb.fst");

  load_jalr_program();

  top.reset = 1;
  top.clk = 0;
  top.MemRData = 0;
  top.inst = 0;

  for (int i = 0; i < 8; ++i) tick(top, tfp);
  top.reset = 0;

  bool pass = false;

  for (int cycle = 0; cycle < 30; ++cycle) {
    tick(top, tfp);
    std::printf("[TB] cycle=%02d pc=%08x inst=%08x\n", cycle, top.pc, top.inst);

    // jalr 이후 정렬된 주소 0x10000014로 redirect되는지 확인
    if (cycle >= 7 && top.pc == 0x10000014u) {
      pass = true;
    }
  }

  tfp.close();
  top.final();

  if (!pass) {
    std::fprintf(stderr, "[TB][FAIL] JALR LSB alignment self-check failed.\n");
    return 1;
  }

  std::printf("[TB][PASS] JALR LSB alignment self-check passed.\n");
  return 0;
}
