/*
Module  : Data Cache 
Author  : Isuru Nawinne, Kisaru Liyanage
Date    : 25/05/2020

Description	:

This file presents a skeleton implementation of the cache controller using a Finite State Machine model. Note that this code is not complete.
*/
`include "sub_modules\comparator.v"
`include "sub_modules\mux4_1_8bit.v"
`include "sub_modules\mux8_1_37bit.v"

// `timescale 1ns/100ps

module dcache (
    clock,
    reset,
    read,
    write,
    address,
    writedata,
    readdata,
    busywait,
    mem_busywait,
    mem_readdata,
    mem_writedata,
    mem_address,
    mem_read,
    mem_write
    );

    input           clock;
    input           reset;
    input           read;
    input           write;
    input[7:0]      address;
    input[7:0]      writedata;
    output reg [7:0]readdata;
    output reg      busywait;
    input           mem_busywait;
    input[31:0]     mem_readdata;
    output reg[31:0]mem_writedata;
    output reg[5:0] mem_address;
    output reg      mem_read;
    output reg      mem_write;

    /*
    Combinational part for indexing, tag comparison for hit deciding, etc.
    */

    //Declaring reg for cache
    reg[36:0] cache_block[7:0];
    reg hit;

    // decode values of index, tag, and offset from incoming address
    wire[2:0] index, tag;
    wire[1:0] offset;
    assign {tag,index,offset} = address;

    // -----------------------------------------------------------------
    // asert the busywait signal if read or write request is recieved
    always @(read, write)
    begin
        busywait = (read || write)? 1 : 0;
    end

    // ----------------------------------------------------
    wire[36:0] cache_block_data;
    wire[7:0] data_out;

    mux8_1_37 cacheblock_mux(
        cache_block[7],
        cache_block[6],
        cache_block[5],
        cache_block[4],
        cache_block[3],
        cache_block[2],
        cache_block[1],
        cache_block[0],index,cache_block_data);

    // Extract the stored data, valid_bit, dirty_bit, and cache_tag.
    // has a delay of #1
    wire[2:0] cache_tag;
    wire[31:0] datablock_data;
    wire cache_valid,cache_dirty;

    assign #1 {cache_valid,cache_dirty,cache_tag,datablock_data} = cache_block_data;

    // ----------------------------------------------------------------------
    // Instantiate the comparator
    // HIGH if tag_cache is equal to tag in address
    wire cmpr_result;
    comparator comparator(cache_tag,tag,cmpr_result);

    // Select the correct word using the offset
    mux4_1_8 db_offset_mux(
        datablock_data[7:0],
        datablock_data[15:8],
        datablock_data[23:16],
        datablock_data[31:24],
        offset,
        data_out
    );

    // Detect hit or miss
    always@(*)
    begin
      if(read||write) begin
        #0.9 hit = cmpr_result && cache_valid;
      end
    end

    // ---------------------------------------------------------------------

    //Read the cache asynchronously
    // Data word selection has a latency of #1 but this overlaps with the tag comparison
    always @(*)
    if(hit && read && !write)
    begin
        readdata = data_out;
        busywait = 0;
    end


    // Writing
    always@(posedge clock)
    begin
     if(write && !read && hit )
        begin
        busywait = 0;

        //Demux to writedata to the correct registers of the selected data block             
        case(offset)
            2'b00:  #1 cache_block[index][31:24] = writedata; 
            2'b01:  #1 cache_block[index][23:16] = writedata; 
            2'b10:  #1 cache_block[index][15:8]  = writedata; 
            2'b11:  #1 cache_block[index][7:0]   = writedata; 
            
        endcase

        //update dirty bit and valid bit
        cache_block[index][35] =1; // Dirty bit
        cache_block[index][36] =1; // Valid bit
                        
        end
    end

    integer i;

    //Reset memory
    always @(posedge reset)
    begin
        if (reset)
        begin
            for (i=0;i<8; i=i+1)
                cache_block[i] = 0;            
            busywait = 0;
        end
    end

    

    /* Cache Controller FSM Start */

    parameter IDLE = 3'b000, MEM_READ = 3'b001, MEM_WRITE = 3'b010;
    reg [2:0] state, next_state;

    // combinational next state logic
    always @(*)
    begin
        case (state)
            IDLE:
                if ((read || write) && !cache_dirty && !hit)  
                    next_state = MEM_READ;
                else if ((read || write) && cache_dirty && !hit)
                    next_state = MEM_WRITE;
                else
                    next_state = IDLE;
            
            MEM_READ:
                if (!mem_busywait)
                    next_state = IDLE;
                else    
                    next_state = MEM_READ;
            
            MEM_WRITE:
                if (!mem_busywait)
                    next_state = MEM_READ;
                else    
                    next_state = MEM_WRITE;
            
        endcase
    end

    // combinational output logic
    always @(*)
    begin
        case(state)
            IDLE:
            begin
                mem_read = 0;
                mem_write = 0;
                mem_address = 8'dx;
                mem_writedata = 8'dx;
                busywait = 0;
            end
         
            MEM_READ: 
            begin
                mem_read = 1;
                mem_write = 0;
                mem_address = {tag, index};
                mem_writedata = 32'dx;
                busywait = 1;
                #1 //delay to write data loaded from memory to cache
                if(!mem_busywait) begin
                  busywait = 1;
                  cache_block[index][31:0] = {mem_readdata[7:0],mem_readdata[15:8],mem_readdata[23:16],mem_readdata[31:24]};
                  cache_block[index][36:32] = {2'b10,tag}; 
                end
            end
            
            MEM_WRITE: 
            begin
                mem_read = 0;
                mem_write = 1;
                mem_address = {cache_tag, index};
                mem_writedata = {datablock_data[7:0],datablock_data[15:8],datablock_data[23:16],datablock_data[31:24]};
                busywait = 1;
            end
        endcase
    end

    // sequential logic for state transitioning 
    always @(posedge clock, reset)
    begin
        if(reset)
            state = IDLE;
        else
            state = next_state;
    end
    /* Cache Controller FSM End */

endmodule
