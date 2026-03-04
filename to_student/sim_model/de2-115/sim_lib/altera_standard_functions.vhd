-- Copyright (C) 2020 Intel Corporation. All rights reserved.
-- Your use of Intel Corporation's design tools, logic functions 
-- and other software and tools, and any partner logic 
-- functions, and any output files from any of the foregoing 
-- (including device programming or simulation files), and any 
-- associated documentation or information are expressly subject 
-- to the terms and conditions of the Intel Program License 
-- Subscription Agreement, the Intel Quartus Prime License Agreement,
-- the Intel FPGA IP License Agreement, or other applicable license
-- agreement, including, without limitation, that your use is for
-- the sole purpose of programming logic devices manufactured by
-- Intel and sold by Intel or its authorized distributors.  Please
-- refer to the applicable agreement for further details, at
-- https://fpgasoftware.intel.com/eula.
-- Quartus Prime 20.1.1 Build 720 11/11/2020
library std;
use std.standard.all;

package altera_standard_functions is

    function maximum (L, R: integer) return integer;
    function minimum (L, R: integer) return integer;
    
end altera_standard_functions;

package body altera_standard_functions is

    function maximum (L, R: integer) return integer is
    begin
        if L > R then
            return L;
        else
            return R;
        end if;
    end maximum;

    function minimum (L, R: integer) return integer is
    begin
        if L > R then
            return R;
        else
            return L;
        end if;
    end minimum;
    
end altera_standard_functions;
