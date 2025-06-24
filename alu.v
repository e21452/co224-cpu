// create module for FORWARD funtional unit
module foward_fu (RESULT, DATA2);

    input [7:0] DATA2;      // 8-bit input DATA2
    output [7:0] RESULT;    // 8-bit output RESULT

    // assign RESULT to DATA2 with 1 unit of time delay
    // whenever the value of DATA2 changes this block will be trigger
    assign #1 RESULT = DATA2;   

endmodule

// create module for ADD funtional unit
module add_fu (RESULT, DATA1, DATA2);
 
    input [7:0] DATA1, DATA2;   // 8-bit input DATA1 and DATA2
    output [7:0] RESULT;        // 8-bit output RESULT

    // assign RESULT to DATA1 + DATA2 with 2 units of time delay
    // whenever the value of DATA1 or DATA2 changes this block will be trigger
    assign #2 RESULT = DATA1 + DATA2;

endmodule

// create module for AND funtional unit
module and_fu (RESULT, DATA1, DATA2);
 
    input [7:0] DATA1, DATA2;   // 8-bit input DATA1 and DATA2
    output [7:0] RESULT;        // 8-bit output RESULT

    // assign RESULT to DATA1 &(bitwise AND) DATA2 with 1 unit of time delay
    // whenever the value of DATA1 or DATA2 changes this block will be trigger
    assign #1 RESULT = DATA1 & DATA2;

endmodule

// create module for OR funtional unit
module or_fu (RESULT, DATA1, DATA2);
 
    input [7:0] DATA1, DATA2;   // 8-bit input DATA1 and DATA2
    output [7:0] RESULT;        // 8-bit output RESULT

    // assign RESULT to DATA1 |(bitwise OR) DATA2 with 1 unit of time delay
    // whenever the value of DATA1 or DATA2 changes this block will be trigger
    assign #1 RESULT = DATA1 | DATA2;

endmodule

module mul_fu (RESULT, DATA1, DATA2);
    input [31:0] DATA1, DATA2;   // 32-bit input DATA1 and DATA2
    output [31:0] RESULT;        // 32-bit output RESULT

    
    
endmodule

// create module for ALU
module alu (ZERO, RESULT, DATA1, DATA2, SELECT);

    input [7:0] DATA1, DATA2;   // 8-bit input DATA1 and DATA2
    input [2:0] SELECT;         // 3-bit input SELECT
    output reg [7:0] RESULT;
    output reg ZERO;            // 8-bit output RESULT, here I declare as a reg because I need to assign value for it

    // 4 8-bit input wires to get the RESULT of FORWARD, ADD, AND and OR
    wire [7:0] forward_result, add_result, and_result, or_result;

    // instantiations for FORWARD, ADD, AND and OR
    foward_fu myforward(forward_result, DATA2);
    add_fu myadd(add_result, DATA1, DATA2);
    and_fu myand(and_result, DATA1, DATA2);
    or_fu myor(or_result, DATA1, DATA2);

    // create an always block with senciticve list as all
    always @ (*) begin
        // here I used case block to get the function of 8:1 MUX
        case (SELECT)
            3'b000: RESULT = forward_result;    // if select is 000 then, assign RESULT to forward_result
            3'b001: RESULT = add_result;        // if select is 001 then, assign RESULT to add_result
            3'b010: RESULT = and_result;        // if select is 010 then, assign RESULT to and_result
            3'b011: RESULT = or_result;         // if select is 011 then, assign RESULT to or_result
            //default: RESULT = 8'b0000_0000;     // reserved for future
        endcase
        
        if (RESULT == 0)
            ZERO = 1;
        else
            ZERO = 0;
    end

endmodule