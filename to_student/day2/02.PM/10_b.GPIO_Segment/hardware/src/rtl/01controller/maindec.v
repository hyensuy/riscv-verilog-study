module maindec( 
	input Btaken,
  input [6:0] opcode,
  input [6:0] funct7,
  input [2:0] funct3,
  output reg RegWrite,
  output reg [2:0] ImmSrc,
  output reg [1:0] ALUSrcA,
  output reg ALUSrcB,
  output reg MemWrite,
  output reg [1:0] ResultSrc,
  output reg Branch,
  output reg [1:0] PCSrc
  //output reg Csr
);

	//Regwrite 
	always @ (*)
	begin 
 		case (opcode)
        7'b011_0011: RegWrite = 1'b1;   //R-type
        7'b001_0011: RegWrite = 1'b1;   //I-type Arithmetic
        7'b000_0011: RegWrite = 1'b1;   //I-type Load
        7'b110_0111: RegWrite = 1'b1;   //I-type Jalr
        7'b010_0011: RegWrite = 1'b0;   //S-type Store
        7'b110_0011: RegWrite = 1'b0;   //B-type Branch
        7'b011_0111: RegWrite = 1'b1;   //U-type LUI
        7'b001_0111: RegWrite = 1'b1;   //U-type AUIPC
        7'b110_1111: RegWrite = 1'b1;   //J-type JAL
        default: RegWrite = 1'bx;
 		endcase
	end

	//ImmSrc 
	always @ (*)
	begin
 		case(opcode)
 				7'b001_0011: ImmSrc = 3'b000;   //I-type Arithmetic
        7'b000_0011: ImmSrc = 3'b000;   //I-type Load
        7'b110_0111: ImmSrc = 3'b000;   //I-type Jalr
        7'b010_0011: ImmSrc = 3'b001;   //S-type Store
        7'b110_0011: ImmSrc = 3'b010;   //B-type Branch
				7'b110_1111: ImmSrc = 3'b011;   //J-type JAL
        7'b011_0111: ImmSrc = 3'b100;   //U-type LUI
        7'b001_0111: ImmSrc = 3'b100;   //U-type AUIPC
        default: ImmSrc = 3'bxxx;	//default : R-type
 		endcase
	end

	//ALUSrcA
	always @(*)
	begin
 		case(opcode)
        7'b011_0111: ALUSrcA = 2'b10;   //U-type LUI
				7'b001_0111: ALUSrcA = 2'b01;   //U-type AUIPC
				default: ALUSrcA = 2'b00;	//remain
 		endcase
	end

	//ALUSrcB
	always @(*)
	begin
 		case(opcode)
				7'b011_0011: ALUSrcB = 1'b0;    //R-type
        7'b110_0011: ALUSrcB = 1'b0;    //B-type Branch
				default: ALUSrcB = 1'b1;	//remain
 		endcase
	end


	//MemWrite
	always @(*)
	begin
 		case(opcode)
				7'b010_0011: MemWrite = 1'b1;   //S-type Store
				default: MemWrite = 1'b0;	//remain
 		endcase
	end

	//ResultSrc
	always @(*)
	begin
 		case(opcode)
				7'b000_0011: ResultSrc = 2'b01;  //I-type Load
        7'b110_0111: ResultSrc = 2'b10;  //I-type Jalr
				7'b110_1111: ResultSrc = 2'b10;  //J-type JAL
				default: ResultSrc = 2'b00;	 //remain
 		endcase
	end

	//Branch
	always @(*)
	begin
 		case(opcode)
				7'b110_0011: Branch = 1'b1;     //B-type Branch
				default: Branch = 1'b0;		//remain
 		endcase
	end

	//PCSrc 
	always @(*)
	begin
 		case(opcode)
				7'b110_0111: PCSrc = 2'b10;    //I-type Jalr
				7'b110_0011: PCSrc = (Btaken == 1'b1) ? 2'b01 : 2'b00;     //B-type Branch
				7'b110_1111: PCSrc = 2'b01;  //J-type JAL
				default: PCSrc = 2'b00;		//remain
 		endcase
	end

/*
//Csr
always @(*)
begin
 case(opcode)
	7'b111_0011: Csr = 1'b1;   
	default: Csr = 1'b0;	
 endcase
end
*/

endmodule
