./sim_define.v

../../src/rtl/01controller/controller.v
../../src/rtl/01controller/aludec.v
../../src/rtl/01controller/maindec.v
../../src/rtl/02memory/ASYNC_RAM_DP_WBE.v
../../src/rtl/03register_file/reg_file_async.v
../../src/rtl/04extend_unit/extend.v
../../src/rtl/05ALU_unit/adder_32bit.v
../../src/rtl/05ALU_unit/alu.v

../../src/rtl/06branch_unit/branch_logic.v
../../src/rtl/07Byte_Enable/BE_logic.v
../../src/rtl/08Register_write_data_logic/register_write_data_logic.v
../../src/rtl/09Next_PC_logic/adder_1bit.v
../../src/rtl/09Next_PC_logic/alu_add.v
../../src/rtl/09Next_PC_logic/next_pc_logic.v

../../src/rtl/10Peripheral/GPIO.v
../../src/rtl/10Peripheral/Addr_Decoder.v
../../src/rtl/10Peripheral/data_mux.v
../../src/rtl/10Peripheral/SEG7_LUT.v

../../src/rtl/10Peripheral/TimerCounter.v

../../src/rtl/datapath.v
../../src/rtl/rv32i_cpu.v
../../src/rtl/SMU_RV32I_System.v

../../testbench/peripheral_tests_tb.v
