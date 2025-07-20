//title netlist for analog to digital converter
// file adc_gate.v
/*      This file demonstrates the following capabilities for SILOS III for
	mixed analog and digital simulation:
	-  passing analog values in module ports
	-  modeling a simple analog comparator
	-  modeling a simple digital to analog converter
	-  nested `define macros (OVI 2.0 feature)
	-  UDP primitives for D flip-flop and JK flip-flop
*/

!con .ext=all		// This is a switch to allow the SILOS III analog extensions

`define abs1(a) (((a)<0)?-(a):(a))
`define close(a,b) (`abs1(a-b) < 0.01) ? 1:0
`define high  'b1                       
`define low   'b0

// this module defines the stimulus and instantiates the circuit

`timescale 1ns / 1ns

module top;
	wire     up, down;       
	real  analog_in;
	wire real  feedback;
	wire [7:0] count;
	reg [7:0] in;
	reg     clock;
	wire    down_up;
	wire    enable;
	reg     load_inputs;
	reg     clear;
	integer counter_value;

	comparator comp(analog_in,feedback,up,down);
	dac dig2an(feedback, count);
	sr_flop_gate sr_flop(up, down, clock, down_up, clear, enable);
	counter_gate counter (in, clock, down_up, enable, load_inputs, count);

	initial
		begin
		clock = 'b0;
		forever
			begin
			#2000 clock = 'b1;
			#2000 clock = 'b0;
			#500 clock = 'b1;
			end
		end
	initial
		fork
			     in = 'b0;

			     clear = 'b0;
			#100 clear = 'b1;

			     load_inputs = 'b1;
			#1   load_inputs = 'b0;
			#600 load_inputs = 'b1;

			     analog_in = 0.0;
			#1k  analog_in = 0.5;
			#30k analog_in = 1.0;
			#50k analog_in = 1.8;
			#90k analog_in = 1.0;
			#130k analog_in = 0.5;
			#150k analog_in = 0.0;
			#180k $finish;
		join
	always @count counter_value = integer(feedback*10);
endmodule

// this module models an analog comparator
module comparator(analog_in,feedback,up,down);  // analog signals are passed in
	input analog_in,feedback;
	output up, down;
	real analog_in,feedback;                // ports (analog_in, feedback)
	reg up, down;
	always
		begin
			@ (analog_in or feedback);
			up = `low;
			down = `low;
			if (!`close(analog_in,feedback))
				begin
				if ( analog_in > feedback )
					up = `high;
				else if ( analog_in < feedback )
					down = `high;
				end
		end
endmodule

//this module models a digital to analog converter
module dac(feedback, count);
	input[7:0] count;
	output feedback;
	real feedback;
	initial
		feedback = 0.0;
	always
		@ (count) #121 feedback = real(integer(count)) / 10.0;
endmodule

//  Gate level latching logic
module sr_flop_gate (up, down, clock, down_up, clear, enable);
	// this module models latching circuitry at the gate level:
	supply1 vdd;
	input up, down, clock, clear;
	output down_up, enable;
	wire up, down, clock, clear;
	wire down_up, enable;
	and     #(320, 280) 
		(and1, clock, up),
		(and2, clock, down),
		(and3, ff1_q, ff2_qb),
		(down_up, ff2_q, ff1_qb);
	and     #330
		(clock_d, clock);
	nor     #150 nor1 (enable, down_up, and3);
	
	d_flip_flop     #(220, 210)
			(ff1_q, clock_d, and1, vdd, clear),
			(ff2_q, clock_d, and2, vdd, clear);
	not     (ff1_qb,ff1_q),
		(ff2_qb,ff2_q);
endmodule

// ls191 up-down counter
module ls191 (d,b,c,a, clk, du, ct, ld, od, oc, ob, oa, rco, mo);
	input a,b,c,d,clk,du,ct,ld;
	output oa,ob,oc,od,rco,mo;
	wire clk;
	wire a,b,c,d,du,ct,ld;
	wire s0, s1, s2, s3;
	wire c0, c1, c2, c3;
	
	jk_flip_flop
		(q0, ck, ~ct, ~ct, s0, c0),
		(q1, ck, ~d1, ~d1, s1, c1),
		(q2, ck, ~d2, ~d2, s2, c2),
		(q3, ck, ~d3, ~d3, s3, c3);
	not     (q0n,q0),
		(q1n,q1),
		(q2n,q2),
		(q3n,q3);
	and     #(240, 360)
		(oa, q0),
		(ob, q1),
		(oc, q2),
		(od, q3);
	// rc output
	not     #(210, 250) (tcd, tc);
	nand    #(200, 240) (rco, clk, ctnd, tcd);
	// tc output
	and     #(90, 190)
		(n53, q0, q1, q2, q3),
		(n54,  q0n, q1n, q2n, q3n);
	//aoi   
	assign  tc = (~(((~du) & n53) | (du & n54)));
	and     #330 (mo, ~tc);
	// other logic
	nor
		(cue, du, ct),
		(ce, ~du, ct);
	nand    
		(s0, ad, ldnd),
		(c0, s0, ldne),
		(s1, bd, ldnd),
		(c1, s1, ldne),
		(s2, cd, ldnd),
		(c2, s2, ldne),
		(s3, dd, ldnd),
		(c3, s3, ldne);
	
	// aoi logic
	assign  d1 = (~((ce & q0n) | ( q0 & cue)));
	assign  d2 = (~((ce & q0n & q1n) | (q0 & q1 & cue)));
	assign  d3 = (~((ce & q0n & q1n & q2n) | (q0 & q1 & q2 & cue)));
	not
		 (ck, clk);
	and     #(80,40)
		 (ad, a),
		(bd, b),
		(cd, c),
		(dd, d);
	not     #(90,130)
		(ctnd, ct);
	not     #(90,1)
		(ldnd, ld);
	not     #(40,1)
		(ldne, ld);
endmodule

// 8-bit up/down counter
module counter_gate (in, clock, down_up, enable, load_inputs, count);
	input clock, down_up, enable, load_inputs;
	input[7:0] in;
	output[7:0] count;
	wire ripple_clk, enable; 
	wire clock, load_inputs;
	wire[7:0] in;

	ls191   ls191_1 (in[3],in[2],in[1],in[0], clock, down_up, enable, load_inputs,
		 count[3],count[2],count[1],count[0], ripple_clk,foo),
		ls191_2 (in[7],in[6],in[5],in[4], clock, down_up, ripple_clk, 
		load_inputs,  count[7],count[6],count[5],count[4], foo,foo); 
endmodule

// d flip-flop udp primitive
primitive d_flip_flop (q, clock, data, set, clear);
	input clock, data, set, clear;
	output q;
	reg q;

	table
	//      clock   data    set     clear   q       q+
		?       ?       0       ?       :?:     1;
		?       ?       x       0       :?:     0;
		?       ?       1       0       :?:     0;
		(01)    0       1       1       :?:     0;
		(01)    1       1       1       :?:     1;
		(01)    x       1       1       :?:     x;
		f       ?       1       1       :?:     -;
		?       ?       1       1       :?:     -;
	endtable
endprimitive

// jk flip-flop udp primitive
primitive jk_flip_flop (q, clock, j,k, set, clear);
	input clock, j,k, set, clear;
	output q;
	reg q;
	initial  q = 1'b0;
	table
	//      clock   jk      set     clear   q       q+
		?       ??      0       ?       :?:     1;
		?       ??      x       0       :?:     0;
		?       ??      1       0       :?:     0;
		(01)    00      1       1       :0:     0;
		(01)    00      1       1       :x:     x;
		(01)    00      1       1       :1:     1;
		(01)    10      1       1       :?:     1;
		(01)    01      1       1       :?:     0;
		(01)    11      1       1       :1:     0;
		(01)    11      1       1       :x:     x;
		(01)    11      1       1       :0:     1;
		(01)    x?      1       1       :?:     x;
		(01)    ?x      1       1       :?:     x;
		f       ??      1       1       :?:     -;
		?       ??      1       1       :?:     -;
	endtable
endprimitive

