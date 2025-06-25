module controlUnit (WRITEENABLE, ALUOP, SHIFT_OP, S_MUX1, S_MUX2, SHIFT_MUX, BRANCH, JUMP, OPCODE);

    output reg WRITEENABLE, S_MUX1, S_MUX2,SHIFT_MUX, BRANCH, JUMP; //Write_enable, MUX1_select, MUX2_select
    output reg [2:0] ALUOP, SHIFT_OP;                               //ALU operation selection
    input [7:0] OPCODE;                                   //Opcode from the instruction

    always @(*) begin
        WRITEENABLE = 0;
        S_MUX1 = 0;
        S_MUX2 = 1;
        BRANCH = 0;
        JUMP = 0;
        SHIFT_OP = 0;
        SHIFT_MUX = 0;

        #1
        case (OPCODE)
            8'b0000_1000: 
                        begin 
                            ALUOP = 3'b100; // add
                            WRITEENABLE = 1;
                        end
            8'b0000_0010: 
                        begin 
                            ALUOP = 3'b001; // add
                            WRITEENABLE = 1;
                        end
            8'b0000_0011:                   // sub
                        begin
                            ALUOP = 3'b001;
                            S_MUX1 = 1;
                            WRITEENABLE = 1;
                        end
            8'b0000_0100: 
                        begin
                            ALUOP = 3'b010; // and
                            WRITEENABLE = 1;
                        end
            8'b0000_0101: 
                        begin
                            ALUOP = 3'b011; // or
                            WRITEENABLE = 1;
                        end
            8'b0000_0001: 
                        begin
                            ALUOP = 3'b000; // mov
                            WRITEENABLE = 1;
                        end
            8'b0000_0000:                   // loadi
                        begin 
                            ALUOP = 3'b000;
                            WRITEENABLE = 1;
                            S_MUX2 = 0;
                        end 
            8'b0000_0111:               // beq
                        begin
                            ALUOP = 3'b001;
                            S_MUX1 = 1;
                            BRANCH = 1;
                        end
            8'b0000_0110:       // j
                        begin
                            JUMP = 1;
                        end
            8'b1000_0111:          // bne
                        begin
                            ALUOP = 3'b001;
                            S_MUX1 = 1;
                            BRANCH = 1;
                        end
            8'b1000_0001:          // sll
                        begin
                            ALUOP = 3'b000; 
                            WRITEENABLE = 1;
                            SHIFT_OP = OPCODE[6:4];
                            SHIFT_MUX = 1;
                        end
            8'b1001_0001:          // slr
                        begin
                            ALUOP = 3'b000; 
                            WRITEENABLE = 1;
                            SHIFT_OP = OPCODE[6:4];
                            SHIFT_MUX = 1;
                        end
            8'b1011_0001:          // ror
                        begin
                            ALUOP = 3'b000; 
                            WRITEENABLE = 1;
                            SHIFT_OP = OPCODE[6:4];
                            SHIFT_MUX = 1;
                        end
            8'b1101_0001:          // sar
                        begin
                            ALUOP = 3'b000; 
                            WRITEENABLE = 1;
                            SHIFT_OP = OPCODE[6:4];
                            SHIFT_MUX = 1;
                        end

        endcase
    end
    
endmodule