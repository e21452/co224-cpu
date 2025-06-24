module array_multiplier(A, B,z);
  input [7:0] A,B;
  output [7:0] z;
  reg p[3:0][3:0];
  reg p0[3:0];
  wire [11:0] c; // c represents carry of HA/FA
  wire [11:0] s;  // s represents sum of HA/FA

  integer i;
  
  always@(A,B)
  begin
    for(i=0;i<4;i++) begin
      p[i][0] = A[0] & B[i]; 
      p[i][1] = A[1] & B[i];
      p[i][2] = A[2] & B[i];
      p[i][3] = A[3] & B[i];
    end
  end 

  // row 1
  half_adder h0(p[0][1],p[1][0],s[0],c[0]);
  full_adder f1(p[0][2],p[1][1],c[0],s[1],c[1]);
  full_adder f2(p[0][3],p[1][2],c[1],s[2],c[2]);
  half_adder h3(p[1][3],c[2],s[3],c[3]);

  // row 2
  half_adder h4(p[2][0],s[1],s[4],c[4]);
  full_adder f5(p[2][1],s[2],c[4],s[5],c[5]);
  full_adder f6(p[2][2],s[3],c[5],s[6],c[6]);
  full_adder f7(p[2][3],c[3],c[6],s[7],c[7]);

  //row 3
  half_adder h8(p[3][0],s[5],s[8],c[8]);
  full_adder f9(p[3][1],s[6],c[8],s[9],c[9]);
  full_adder f10(p[3][2],s[7],c[9],s[10],c[10]);
  full_adder f11(p[3][3],c[7],c[10],s[11],c[11]);

  assign #3 z = {c[11],s[11:8],s[4],s[0],p[0][0]};
endmodule

module half_adder(input a, b, output s0, c0);
  assign s0 = a ^ b;
  assign c0 = a & b;
endmodule

module full_adder(input a, b, cin, output s0, c0);
  assign s0 = a ^ b ^ cin;
  assign c0 = (a & b) | (b & cin) | (a & cin);
endmodule