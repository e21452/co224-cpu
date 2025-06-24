module reg_file (
    output reg [7:0] out1,out2,
    input [7:0] in,
    input [2:0] in_addr,out1_addr,out2_addr,
    input write,clk,reset

);

    reg [7:0] reg_arr [7:0];       //8x8 register file
    integer i;

    always @(*) begin
        #2 out1 = reg_arr[out1_addr];
        out2 = reg_arr[out2_addr];              //assigning out1 and out2 according to out1_addr and out2_addr
    end

    
    always @(posedge clk) begin
        if(reset) begin     
        #1  for (i = 0; i < 8; i++) begin       //assigning all register to 0
                reg_arr[i] = 0;                 //using for loop itereate through every register
            end
        end
        else if (write) 
            #1 reg_arr[in_addr] = in;           // writing in value to the register that determined from the in_addr
        
    end
    
endmodule

