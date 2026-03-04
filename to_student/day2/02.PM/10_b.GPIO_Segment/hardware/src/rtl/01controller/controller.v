module controller(
	input Btaken,
	input [6:0] opcode,
  input [6:0] funct7,
	input [2:0] funct3,
  output 	 RegWrite,
  output [2:0] ImmSrc,
  output [1:0] ALUSrcA,
  output 	 ALUSrcB,
	output [4:0] ALUControl,
  output   MemWrite,
  output [1:0] ResultSrc,
  output   Branch,
  output [1:0] PCSrc
  //output Csr
);

	aludec u_aludec(
		.opcode(opcode),
		.funct7(funct7),
		.funct3(funct3),
		.ALUControl(ALUControl)
	);

	maindec u_maindec( 
		.Btaken(Btaken),
    .opcode(opcode),
    .funct7(funct7),
    .funct3(funct3),
    .RegWrite(RegWrite),
    .ImmSrc(ImmSrc),
    .ALUSrcA(ALUSrcA),
    .ALUSrcB(ALUSrcB),
    .MemWrite(MemWrite),
    .ResultSrc(ResultSrc),
    .Branch(Branch),
    .PCSrc(PCSrc)
               // .Csr(Csr)
	);


endmodule
