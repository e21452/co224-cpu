// `timescale 1ns/100ps
module comparator(A,B,Z);
    input[2:0] A,B;
    output reg Z;

    wire[2:0] a;

    assign a[0] = ~(A[0]^B[0]);
    assign a[1] = ~(A[1]^B[1]);
    assign a[2] = ~(A[2]^B[2]);

    // Z is high is A and B are equal
    always@(*)
    Z = a[0]&a[1]&a[2];

endmodule