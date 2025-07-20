module alu(
	op_alu, op_shf, t, aopy, carry, n15, n0,
	rshf, cf, arez0);

	input	[3:0]	op_alu, op_shf;
	input	[15:0]	t, aopy;
	input			carry, n15, n0;
	output	[16:0]	rshf;
	output			cf, arez0;

	reg		carin;
	always @(op_alu or carry)
		casex(op_alu)
			4'bx100 : carin <= 1'b1;
			4'b0101 : carin <= carry;
			4'b1x01 : carin <= carry;
			default   carin <= 1'b0;
		endcase

	reg [15:0] op_X;
	always @(op_alu or t)
		casex(op_alu)   
			4'b110x : op_X <= ~t;
			default   op_X <=  t;
		endcase  

	reg [15:0] op_Y;
	always @(op_alu or aopy)
		casex(op_alu) 
			4'b010x : op_Y <= ~aopy ;
			default   op_Y <=  aopy ;
		endcase    

	wire	[15:0]	rz_or  = op_X | op_Y;
	wire	[15:0]	rz_and = op_X & op_Y;
	wire	[15:0]	rz_xor = op_X ^ op_Y;

	wire	cou;
	wire	[14:0]	cc;
	assign {cou, cc} = rz_and | rz_xor & {cc, carin};

	assign	cf = (op_alu[3] | op_alu[2]) & ~op_alu[1] ? cou : carry;
	wire	[15:0]	rz_sum = rz_xor ^ {cc, carin};

	reg		[15:0]	arez;
	always @(op_alu or op_X or op_Y or rz_sum or rz_or or rz_and or rz_xor)
		case(op_alu)
			4'b0000 : arez <=  op_X;
			4'b0001 : arez <= ~op_X;
			4'b0010 : arez <=  rz_and;
			4'b0011 : arez <= ~rz_and;
			4'b0110 : arez <=  rz_or;
			4'b0111 : arez <= ~rz_or;
			4'b1010 : arez <=  rz_xor;
			4'b1011 : arez <= ~rz_xor;
			4'b1110 : arez <=  op_Y;
			4'b1111 : arez <= ~op_Y;
			default   arez <= rz_sum;
		endcase

	assign arez0 = arez[0];

	reg		[16:0] rshf;
	always @(op_shf or arez or n15 or n0 or cf)
		casex(op_shf)
			4'b0001 : rshf <= {cf,        {16{arez[15]}}     };
			4'b0010 : rshf <= {            arez,         1'b0};
			4'b0011 : rshf <= {            arez,           cf};
			4'bx100 : rshf <= {    1'b0,       cf, arez[15:1]};
			4'b0101 : rshf <= { arez[0],       cf, arez[15:1]};
			4'bx110 : rshf <= {    1'b0,     1'b0, arez[15:1]};
			4'bx111 : rshf <= {arez[15], arez[15], arez[15:1]};
			4'b101x : rshf <= {              arez,        n15};
			4'b1101 : rshf <= {      n0,       cf, arez[15:1]};
			default : rshf <= {      cf,                 arez};
		endcase

endmodule
