// `timescale 1ns/100ps
module PC_ADDER(PC,PC_4);
    //PC+4 Adder
    input [31:0] PC;
    output [31:0] PC_4;
	assign #1 PC_4 = PC + 32'd4;
	
endmodule