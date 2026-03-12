// Byte-enable and load/store alignment helper.
module BE_logic(input [2:0] funct3,input [1:0] Addr_Last2,input [31:0] WD,input [31:0] RD,output reg [31:0] BE_WD,output reg [31:0] BE_RD,output reg [3:0] Byte_Enable);
  reg [31:0] rd_shift8;
  reg [31:0] rd_shift16;
  always @(*) begin
    case(funct3)
      3'b000,3'b100: Byte_Enable = 4'b0001 << Addr_Last2;
      3'b001,3'b101: Byte_Enable = (Addr_Last2[1]?4'b1100:4'b0011);
      3'b010: Byte_Enable = 4'b1111;
      default: Byte_Enable = 4'b0000;
    endcase

    BE_WD = WD << (8*Addr_Last2);
    rd_shift8  = RD >> (8*Addr_Last2);
    rd_shift16 = RD >> (16*Addr_Last2[1]);

    case (funct3)
      3'b000: BE_RD = {{24{rd_shift8[7]}}, rd_shift8[7:0]};
      3'b100: BE_RD = {24'd0, rd_shift8[7:0]};
      3'b001: BE_RD = {{16{rd_shift16[15]}}, rd_shift16[15:0]};
      3'b101: BE_RD = {16'd0, rd_shift16[15:0]};
      default: BE_RD = RD;
    endcase
  end
endmodule
