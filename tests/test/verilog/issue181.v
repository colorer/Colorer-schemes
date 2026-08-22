`include"top_define.vh"
`include "static_macro_define.vh"
`include <ieee.vh>

`timescale 1ns / 1ps
`timescale 1ns/1ps

module `getname(test_module,`module_name)
(
	input a,
	output b
);

assign b = a;

endmodule

module `plain_macro
(
	input c,
	output d
);
assign d = `plain_macro_subst;
assign d = `getname(c, `module_name);
endmodule

module nested_parens;
wire x = `outer(a, `inner(b, c), d);
endmodule
