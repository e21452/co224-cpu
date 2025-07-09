// 8:1 Mux module
// `timescale 1ns/100ps
module mux (C,D,E,F,S,Z);
    // Input port declaration

    // C - output of forwardUnit
    // D - output of addUnit
    // E - output of andUnit
    // F - output of orUnit
    // S - 3 bit select input
    input signed [7:0] C,D,E,F;
    input [2:0] S; 

    // Output port declaration
    output reg signed [7:0] Z;

    // Output changes whenever C,D,E,F or S is changed
    always @(C,D,E,F,S)
    begin
      // Depending on the selection connect the input line to output line
      case(S)
      3'b000: Z = C;
      3'b001: Z = D;
      3'b010: Z = E;
      3'b011: Z = F;
      endcase
    end
endmodule 