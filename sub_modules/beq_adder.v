// `timescale 1ns/100ps
module BEQ_ADDER(PC_4,EXTENDED_ADDRESS,PC_BEQ);
    //PC+4 Adder
    input [31:0] PC_4,EXTENDED_ADDRESS;
    output [31:0] PC_BEQ;
	assign #2 PC_BEQ = PC_4 + EXTENDED_ADDRESS;
	
endmodule