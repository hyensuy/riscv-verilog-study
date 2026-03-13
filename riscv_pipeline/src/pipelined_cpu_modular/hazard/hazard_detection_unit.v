// Load-use hazard detection (version-2 policy).
// Generates: stallF, stallD, flushE when ID uses destination of load in EX.
module hazard_detection_unit(
  input [4:0] rs1D,rs2D,rdE,
  input ResultSrcE_isLoad,
  output stallF,output stallD,output flushE
);
  wire dep_rs1 = (rs1D==rdE) && (rs1D!=5'd0);
  wire dep_rs2 = (rs2D==rdE) && (rs2D!=5'd0);
  wire lwStall = ResultSrcE_isLoad && (dep_rs1 || dep_rs2);

  assign stallF = lwStall;
  assign stallD = lwStall;
  assign flushE = lwStall;
endmodule
