module sub_32bit(
	input		[31:0] 	a,b,
  output	[31:0] 	y
);

	wire [31:0] b_bar = ~b;
	wire cout;

	adder_32bit u_adder_32bit(
		.a(a),
		.b(b_bar),
		.cin(1'b1),
		.sum(y),
		.cout(cout)
	);
	
endmodule
