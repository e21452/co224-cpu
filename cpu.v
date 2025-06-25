`include "alu.v"
`include "regFile.v"
`include "bit8Shifter.v"
`include "memory.v"
`include "controlunit.v"

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



module complement (OUT, IN); //Module for 2's complemented value

    output [7:0] OUT;
    input [7:0] IN;

    assign #1 OUT = ~IN + 1;

endmodule

module cpu (PC,MEM_READ_ENABLE, MEM_WRITE_ENABLE, MEM_WRITE_DATA, MEM_ADDRESS, INSTRUCTION, MEM_READ_DATA, BUSYWAIT, CLK, RESET);

    output [31:0] PC;  //Peogram Counter
    output MEM_READ_ENABLE, MEM_WRITE_ENABLE; // Memory read and write enable signals
    output [7:0] MEM_WRITE_DATA, MEM_ADDRESS; // Memory write data and address           
    input [31:0] INSTRUCTION;   //Instruction
    input CLK, RESET, BUSYWAIT;
    input [7:0] MEM_READ_DATA; // Memory read data

    reg [7:0] OPCODE, RD, RT, RS;  //Instruction -> | OPCODE | RD | RT | RS/IMM |
    wire REG_WRITE_ENABLE, S_MUX1, S_MUX2, SHIFT_MUX, BRANCH, JUMP, ZERO, ANDOUT, OROUT, XOROUT,
        MEM_ALU_MUX_SIG;    // Signals for write enable, MUX1 select, MUX2 select
    wire [2:0] ALUOP, SHIFT_OP;                   // ALU operation signal line
    wire [7:0] OUT1, OUT2, COUT, MUX1_OUT, MUX2_OUT, SHIFT_MUX_OUT, RESULT, SHIFTED_VALUE,
         MEM_ALU_MUX; // register file out1,out2, complemented value, MUX1 output,MUX2 output, ALU result
    reg [2:0] INADDRESS, OUT1ADDRESS, OUT2ADDRESS; // Address lines for register file
    reg BRANCH_SIGN;
    
    wire [31:0] PCADDR, C_FOUR, PCADDROUT, TARGETADDROUT, EADDR;

    regPC myRegPC(PC, RESET, CLK, PCADDR);
    controlUnit myControlUnit(REG_WRITE_ENABLE, ALUOP, SHIFT_OP, S_MUX1, S_MUX2,SHIFT_MUX, BRANCH, JUMP, MEM_READ_ENABLE, MEM_WRITE_ENABLE, MEM_ALU_MUX_SIG, OPCODE, BUSYWAIT);
    reg_file myRegFile(OUT1, OUT2, MEM_ALU_MUX, INADDRESS, OUT1ADDRESS, OUT2ADDRESS, WRITEENABLE, CLK, RESET);
    complement myComplement(COUT, OUT2);
    alu myAlu(ZERO, RESULT, OUT1, SHIFT_MUX_OUT, ALUOP);

    b8_shifter shifter(OUT1,RS[2:0], SHIFT_OP, SHIFTED_VALUE);

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
    assign MEM_ALU_MUX = MEM_ALU_MUX_SIG ? MEM_READ_DATA : RESULT;

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