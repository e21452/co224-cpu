// `timescale 1ns/100ps
module signExtension(IN,OUT);
    input[7:0] IN;
    output reg[31:0] OUT;

    always@(IN)
        OUT = {{22{IN[7]}},IN,2'b00};
endmodule