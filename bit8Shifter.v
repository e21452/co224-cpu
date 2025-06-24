

module b8_shifter (
    input [7:0] IN,
    input [2:0] S_AMNT,
    input [2:0] DIRECTION,                            //0 - Left, 1 - Right
    output reg [7:0] OUT
);


    wire [7:0] IN_R, IN_L, SHIFT_IN, OUT_R, OUT_L;
    reg [7:0] level_0_0, level_0_1, level_0_out;
    reg [7:0] level_1_0, level_1_1, level_1_out;
    reg [7:0] level_2_0, level_2_1, level_2_out;


    assign IN_R = {
        IN[0], IN[1], IN[2], IN[3],
        IN[4], IN[5], IN[6], IN[7]
                   };
    
    assign IN_L = IN;
    assign SHIFT_IN = DIRECTION[0] ? IN_R: IN_L;

    assign OUT_R = {
        level_2_out[0], level_2_out[1], level_2_out[2], level_2_out[3],
        level_2_out[4], level_2_out[5], level_2_out[6], level_2_out[7]
                   };

    assign OUT_L = level_2_out;

    wire level_0_of;
    wire [1:0]  level_1_of;
    wire [3:0]  level_2_of;

    
    assign level_0_of = DIRECTION[1]? SHIFT_IN[7]: (DIRECTION[2]? IN[7]: 1'b0);
    assign level_1_of = DIRECTION[1]? level_0_out[7:6]: (DIRECTION[2]? {2{IN[7]}}: 2'b0); 
    assign level_2_of = DIRECTION[1]? level_1_out[7:4]: (DIRECTION[2]? {4{IN[7]}}: 4'b0);   
      

    always @(*) begin
        level_0_0 = SHIFT_IN;
        level_0_1 = {SHIFT_IN[6:0],level_0_of};

        level_1_0 = level_0_out;
        level_1_1 = {level_0_out[5:0],level_1_of};

        level_2_0 = level_1_out;
        level_2_1 = {level_1_out[3:0],level_2_of};

        
    end

    always @(*) begin
        level_0_out = S_AMNT[0] ? level_0_1: level_0_0;
        level_1_out = S_AMNT[1] ? level_1_1: level_1_0;
        level_2_out = S_AMNT[2] ? level_2_1: level_2_0;

        OUT = DIRECTION[0] ? OUT_R: OUT_L;
    end
endmodule
    
