`include "alu.v"
`include "regFile.v"
`include "bit8Shifter.v"
`include "memory.v"

module regPC (PC, RESET, CLK, ADDRESS);  //Program Counter that incremented by 4
    
    output reg [31:0] PC;
    input [31:0] ADDRESS;
    input RESET, CLK;

    always @(posedge CLK) begin  
        if(RESET) 
            PC = 0;
        else
            PC = ADDRESS;
    end

endmodule

module addr (
    output reg [31:0] RESULT,
    input [31:0] DATA1, DATA2
);
    
    always @(*) begin
        #2 RESULT = DATA1 + DATA2; 
    end

endmodule

module extender (
    output [31:0] OUT,
    input [7:0] IN
);

    assign OUT = {{22{IN[7]}}, IN, 2'b00};
    
endmodule

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

module complement (OUT, IN); //Module for 2's complemented value

    output [7:0] OUT;
    input [7:0] IN;

    assign #1 OUT = ~IN + 1;

endmodule

module cpu (PC, INSTRUCTION, CLK, RESET);

    output [31:0] PC;           //Peogram Counter
    input [31:0] INSTRUCTION;   //Instruction
    input CLK, RESET;

    reg [7:0] OPCODE, RD, RT, RS;  //Instruction -> | OPCODE | RD | RT | RS/IMM |
    wire REG_WRITE_ENABLE, S_MUX1, S_MUX2, SHIFT_MUX, BRANCH, JUMP, ZERO, ANDOUT, OROUT, XOROUT,
        MREAD_SIG, MWRITE_SIG, BUSYWAIT, MEM_ALU_MUX_SIG, MEM_WRITE_ENABLE, MEM_READ_ENABLE;    // Signals for write enable, MUX1 select, MUX2 select
    wire [2:0] ALUOP, SHIFT_OP;                   // ALU operation signal line
    wire [7:0] OUT1, OUT2, COUT, MUX1_OUT, MUX2_OUT, SHIFT_MUX_OUT, RESULT, SHIFTED_VALUE,
        MDREAD, MEM_ALU_MUX; // register file out1,out2, complemented value, MUX1 output,MUX2 output, ALU result
    reg [2:0] INADDRESS, OUT1ADDRESS, OUT2ADDRESS; // Address lines for register file
    reg BRANCH_SIGN;
    
    wire [31:0] PCADDR, C_FOUR, PCADDROUT, TARGETADDROUT, EADDR;

    regPC myRegPC(PC, RESET, CLK, PCADDR);
    controlUnit myControlUnit(REG_WRITE_ENABLE, ALUOP, SHIFT_OP, S_MUX1, S_MUX2,SHIFT_MUX, BRANCH, JUMP, OPCODE);
    reg_file myRegFile(OUT1, OUT2, MEM_ALU_MUX, INADDRESS, OUT1ADDRESS, OUT2ADDRESS, WRITEENABLE, CLK, RESET);
    complement myComplement(COUT, OUT2);
    alu myAlu(ZERO, RESULT, OUT1, SHIFT_MUX_OUT, ALUOP);

    b8_shifter shifter(OUT1,RS[2:0], SHIFT_OP, SHIFTED_VALUE);

    data_memory myDataMemory(CLK, RESET, MEM_READ_ENABLE, MEM_WRITE_ENABLE, RESULT, OUT1, MDREAD , BUSYWAIT); // Data memory module

    addr myPcAddr(PCADDROUT, PC, C_FOUR); 
    addr myTargetAddr(TARGETADDROUT, PCADDROUT, EADDR);
    extender myExtender(EADDR, RD);
    and (ANDOUT, BRANCH, XOROUT);
    or (OROUT, ANDOUT, JUMP);
    xor (XOROUT, BRANCH_SIGN, ZERO);

    assign MUX1_OUT = S_MUX1 ? COUT : OUT2;
    assign MUX2_OUT = S_MUX2 ? MUX1_OUT : RS;
    assign SHIFT_MUX_OUT = SHIFT_MUX ? SHIFTED_VALUE : MUX2_OUT;
    assign C_FOUR = 4;
    assign PCADDR = OROUT ? TARGETADDROUT : PCADDROUT;
    assign MEM_ALU_MUX = MEM_ALU_MUX_SIG ? MDREAD : RESULT;

    always @(*) begin
        OPCODE = INSTRUCTION[31:24]; //Opcode Extraction
        RS = INSTRUCTION[7:0];       //RS value Extraction
        RT = INSTRUCTION[15:8];      //RT value Extraction
        RD = INSTRUCTION[23:16];     //RD value Extraction
        BRANCH_SIGN = OPCODE[7];

        OUT2ADDRESS = RS[2:0];       // out2 address from RS lower 3bit
        OUT1ADDRESS = RT[2:0];       // out1 address from RT lower 3bit
        INADDRESS = RD[2:0];         // in address from RD lower 3bit

    end
    
endmodule