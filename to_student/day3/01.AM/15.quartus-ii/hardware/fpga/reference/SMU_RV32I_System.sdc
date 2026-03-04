#set_time_format -unit ns -decimal_places 3


#**************************************************************
# Create Clock
#**************************************************************


create_clock -name clk -period 20.000 [get_ports CLOCK_50]

derive_pll_clocks
derive_clock_uncertainty
