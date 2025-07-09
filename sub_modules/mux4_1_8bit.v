// 8:1 Mux module 5 bit output
// `timescale 1ns/100ps
module mux4_1_8(m3,m2,m1,m0,S,Z);
    
    input [7:0] m3,m2,m1,m0;
    input [1:0] S; 

    // Output port declaration
    output reg [7:0] Z;

    // Output changes whenever C,D,E,F or S is changed
    always @(m3,m2,m1,m0,S)
    begin
      // Depending on the selection connect the input line to output line
      case(S)
      2'b00: Z = m0;
      2'b01: Z = m1;
      2'b10: Z = m2;
      2'b11: Z = m3;
      endcase
    end
endmodule 