// 8:1 Mux module
// `timescale 1ns/100ps
module mux8_1_37(a7,a6,a5,a4,a3,a2,a1,a0,S,Z);
   
   // S - 1 bit select input
    input [36:0] a7,a6,a5,a4,a3,a2,a1,a0;
    input[2:0] S; 

    // Output port declaration
    output reg [36:0] Z;

    // Output changes whenever C,D or S is changed
    always @(a7,a6,a5,a4,a3,a2,a1,a0,S)
    begin
      // Depending on the selection connect the input line to output line
      case(S)
      3'd0: Z = a0;
      3'd1: Z = a1;
      3'd2: Z = a2;
      3'd3: Z = a3;
      3'd4: Z = a4;
      3'd5: Z = a5;
      3'd6: Z = a6;
      3'd7: Z = a7;
      endcase
    end
endmodule 