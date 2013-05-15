/*  Synhronous Serial port module for AD733xx chip interfecing  */
module sport(
	clk, rst, twt, wr0, wr1, t, int, s0, s1,	// to core
	sclk, rx, rxfs, tx, txfs);					// external

	input			clk, rst, twt;
	input			wr0, wr1;
	input	[15:0]	t;
	output			int;
	output	[15:0]	s0, s1;
	input			sclk, rx, rxfs;
	output			tx, txfs;

	// locals
	reg		[15:0]	s0, s1;
	reg		[4:0]	count;

//	wire xclk = twt & clk;

	assign	int			= count[3:0] == 4'b0000;
	wire	shift_clock	= sclk | ~count[4];

	reg w0, w1;		// write strobe
	always @(posedge clk) // xclk or negedge rst)
//		if(rst==0)	begin w0 <= 0;   w1 <= 0;   end
		if(twt)	begin
			w0 <= wr0 ? 1 : 0;
			w1 <= wr1 ? 1 : 0;
		end

	reg start;
	always @(negedge rxfs or negedge sclk)
		if (~sclk)	start <= 0;
		else		start <= 1;

	always @(posedge shift_clock or posedge start)
		if (start)	count <= 5'b11111;
		else		count <= count - 1;

	always @(posedge shift_clock or posedge w0)
		if (w0)			s0 <= t;
		else 	if(int)	s0 <= s1;
				else	s0 <= {s0[14:0], rx};

	always @(posedge shift_clock or posedge w1)
		if (w1)			s1 <= t;
		else	if(int)	s1 <= {s0[14:0], rx};

	assign txfs = rxfs;
	assign tx = s0[15];

endmodule
