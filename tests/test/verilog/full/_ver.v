module alu (
   op,
   a,
   b,
   y,
   cin,
   cout,
   zout
);

        always @(CLKDIV or HDP or HNDP or VDP or VNDP or PADDR[1:0])
                case(PADDR[1:0])
                        3'b000 : PRDATA <= CLKDIV;
                        3'b001 : PRDATA <= HDP;
                        3'b010 : PRDATA <= HNDP;
                        3'b011 : PRDATA <= VDP;
                        3'b100 : PRDATA <= VNDP;
                        default  PRDATA <= VNDP;
                endcase
            if(a) b <= c;

чтобы все было корректно, надо писать так:

        always @(CLKDIV or HDP or HNDP or VDP or VNDP or PADDR[1:0])
         begin
                case(PADDR[1:0])
                        3'b000 : PRDATA <= CLKDIV;
                        3'b001 : PRDATA <= HDP;
                        3'b010 : PRDATA <= HNDP;
                        3'b011 : PRDATA <= VDP;
                        3'b100 : PRDATA <= VNDP;
                        default  PRDATA <= VNDP;
                endcase
            if(a) b <= c;
         end

endmodule
