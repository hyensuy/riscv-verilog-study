-v ../../../../sim_model/de2-115/sim_lib/220model.v
-v ../../../../sim_model/de2-115/sim_lib/altera_mf.v
-v ../../../../sim_model/de2-115/sim_lib/sgate.v
-v ../../../../sim_model/de2-115/sim_lib/cycloneive_atoms.v

+libext+.v+.vlib

./sim_define.v

+libext+.vp
../../src/rtl/pipelined_cpu/rv32i_cpu_protected.vp

// ../../src/rtl/memory/ASYNC_RAM_DP_WBE.v
../../src/rtl/memory/dualport_mem_synch_rw_dualclk.sv

../../src/rtl/peripheral/Addr_Decoder.v
../../src/rtl/peripheral/data_mux.v
../../src/rtl/peripheral/GPIO.v
../../src/rtl/peripheral/SEG7_LUT.v
../../src/rtl/peripheral/TimerCounter.v

../../src/rtl/peripheral/UART/uart.v
../../src/rtl/peripheral/UART/uart_receiver.v
../../src/rtl/peripheral/UART/uart_transmitter.v
../../src/rtl/peripheral/UART/uart_wrap.v

../../src/rtl/SMU_RV32I_System.v

../../testbench/echo_tb.v
