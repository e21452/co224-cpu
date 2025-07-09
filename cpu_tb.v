// Computer Architecture (CO224) - Lab 05
// Design: Testbench of Integrated CPU of Simple Processor
// Author: Isuru Nawinne
`include "cpu.v"
`include "dcache.v"

module cpu_tb;

    reg CLK, RESET;
    wire [31:0] PC;
    reg [31:0] INSTRUCTION;

    /* 
    ------------------------
     SIMPLE INSTRUCTION MEM
    ------------------------
    */
    
    // TODO: Initialize an array of registers (8x1024) named 'instr_mem' to be used as instruction memory
        reg [7:0] instr_mem[1024:0];
    
    // TODO: Create combinational logic to support CPU instruction fetching, given the Program Counter(PC) value 
    //       (make sure you include the delay for instruction fetching here)
    initial INSTRUCTION = 0;
    always @(posedge CLK ) begin
        #2 INSTRUCTION = {instr_mem[PC + 3], instr_mem[PC + 2], instr_mem[PC + 1], instr_mem[PC]};
    end
    initial
    begin
        // Initialize instruction memory with the set of instructions you need execute on CPU
        
        // METHOD 1: manually loading instructions to instr_mem
        {instr_mem[10'd3], instr_mem[10'd2], instr_mem[10'd1], instr_mem[10'd0]} = 32'b00000000_00000100_00000000_00000101;         //  loadi 4 0x05    ; r4 = 5
        {instr_mem[10'd7], instr_mem[10'd6], instr_mem[10'd5], instr_mem[10'd4]} = 32'b00000000_00000010_00000000_00000101;         //  loadi 2 0x05    ; r2 = 5
        {instr_mem[10'd11], instr_mem[10'd10], instr_mem[10'd9], instr_mem[10'd8]} = 32'b00000010_00000110_00000100_00000010;       //  add 6 4 2       ; r6 = r4 + r2
        {instr_mem[10'd15], instr_mem[10'd14], instr_mem[10'd13], instr_mem[10'd12]} = 32'b00000001_00000000_00000000_00000110;     //  mov 0 6		    ; r0 = r6
        {instr_mem[10'd19], instr_mem[10'd18], instr_mem[10'd17], instr_mem[10'd16]} = 32'b00000111_00010100_00000100_00000010;     //  beq 0x14 2 4	
        {instr_mem[10'd103], instr_mem[10'd102], instr_mem[10'd101], instr_mem[10'd100]} = 32'b00000000_00000001_00000000_00000001;     //  loadi 1 0x01	; r1 = 1
        {instr_mem[10'd107], instr_mem[10'd106], instr_mem[10'd105], instr_mem[10'd104]} = 32'b10000111_00010111_00000010_00000001;     // bne 0x17 2 1
        {instr_mem[10'd203], instr_mem[10'd202], instr_mem[10'd201], instr_mem[10'd200]} = 32'b0000_1011_00000000_00000110_00000110;     //  swi 5 0x6		;
        {instr_mem[10'd207], instr_mem[10'd206], instr_mem[10'd205], instr_mem[10'd204]} = 32'b0000_1010_00000000_00000100_00000100;     //  swd 3 4		;
        {instr_mem[10'd211], instr_mem[10'd210], instr_mem[10'd209], instr_mem[10'd208]} = 32'b0000_0010_00000110_00000100_00000010;     //  add 6 4 2 		;
        {instr_mem[10'd215], instr_mem[10'd214], instr_mem[10'd213], instr_mem[10'd212]} = 32'b0000_1001_00000001_00000000_00000110;     //  lwi 1 0x6		;


        // METHOD 2: loading instr_mem content from instr_mem.mem files
        // $readmemb("programmer/instr_mem.mem", instr_mem);
    end
    
    /* 
    -----
     CPU
    -----
    */
    wire MEM_READ_ENABLE, MEM_WRITE_ENABLE, MEM_BUSYWAIT;
    wire [31:0] MEM_WRITE_DATA, MEM_READ_DATA;
    wire [5:0] MEM_ADDRESS;
    wire CACHE_READ_ENABLE, CACHE_WRITE_ENABLE, BUSYWAIT;
    wire [7:0] CACHE_WRITE_DATA, CACHE_READ_DATA;
    wire [7:0] CACHE_ADDRESS;

    cpu mycpu(PC,CACHE_READ_ENABLE, CACHE_WRITE_ENABLE, CACHE_WRITE_DATA, CACHE_ADDRESS, INSTRUCTION, CACHE_READ_DATA, BUSYWAIT, CLK, RESET);
    data_memory myDataMemory(CLK, RESET, MEM_READ_ENABLE, MEM_WRITE_ENABLE, MEM_ADDRESS, MEM_WRITE_DATA, MEM_READ_DATA , BUSYWAIT); // Data memory module
    dcache cache_memory(CLK, RESET, CACHE_READ_ENABLE, CACHE_WRITE_ENABLE, CACHE_ADDRESS, CACHE_WRITE_DATA, CACHE_READ_DATA, BUSYWAIT, 
                        MEM_BUSYWAIT, MEM_READ_DATA, MEM_WRITE_DATA, MEM_ADDRESS, MEM_READ_ENABLE, MEM_WRITE_ENABLE);

    // always @(posedge CLK ) begin
        
    // end
    integer i;
    initial begin
    
        // generate files needed to plot the waveform using GTKWave
        $dumpfile("cpu_wavedata.vcd");
		$dumpvars(0, cpu_tb);
        for (i = 0; i < 8; i++) begin       //assigning all register to 0
           $dumpvars(1, cpu_tb.mycpu.myRegFile.reg_arr[i]);                     //using for loop itereate through every register
        end
        CLK = 1'b0;
        
        // TODO: Reset the CPU (by giving a pulse to RESET signal) to start the program execution
        
        RESET = 1'b1;
        #5 RESET = 0;
        
        // finish simulation after some time
        #500
        $finish;
        
    end
    
    // clock signal generation
    always
        #4 CLK = ~CLK;
        

endmodule