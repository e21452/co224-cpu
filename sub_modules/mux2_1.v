// 8:1 Mux module
// `timescale 1ns/100ps
module mux2_1(C,D,S,Z);
    // Input port declaration

    // C - output of 1
    // D - output of 2

    // S - 1 bit select input
    input signed [7:0] C,D;
    input S; 

    // Output port declaration
    output reg signed [7:0] Z;

    // Output changes whenever C,D or S is changed
    always @(C,D,S)
    begin
      // Depending on the selection connect the input line to output line
      case(S)
      1'b0: Z = C;
      1'b1: Z = D;
      endcase
    end
endmodule 