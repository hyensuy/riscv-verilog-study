#include <verilated.h>
#include <verilated_fst_c.h>

#include <array>
#include <cstdint>
#include <iostream>

#include "Vrv32i_cpu.h"
#include "Vrv32i_cpu___024root.h"

namespace {

constexpr uint32_t RESET_PC      = 0x10000000u;
constexpr uint32_t TIMEOUT_CYCLE = 25u;
constexpr uint32_t MEM_WORDS     = 1u << 12;

// Opcodes
constexpr uint32_t OPC_LUI       = 0b0110111;
constexpr uint32_t OPC_AUIPC     = 0b0010111;
constexpr uint32_t OPC_JAL       = 0b1101111;
constexpr uint32_t OPC_JALR      = 0b1100111;
constexpr uint32_t OPC_BRANCH    = 0b1100011;
constexpr uint32_t OPC_STORE     = 0b0100011;
constexpr uint32_t OPC_LOAD      = 0b0000011;
constexpr uint32_t OPC_ARI_RTYPE = 0b0110011;
constexpr uint32_t OPC_ARI_ITYPE = 0b0010011;

// funct3
constexpr uint32_t FNC_BEQ     = 0b000;
constexpr uint32_t FNC_BNE     = 0b001;
constexpr uint32_t FNC_BLT     = 0b100;
constexpr uint32_t FNC_BGE     = 0b101;
constexpr uint32_t FNC_BLTU    = 0b110;
constexpr uint32_t FNC_BGEU    = 0b111;
constexpr uint32_t FNC_LB      = 0b000;
constexpr uint32_t FNC_LH      = 0b001;
constexpr uint32_t FNC_LW      = 0b010;
constexpr uint32_t FNC_LBU     = 0b100;
constexpr uint32_t FNC_LHU     = 0b101;
constexpr uint32_t FNC_SB      = 0b000;
constexpr uint32_t FNC_SH      = 0b001;
constexpr uint32_t FNC_SW      = 0b010;
constexpr uint32_t FNC_ADD_SUB = 0b000;
constexpr uint32_t FNC_SLL     = 0b001;
constexpr uint32_t FNC_SLT     = 0b010;
constexpr uint32_t FNC_SLTU    = 0b011;
constexpr uint32_t FNC_XOR     = 0b100;
constexpr uint32_t FNC_OR      = 0b110;
constexpr uint32_t FNC_AND     = 0b111;
constexpr uint32_t FNC_SRL_SRA = 0b101;

constexpr uint32_t FNC7_0 = 0b0000000;
constexpr uint32_t FNC7_1 = 0b0100000;

inline uint32_t mask12(int32_t x) { return static_cast<uint32_t>(x) & 0xFFFu; }
inline uint32_t mask13(int32_t x) { return static_cast<uint32_t>(x) & 0x1FFFu; }
inline uint32_t mask21(int32_t x) { return static_cast<uint32_t>(x) & 0x1FFFFFu; }

inline uint32_t enc_r(uint32_t funct7, uint32_t rs2, uint32_t rs1,
                      uint32_t funct3, uint32_t rd, uint32_t opcode) {
    return ((funct7 & 0x7Fu) << 25) |
           ((rs2    & 0x1Fu) << 20) |
           ((rs1    & 0x1Fu) << 15) |
           ((funct3 & 0x7u)  << 12) |
           ((rd     & 0x1Fu) << 7)  |
           ( opcode & 0x7Fu);
}

inline uint32_t enc_i(uint32_t imm12, uint32_t rs1, uint32_t funct3,
                      uint32_t rd, uint32_t opcode) {
    return ((imm12  & 0xFFFu) << 20) |
           ((rs1    & 0x1Fu)  << 15) |
           ((funct3 & 0x7u)   << 12) |
           ((rd     & 0x1Fu)  << 7)  |
           ( opcode & 0x7Fu);
}

inline uint32_t enc_s(uint32_t imm12, uint32_t rs2, uint32_t rs1,
                      uint32_t funct3, uint32_t opcode) {
    return (((imm12 >> 5) & 0x7Fu) << 25) |
           ((rs2    & 0x1Fu)       << 20) |
           ((rs1    & 0x1Fu)       << 15) |
           ((funct3 & 0x7u)        << 12) |
           ((imm12  & 0x1Fu)       << 7)  |
           ( opcode & 0x7Fu);
}

inline uint32_t enc_b(uint32_t imm13, uint32_t rs2, uint32_t rs1,
                      uint32_t funct3, uint32_t opcode) {
    return (((imm13 >> 12) & 0x1u)  << 31) |
           (((imm13 >> 5)  & 0x3Fu) << 25) |
           ((rs2           & 0x1Fu) << 20) |
           ((rs1           & 0x1Fu) << 15) |
           ((funct3        & 0x7u)  << 12) |
           (((imm13 >> 1)  & 0xFu)  << 8)  |
           (((imm13 >> 11) & 0x1u)  << 7)  |
           ( opcode        & 0x7Fu);
}

inline uint32_t enc_u(uint32_t imm32, uint32_t rd, uint32_t opcode) {
    return (imm32 & 0xFFFFF000u) |
           ((rd & 0x1Fu) << 7)   |
           (opcode & 0x7Fu);
}

inline uint32_t enc_j(uint32_t imm21, uint32_t rd, uint32_t opcode) {
    return (((imm21 >> 20) & 0x1u)   << 31) |
           (((imm21 >> 1)  & 0x3FFu) << 21) |
           (((imm21 >> 11) & 0x1u)   << 20) |
           (((imm21 >> 12) & 0xFFu)  << 12) |
           ((rd            & 0x1Fu)  << 7)  |
           ( opcode        & 0x7Fu);
}

class Tb {
public:
    explicit Tb(const char* trace_name) {
        top_ = new Vrv32i_cpu;
        tfp_ = new VerilatedFstC;
        sim_time_ = 0;

        top_->clk = 0;
        top_->reset = 1;
        top_->inst = 0;
        top_->MemRData = 0;

        Verilated::traceEverOn(true);
        top_->trace(tfp_, 99);
        tfp_->open(trace_name);

        eval_and_dump();
    }

    ~Tb() {
        if (top_) top_->final();
        if (tfp_) tfp_->close();
        delete tfp_;
        delete top_;
    }

    uint32_t& rf(int idx) {
        // 현재 프로젝트에서 가장 가능성 높은 경로
        return top_->rootp->rv32i_cpu__DOT__u_cpu__DOT__i_datapath__DOT__rf__DOT__mem[idx];
    }

    uint32_t& mem(uint32_t idx) {
        return umem_[idx & (MEM_WORDS - 1u)];
    }

    void reset_memories() {
        for (int i = 0; i < 32; ++i) rf(i) = 0;
        for (auto& w : umem_) w = 0;
        eval_only();
    }

    void init_rf() {
        for (int i = 1; i < 32; ++i) rf(i) = 100u * static_cast<uint32_t>(i) + 1u;
        eval_only();
    }

    void cpu_reset_sequence() {
        top_->reset = 1;
        for (int i = 0; i < 3; ++i) tick();
        top_->reset = 0;
        tick();
    }

    void powerup_reset_sequence() {
        top_->reset = 1;
        for (int i = 0; i < 10; ++i) tick();
        top_->reset = 0;
        tick();
    }

    void check_rf(uint32_t test_id, int rf_wa, uint32_t expected, const char* name) {
        wait_until([&]() { return rf(rf_wa) == expected; },
                   [&]() { return rf(rf_wa); },
                   test_id, name, expected);
    }

    void check_mem(uint32_t test_id, int addr, uint32_t expected, const char* name) {
        wait_until([&]() { return mem(addr) == expected; },
                   [&]() { return mem(addr); },
                   test_id, name, expected);
    }

private:
    Vrv32i_cpu* top_ = nullptr;
    VerilatedFstC* tfp_ = nullptr;
    uint64_t sim_time_ = 0;
    std::array<uint32_t, MEM_WORDS> umem_{};

    static inline uint32_t word_index(uint32_t byte_addr) {
        return (byte_addr >> 2) & (MEM_WORDS - 1u);
    }

    uint32_t read_word(uint32_t byte_addr) {
        return umem_[word_index(byte_addr)];
    }

    void write_word(uint32_t byte_addr, uint32_t data, uint8_t be) {
        uint32_t& w = umem_[word_index(byte_addr)];
        for (int b = 0; b < 4; ++b) {
            if (be & (1u << b)) {
                const uint32_t mask = 0xFFu << (8 * b);
                w = (w & ~mask) | (data & mask);
            }
        }
    }

    void drive_comb() {
        top_->inst = read_word(top_->pc);
        top_->MemRData = read_word(top_->MemAddr);
    }

    void eval_only() {
        drive_comb();
        top_->eval();
    }

    void eval_and_dump() {
        drive_comb();
        top_->eval();
        tfp_->dump(sim_time_);
    }

    void tick() {
        top_->clk = 0;
        eval_and_dump();
        sim_time_ += 10;

        top_->clk = 1;
        drive_comb();
        top_->eval();
        if (top_->MemWrite) {
            write_word(top_->MemAddr, top_->MemWData, top_->ByteEnable);
        }
        tfp_->dump(sim_time_);
        sim_time_ += 10;
    }

    void fail(uint32_t test_id, const char* name, uint32_t expected, uint32_t got) {
        std::cerr << "[Failed] Timeout at [" << test_id << "] test " << name
                  << ", expected_result = 0x" << std::hex << expected
                  << ", got = 0x" << got << std::dec << '\n';
        throw 1;
    }

    template <typename CondFn, typename ReadFn>
    void wait_until(CondFn cond, ReadFn read_current, uint32_t test_id,
                    const char* name, uint32_t expected) {
        uint32_t cycle = 0;
        uint32_t current = read_current();

        while (!cond()) {
            if (cycle == TIMEOUT_CYCLE) {
                fail(test_id, name, expected, current);
            }
            tick();
            ++cycle;
            current = read_current();
        }

        std::cout << "[" << test_id << "] Test " << name << " passed!\n";
    }
};

}  // namespace

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);

    try {
        Tb tb("sim/verilator/wave_full_regress.fst");
        uint32_t test_id = 0;

        int i;
        uint32_t RD, RS1, RS2, RD1, RD2, SHAMT, IMM, IMM0, IMM1, IMM2, IMM3;
        uint32_t INST_ADDR, DATA_ADDR;
        uint32_t DATA_ADDR0, DATA_ADDR1, DATA_ADDR2, DATA_ADDR3;
        uint32_t DATA_ADDR4, DATA_ADDR5, DATA_ADDR6, DATA_ADDR7, DATA_ADDR8;
        uint32_t JUMP_ADDR;

        uint32_t BR_TAKEN_OP1[6]  = {};
        uint32_t BR_TAKEN_OP2[6]  = {};
        uint32_t BR_NTAKEN_OP1[6] = {};
        uint32_t BR_NTAKEN_OP2[6] = {};
        uint32_t BR_TYPE[6]       = {};
        const char* BR_NAME_TK1[6];
        const char* BR_NAME_TK2[6];
        const char* BR_NAME_NTK[6];

        tb.powerup_reset_sequence();

        // R-Type -----------------------------------------------------------
        tb.reset_memories();
        RS1 = 1; RD1 = static_cast<uint32_t>(-100);
        RS2 = 2; RD2 = 200;
        RD  = 3;
        tb.rf(RS1) = RD1;
        tb.rf(RS2) = RD2;
        SHAMT      = 20;
        INST_ADDR  = 0x0000;

        tb.mem(INST_ADDR + 0)  = enc_r(FNC7_0, RS2,   RS1, FNC_ADD_SUB,  3, OPC_ARI_RTYPE);
        tb.mem(INST_ADDR + 1)  = enc_r(FNC7_1, RS2,   RS1, FNC_ADD_SUB,  4, OPC_ARI_RTYPE);
        tb.mem(INST_ADDR + 2)  = enc_r(FNC7_0, RS2,   RS1, FNC_SLL,      5, OPC_ARI_RTYPE);
        tb.mem(INST_ADDR + 3)  = enc_r(FNC7_0, RS2,   RS1, FNC_SLT,      6, OPC_ARI_RTYPE);
        tb.mem(INST_ADDR + 4)  = enc_r(FNC7_0, RS2,   RS1, FNC_SLTU,     7, OPC_ARI_RTYPE);
        tb.mem(INST_ADDR + 5)  = enc_r(FNC7_0, RS2,   RS1, FNC_XOR,      8, OPC_ARI_RTYPE);
        tb.mem(INST_ADDR + 6)  = enc_r(FNC7_0, RS2,   RS1, FNC_OR,       9, OPC_ARI_RTYPE);
        tb.mem(INST_ADDR + 7)  = enc_r(FNC7_0, RS2,   RS1, FNC_AND,     10, OPC_ARI_RTYPE);
        tb.mem(INST_ADDR + 8)  = enc_r(FNC7_0, RS2,   RS1, FNC_SRL_SRA, 11, OPC_ARI_RTYPE);
        tb.mem(INST_ADDR + 9)  = enc_r(FNC7_1, RS2,   RS1, FNC_SRL_SRA, 12, OPC_ARI_RTYPE);
        tb.mem(INST_ADDR + 10) = enc_i((FNC7_0 << 5) | SHAMT, RS1, FNC_SLL,     13, OPC_ARI_ITYPE);
        tb.mem(INST_ADDR + 11) = enc_i((FNC7_0 << 5) | SHAMT, RS1, FNC_SRL_SRA, 14, OPC_ARI_ITYPE);
        tb.mem(INST_ADDR + 12) = enc_i((FNC7_1 << 5) | SHAMT, RS1, FNC_SRL_SRA, 15, OPC_ARI_ITYPE);
        tb.cpu_reset_sequence();

        tb.check_rf(++test_id, 3,  0x00000064u, "R-Type ADD");
        tb.check_rf(++test_id, 4,  0xfffffed4u, "R-Type SUB");
        tb.check_rf(++test_id, 5,  0xffff9c00u, "R-Type SLL");
        tb.check_rf(++test_id, 6,  0x00000001u, "R-Type SLT");
        tb.check_rf(++test_id, 7,  0x00000000u, "R-Type SLTU");
        tb.check_rf(++test_id, 8,  0xffffff54u, "R-Type XOR");
        tb.check_rf(++test_id, 9,  0xffffffdcu, "R-Type OR");
        tb.check_rf(++test_id,10,  0x00000088u, "R-Type AND");
        tb.check_rf(++test_id,11,  0x00ffffffu, "R-Type SRL");
        tb.check_rf(++test_id,12,  0xffffffffu, "R-Type SRA");
        tb.check_rf(++test_id,13,  0xf9c00000u, "R-Type SLLI");
        tb.check_rf(++test_id,14,  0x00000fffu, "R-Type SRLI");
        tb.check_rf(++test_id,15,  0xffffffffu, "R-Type SRAI");

        // I-Type arithmetic -----------------------------------------------
        tb.reset_memories();
        RS1 = 1; RD1 = static_cast<uint32_t>(-100);
        tb.rf(RS1) = RD1;
        IMM = static_cast<uint32_t>(-200);
        INST_ADDR = 0;
        tb.mem(INST_ADDR + 0) = enc_i(mask12(static_cast<int32_t>(IMM)), RS1, FNC_ADD_SUB, 3, OPC_ARI_ITYPE);
        tb.mem(INST_ADDR + 1) = enc_i(mask12(static_cast<int32_t>(IMM)), RS1, FNC_SLT,     4, OPC_ARI_ITYPE);
        tb.mem(INST_ADDR + 2) = enc_i(mask12(static_cast<int32_t>(IMM)), RS1, FNC_SLTU,    5, OPC_ARI_ITYPE);
        tb.mem(INST_ADDR + 3) = enc_i(mask12(static_cast<int32_t>(IMM)), RS1, FNC_XOR,     6, OPC_ARI_ITYPE);
        tb.mem(INST_ADDR + 4) = enc_i(mask12(static_cast<int32_t>(IMM)), RS1, FNC_OR,      7, OPC_ARI_ITYPE);
        tb.mem(INST_ADDR + 5) = enc_i(mask12(static_cast<int32_t>(IMM)), RS1, FNC_AND,     8, OPC_ARI_ITYPE);
        tb.cpu_reset_sequence();

        tb.check_rf(++test_id, 3, 0xfffffed4u, "I-Type ADD");
        tb.check_rf(++test_id, 4, 0x00000000u, "I-Type SLT");
        tb.check_rf(++test_id, 5, 0x00000000u, "I-Type SLTU");
        tb.check_rf(++test_id, 6, 0x000000a4u, "I-Type XOR");
        tb.check_rf(++test_id, 7, 0xffffffbcu, "I-Type OR");
        tb.check_rf(++test_id, 8, 0xffffff18u, "I-Type AND");

        // I-Type loads ----------------------------------------------------
        tb.reset_memories();
        tb.rf(1) = 0x30000100u;
        IMM0 = 0; IMM1 = 1; IMM2 = 2; IMM3 = 3;
        INST_ADDR = 0;
        DATA_ADDR = (tb.rf(1) + IMM0) >> 2;

        tb.mem(INST_ADDR + 0)  = enc_i(IMM0, 1, FNC_LW,  2,  OPC_LOAD);
        tb.mem(INST_ADDR + 1)  = enc_i(IMM0, 1, FNC_LH,  3,  OPC_LOAD);
        tb.mem(INST_ADDR + 4)  = enc_i(IMM2, 1, FNC_LH,  5,  OPC_LOAD);
        tb.mem(INST_ADDR + 6)  = enc_i(IMM0, 1, FNC_LB,  7,  OPC_LOAD);
        tb.mem(INST_ADDR + 7)  = enc_i(IMM1, 1, FNC_LB,  8,  OPC_LOAD);
        tb.mem(INST_ADDR + 8)  = enc_i(IMM2, 1, FNC_LB,  9,  OPC_LOAD);
        tb.mem(INST_ADDR + 9)  = enc_i(IMM3, 1, FNC_LB, 10,  OPC_LOAD);
        tb.mem(INST_ADDR + 10) = enc_i(IMM0, 1, FNC_LHU,11,  OPC_LOAD);
        tb.mem(INST_ADDR + 12) = enc_i(IMM2, 1, FNC_LHU,13,  OPC_LOAD);
        tb.mem(INST_ADDR + 14) = enc_i(IMM0, 1, FNC_LBU,15,  OPC_LOAD);
        tb.mem(INST_ADDR + 15) = enc_i(IMM1, 1, FNC_LBU,16,  OPC_LOAD);
        tb.mem(INST_ADDR + 16) = enc_i(IMM2, 1, FNC_LBU,17,  OPC_LOAD);
        tb.mem(INST_ADDR + 17) = enc_i(IMM3, 1, FNC_LBU,18,  OPC_LOAD);
        tb.mem(DATA_ADDR)      = 0xdeadbeefu;
        tb.cpu_reset_sequence();

        tb.check_rf(++test_id,  2, 0xdeadbeefu, "I-Type LW");
        tb.check_rf(++test_id,  3, 0xffffbeefu, "I-Type LH 0");
        tb.check_rf(++test_id,  5, 0xffffdeadu, "I-Type LH 2");
        tb.check_rf(++test_id,  7, 0xffffffefu, "I-Type LB 0");
        tb.check_rf(++test_id,  8, 0xffffffbeu, "I-Type LB 1");
        tb.check_rf(++test_id,  9, 0xffffffadu, "I-Type LB 2");
        tb.check_rf(++test_id, 10, 0xffffffdeu, "I-Type LB 3");
        tb.check_rf(++test_id, 11, 0x0000beefu, "I-Type LHU 0");
        tb.check_rf(++test_id, 13, 0x0000deadu, "I-Type LHU 2");
        tb.check_rf(++test_id, 15, 0x000000efu, "I-Type LBU 0");
        tb.check_rf(++test_id, 16, 0x000000beu, "I-Type LBU 1");
        tb.check_rf(++test_id, 17, 0x000000adu, "I-Type LBU 2");
        tb.check_rf(++test_id, 18, 0x000000deu, "I-Type LBU 3");

        // S-Type ----------------------------------------------------------
        tb.reset_memories();
        tb.rf(1)  = 0x12345678u;
        tb.rf(2)  = 0x30000010u;
        tb.rf(3)  = 0x30000020u;
        tb.rf(4)  = 0x30000030u;
        tb.rf(5)  = 0x30000040u;
        tb.rf(6)  = 0x30000050u;
        tb.rf(7)  = 0x30000060u;
        tb.rf(8)  = 0x30000070u;
        tb.rf(9)  = 0x30000080u;
        tb.rf(10) = 0x30000090u;

        IMM0 = 0x100; IMM1 = 0x101; IMM2 = 0x102; IMM3 = 0x103;
        INST_ADDR = 0;

        DATA_ADDR0 = (tb.rf(2)  + IMM0) >> 2;
        DATA_ADDR1 = (tb.rf(3)  + IMM0) >> 2;
        DATA_ADDR2 = (tb.rf(4)  + IMM1) >> 2;
        DATA_ADDR3 = (tb.rf(5)  + IMM2) >> 2;
        DATA_ADDR4 = (tb.rf(6)  + IMM3) >> 2;
        DATA_ADDR5 = (tb.rf(7)  + IMM0) >> 2;
        DATA_ADDR6 = (tb.rf(8)  + IMM1) >> 2;
        DATA_ADDR7 = (tb.rf(9)  + IMM2) >> 2;
        DATA_ADDR8 = (tb.rf(10) + IMM3) >> 2;

        tb.mem(INST_ADDR + 0) = enc_s(IMM0, 1, 2,  FNC_SW, OPC_STORE);
        tb.mem(INST_ADDR + 1) = enc_s(IMM0, 1, 3,  FNC_SH, OPC_STORE);
        tb.mem(INST_ADDR + 3) = enc_s(IMM2, 1, 5,  FNC_SH, OPC_STORE);
        tb.mem(INST_ADDR + 5) = enc_s(IMM0, 1, 7,  FNC_SB, OPC_STORE);
        tb.mem(INST_ADDR + 6) = enc_s(IMM1, 1, 8,  FNC_SB, OPC_STORE);
        tb.mem(INST_ADDR + 7) = enc_s(IMM2, 1, 9,  FNC_SB, OPC_STORE);
        tb.mem(INST_ADDR + 8) = enc_s(IMM3, 1, 10, FNC_SB, OPC_STORE);

        tb.mem(DATA_ADDR0) = 0;
        tb.mem(DATA_ADDR1) = 0;
        tb.mem(DATA_ADDR3) = 0;
        tb.mem(DATA_ADDR4) = 0;
        tb.mem(DATA_ADDR5) = 0;
        tb.mem(DATA_ADDR6) = 0;
        tb.mem(DATA_ADDR7) = 0;
        tb.mem(DATA_ADDR8) = 0;
        tb.cpu_reset_sequence();

        tb.check_mem(++test_id, DATA_ADDR0, 0x12345678u, "S-Type SW");
        tb.check_mem(++test_id, DATA_ADDR1, 0x00005678u, "S-Type SH 1");
        tb.check_mem(++test_id, DATA_ADDR3, 0x56780000u, "S-Type SH 3");
        tb.check_mem(++test_id, DATA_ADDR5, 0x00000078u, "S-Type SB 1");
        tb.check_mem(++test_id, DATA_ADDR6, 0x00007800u, "S-Type SB 2");
        tb.check_mem(++test_id, DATA_ADDR7, 0x00780000u, "S-Type SB 3");
        tb.check_mem(++test_id, DATA_ADDR8, 0x78000000u, "S-Type SB 4");

        // U-Type ----------------------------------------------------------
        tb.reset_memories();
        IMM = 0x7FFF0123u;
        INST_ADDR = 0;
        tb.mem(INST_ADDR + 0) = enc_u(IMM, 3, OPC_LUI);
        tb.mem(INST_ADDR + 1) = enc_u(IMM, 4, OPC_AUIPC);
        tb.cpu_reset_sequence();
        tb.check_rf(++test_id, 3, 0x7fff0000u, "U-Type LUI");
        tb.check_rf(++test_id, 4, 0x8fff0004u, "U-Type AUIPC");

        // JAL -------------------------------------------------------------
        tb.reset_memories();
        tb.rf(1) = 100; tb.rf(2) = 200; tb.rf(3) = 300; tb.rf(4) = 400;
        IMM = 0x00000FF0u;
        INST_ADDR = 0;
        JUMP_ADDR = (RESET_PC + ((IMM & 0x1FFFFEu))) >> 2;
        tb.mem(INST_ADDR + 0) = enc_j(mask21(static_cast<int32_t>(IMM)), 5, OPC_JAL);
        tb.mem(INST_ADDR + 1) = enc_r(FNC7_0, 2, 1, FNC_ADD_SUB, 6, OPC_ARI_RTYPE);
        tb.mem(JUMP_ADDR & 0x3FFFu) = enc_r(FNC7_0, 4, 3, FNC_ADD_SUB, 7, OPC_ARI_RTYPE);
        tb.cpu_reset_sequence();
        tb.check_rf(++test_id, 5, 0x10000004u, "J-Type JAL");
        tb.check_rf(++test_id, 7, 700u,       "J-Type JAL");
        tb.check_rf(++test_id, 6, 0u,         "J-Type JAL");

        // JALR ------------------------------------------------------------
        tb.reset_memories();
        tb.rf(1) = 0x10000100u; tb.rf(2) = 200; tb.rf(3) = 300; tb.rf(4) = 400;
        IMM = 0xFFFFFFF0u;
        INST_ADDR = 0;
        JUMP_ADDR = ((tb.rf(1) + static_cast<int32_t>(IMM)) & ~1u) >> 2;
        tb.mem(INST_ADDR + 0) = enc_i(mask12(static_cast<int32_t>(IMM)), 1, 0b000, 5, OPC_JALR);
        tb.mem(INST_ADDR + 1) = enc_r(FNC7_0, 2, 1, FNC_ADD_SUB, 6, OPC_ARI_RTYPE);
        tb.mem(JUMP_ADDR & 0x3FFFu) = enc_r(FNC7_0, 4, 3, FNC_ADD_SUB, 7, OPC_ARI_RTYPE);
        tb.cpu_reset_sequence();
        tb.check_rf(++test_id, 5, 0x10000004u, "J-Type JALR");
        tb.check_rf(++test_id, 7, 700u,        "J-Type JALR");
        tb.check_rf(++test_id, 6, 0u,          "J-Type JALR");

        // B-Type ----------------------------------------------------------
        IMM       = 0x00000FF0u;
        INST_ADDR = 0;
        JUMP_ADDR = (RESET_PC + (IMM & 0x1FFFu)) >> 2;

        BR_TYPE[0] = FNC_BEQ;  BR_NAME_TK1[0] = "B-Type BEQ Taken 1";  BR_NAME_TK2[0] = "B-Type BEQ Taken 2";  BR_NAME_NTK[0] = "B-Type BEQ Not Taken";
        BR_TAKEN_OP1[0] = 100; BR_TAKEN_OP2[0] = 100; BR_NTAKEN_OP1[0] = 100; BR_NTAKEN_OP2[0] = 200;
        BR_TYPE[1] = FNC_BNE;  BR_NAME_TK1[1] = "B-Type BNE Taken 1";  BR_NAME_TK2[1] = "B-Type BNE Taken 2";  BR_NAME_NTK[1] = "B-Type BNE Not Taken";
        BR_TAKEN_OP1[1] = 100; BR_TAKEN_OP2[1] = 200; BR_NTAKEN_OP1[1] = 100; BR_NTAKEN_OP2[1] = 100;
        BR_TYPE[2] = FNC_BLT;  BR_NAME_TK1[2] = "B-Type BLT Taken 1";  BR_NAME_TK2[2] = "B-Type BLT Taken 2";  BR_NAME_NTK[2] = "B-Type BLT Not Taken";
        BR_TAKEN_OP1[2] = 100; BR_TAKEN_OP2[2] = 200; BR_NTAKEN_OP1[2] = 200; BR_NTAKEN_OP2[2] = 100;
        BR_TYPE[3] = FNC_BGE;  BR_NAME_TK1[3] = "B-Type BGE Taken 1";  BR_NAME_TK2[3] = "B-Type BGE Taken 2";  BR_NAME_NTK[3] = "B-Type BGE Not Taken";
        BR_TAKEN_OP1[3] = 300; BR_TAKEN_OP2[3] = 200; BR_NTAKEN_OP1[3] = 100; BR_NTAKEN_OP2[3] = 200;
        BR_TYPE[4] = FNC_BLTU; BR_NAME_TK1[4] = "B-Type BLTU Taken 1"; BR_NAME_TK2[4] = "B-Type BLTU Taken 2"; BR_NAME_NTK[4] = "B-Type BLTU Not Taken";
        BR_TAKEN_OP1[4] = 0x00000001u; BR_TAKEN_OP2[4] = 0xFFFF0000u; BR_NTAKEN_OP1[4] = 0xFFFF0000u; BR_NTAKEN_OP2[4] = 0x00000001u;
        BR_TYPE[5] = FNC_BGEU; BR_NAME_TK1[5] = "B-Type BGEU Taken 1"; BR_NAME_TK2[5] = "B-Type BGEU Taken 2"; BR_NAME_NTK[5] = "B-Type BGEU Not Taken";
        BR_TAKEN_OP1[5] = 0xFFFF0000u; BR_TAKEN_OP2[5] = 0x00000001u; BR_NTAKEN_OP1[5] = 0x00000001u; BR_NTAKEN_OP2[5] = 0xFFFF0000u;

        for (i = 0; i < 6; ++i) {
            tb.reset_memories();
            tb.rf(1) = BR_TAKEN_OP1[i]; tb.rf(2) = BR_TAKEN_OP2[i]; tb.rf(3) = 300; tb.rf(4) = 400;
            tb.mem(INST_ADDR + 0) = enc_b(mask13(static_cast<int32_t>(IMM)), 2, 1, BR_TYPE[i], OPC_BRANCH);
            tb.mem(INST_ADDR + 1) = enc_r(FNC7_0, 4, 3, FNC_ADD_SUB, 5, OPC_ARI_RTYPE);
            tb.mem(JUMP_ADDR & 0x3FFFu) = enc_r(FNC7_0, 4, 3, FNC_ADD_SUB, 6, OPC_ARI_RTYPE);
            tb.cpu_reset_sequence();
            tb.check_rf(++test_id, 5, 0u,   BR_NAME_TK1[i]);
            tb.check_rf(++test_id, 6, 700u, BR_NAME_TK2[i]);

            tb.reset_memories();
            tb.rf(1) = BR_NTAKEN_OP1[i]; tb.rf(2) = BR_NTAKEN_OP2[i]; tb.rf(3) = 300; tb.rf(4) = 400;
            tb.mem(INST_ADDR + 0) = enc_b(mask13(static_cast<int32_t>(IMM)), 2, 1, BR_TYPE[i], OPC_BRANCH);
            tb.mem(INST_ADDR + 1) = enc_r(FNC7_0, 4, 3, FNC_ADD_SUB, 5, OPC_ARI_RTYPE);
            tb.cpu_reset_sequence();
            tb.check_rf(++test_id, 5, 700u, BR_NAME_NTK[i]);
        }

        // Hazards ---------------------------------------------------------
        tb.reset_memories(); tb.init_rf(); INST_ADDR = 0;
        tb.mem(INST_ADDR + 0) = enc_r(FNC7_0, 1, 2, FNC_ADD_SUB, 3, OPC_ARI_RTYPE);
        tb.mem(INST_ADDR + 1) = enc_r(FNC7_0, 3, 4, FNC_ADD_SUB, 5, OPC_ARI_RTYPE);
        tb.cpu_reset_sequence();
        tb.check_rf(++test_id, 5, tb.rf(1) + tb.rf(2) + tb.rf(4), "Hazard 1");

        tb.reset_memories(); tb.init_rf(); INST_ADDR = 0;
        tb.mem(INST_ADDR + 0) = enc_r(FNC7_0, 1, 2, FNC_ADD_SUB, 3, OPC_ARI_RTYPE);
        tb.mem(INST_ADDR + 1) = enc_r(FNC7_0, 4, 3, FNC_ADD_SUB, 5, OPC_ARI_RTYPE);
        tb.cpu_reset_sequence();
        tb.check_rf(++test_id, 5, tb.rf(1) + tb.rf(2) + tb.rf(4), "Hazard 2");

        tb.reset_memories(); tb.init_rf(); INST_ADDR = 0;
        tb.mem(INST_ADDR + 0) = enc_r(FNC7_0, 1, 2, FNC_ADD_SUB, 3, OPC_ARI_RTYPE);
        tb.mem(INST_ADDR + 1) = enc_r(FNC7_0, 4, 5, FNC_ADD_SUB, 6, OPC_ARI_RTYPE);
        tb.mem(INST_ADDR + 2) = enc_r(FNC7_0, 3, 7, FNC_ADD_SUB, 8, OPC_ARI_RTYPE);
        tb.cpu_reset_sequence();
        tb.check_rf(++test_id, 8, tb.rf(1) + tb.rf(2) + tb.rf(7), "Hazard 3");

        tb.reset_memories(); tb.init_rf(); INST_ADDR = 0;
        tb.mem(INST_ADDR + 0) = enc_r(FNC7_0, 1, 2, FNC_ADD_SUB, 3, OPC_ARI_RTYPE);
        tb.mem(INST_ADDR + 1) = enc_r(FNC7_0, 4, 5, FNC_ADD_SUB, 6, OPC_ARI_RTYPE);
        tb.mem(INST_ADDR + 2) = enc_r(FNC7_0, 7, 3, FNC_ADD_SUB, 8, OPC_ARI_RTYPE);
        tb.cpu_reset_sequence();
        tb.check_rf(++test_id, 8, tb.rf(1) + tb.rf(2) + tb.rf(7), "Hazard 4");

        tb.reset_memories(); tb.init_rf(); INST_ADDR = 0;
        tb.mem(INST_ADDR + 0) = enc_r(FNC7_0, 1, 2, FNC_ADD_SUB, 3, OPC_ARI_RTYPE);
        tb.mem(INST_ADDR + 1) = enc_r(FNC7_0, 4, 3, FNC_ADD_SUB, 5, OPC_ARI_RTYPE);
        tb.mem(INST_ADDR + 2) = enc_r(FNC7_0, 5, 6, FNC_ADD_SUB, 7, OPC_ARI_RTYPE);
        tb.cpu_reset_sequence();
        tb.check_rf(++test_id, 7, tb.rf(1) + tb.rf(2) + tb.rf(4) + tb.rf(6), "Hazard 5");

        tb.reset_memories(); tb.init_rf(); tb.rf(4) = 0x30000100u; IMM = 0; INST_ADDR = 0;
        DATA_ADDR = (tb.rf(4) + IMM) >> 2;
        tb.mem(INST_ADDR + 0) = enc_r(FNC7_0, 1, 2, FNC_ADD_SUB, 3, OPC_ARI_RTYPE);
        tb.mem(INST_ADDR + 1) = enc_s(IMM, 3, 4, FNC_SW, OPC_STORE);
        tb.cpu_reset_sequence();
        tb.check_mem(++test_id, DATA_ADDR, tb.rf(1) + tb.rf(2), "Hazard 6");

        tb.reset_memories(); tb.init_rf(); tb.rf(1) = 0x30000100u; IMM = 0; INST_ADDR = 0;
        DATA_ADDR = (tb.rf(1) + IMM) >> 2;
        tb.mem(DATA_ADDR) = 0x12345678u;
        tb.mem(INST_ADDR + 0) = enc_i(IMM, 1, FNC_LW, 2, OPC_LOAD);
        tb.mem(INST_ADDR + 1) = enc_r(FNC7_0, 2, 3, FNC_ADD_SUB, 4, OPC_ARI_RTYPE);
        tb.cpu_reset_sequence();
        tb.check_rf(++test_id, 4, tb.mem(DATA_ADDR) + tb.rf(3), "Hazard 7");

        tb.reset_memories(); tb.init_rf(); tb.rf(1) = 0x30000100u; tb.rf(4) = 0x30000200u; IMM = 0; INST_ADDR = 0;
        DATA_ADDR0 = (tb.rf(1) + IMM) >> 2;
        DATA_ADDR1 = (tb.rf(4) + IMM) >> 2;
        tb.mem(DATA_ADDR0) = 0x12345678u;
        tb.mem(INST_ADDR + 0) = enc_i(IMM, 1, FNC_LW, 2, OPC_LOAD);
        tb.mem(INST_ADDR + 1) = enc_s(IMM, 2, 4, FNC_SW, OPC_STORE);
        tb.cpu_reset_sequence();
        tb.check_mem(++test_id, DATA_ADDR1, tb.mem(DATA_ADDR0), "Hazard 8");

        tb.reset_memories(); tb.init_rf(); tb.rf(1) = 0x30000100u; IMM = 0; INST_ADDR = 0;
        DATA_ADDR0 = (tb.rf(1) + IMM) >> 2;
        tb.mem(DATA_ADDR0) = 0x30000200u;
        DATA_ADDR1 = (tb.mem(DATA_ADDR0) + IMM) >> 2;
        tb.mem(INST_ADDR + 0) = enc_i(IMM, 1, FNC_LW, 2, OPC_LOAD);
        tb.mem(INST_ADDR + 1) = enc_s(IMM, 4, 2, FNC_SW, OPC_STORE);
        tb.cpu_reset_sequence();
        tb.check_mem(++test_id, DATA_ADDR1, tb.rf(4), "Hazard 9");

        tb.reset_memories(); tb.init_rf(); INST_ADDR = 0; IMM = 0x00000FF0u;
        JUMP_ADDR = (0x10000008u + (IMM & 0x1FFFu)) >> 2;
        tb.mem(INST_ADDR + 0) = enc_r(FNC7_0, 1, 4, FNC_ADD_SUB, 6, OPC_ARI_RTYPE);
        tb.mem(INST_ADDR + 1) = enc_r(FNC7_0, 2, 3, FNC_ADD_SUB, 7, OPC_ARI_RTYPE);
        tb.mem(INST_ADDR + 2) = enc_b(mask13(static_cast<int32_t>(IMM)), 6, 7, FNC_BEQ, OPC_BRANCH);
        tb.mem(INST_ADDR + 3) = enc_r(FNC7_0, 8, 9, FNC_ADD_SUB, 10, OPC_ARI_RTYPE);
        tb.mem(JUMP_ADDR & 0x3FFFu) = enc_r(FNC7_1, 8, 9, FNC_ADD_SUB, 11, OPC_ARI_RTYPE);
        tb.cpu_reset_sequence();
        tb.check_rf(++test_id, 10, 1001u, "Hazard 10 1");
        tb.check_rf(++test_id, 11, tb.rf(9) - tb.rf(8), "Hazard 10 2");

        tb.reset_memories(); tb.init_rf(); IMM = 0x00000004u; INST_ADDR = 0;
        JUMP_ADDR = (RESET_PC + (IMM & 0x1FFFFEu)) >> 2;
        tb.mem(INST_ADDR + 0) = enc_j(mask21(static_cast<int32_t>(IMM)), 1, OPC_JAL);
        tb.mem(INST_ADDR + 1) = enc_r(FNC7_0, 2, 1, FNC_ADD_SUB, 3, OPC_ARI_RTYPE);
        tb.cpu_reset_sequence();
        tb.check_rf(++test_id, 3, tb.rf(2) + 0x10000004u, "Hazard 11");

        tb.reset_memories(); tb.init_rf(); tb.rf(4) = 0x10000000u; IMM = 0x00000004u; INST_ADDR = 0;
        tb.mem(INST_ADDR + 0) = enc_i(IMM, 4, 0b000, 1, OPC_JALR);
        tb.mem(INST_ADDR + 1) = enc_r(FNC7_0, 2, 1, FNC_ADD_SUB, 3, OPC_ARI_RTYPE);
        tb.cpu_reset_sequence();
        tb.check_rf(++test_id, 3, tb.rf(2) + 0x10000004u, "Hazard 12");

        std::cout << "All tests passed!\n";
        return 0;
    } catch (...) {
        return 1;
    }
}
