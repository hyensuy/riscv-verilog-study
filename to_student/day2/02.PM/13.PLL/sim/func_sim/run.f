./sim_define.v

//////// RTL ///////////////////

-v ../../../../../sim_model/de2-115/sim_lib/220model.v
-v ../../../../../sim_model/de2-115/sim_lib/altera_mf.v
-v ../../../../../sim_model/de2-115/sim_lib/sgate.v
-v ../../../../../sim_model/de2-115/sim_lib/cycloneive_atoms.v


+incdir+../../src/rtl
../../src/rtl/alt_pll.v

../../testbench/testbench.v
