// Redirect-triggered flush control for IF/ID and ID/EX.
module flush_control(input [1:0] PCSrcE,output flushD,output flushE_redirect);
  wire redirect = (PCSrcE != 2'b00);
  assign flushD = redirect;
  assign flushE_redirect = redirect;
endmodule
