//`include "/home/sathwikgs/scl_pdk_180nm/stdlib/fs120/verilog/vcs_sim_model/tsl18fs120_scl.v"

`timescale 1ns / 100ps
   
module tb_fixedDecode2;

//integer i;
reg clk, rst, ena, wren;
wire Done;

//wire [15:0]sample_mem[0:30];

reg [15:0]block_size;
//reg [3:0] predictor_order;
//reg [3:0] partition_order;
//wire [3:0] curr_bit;

reg [15:0] memory[0:20]; 

wire [5:0] SamplesRead;
wire [15:0] TestOut;
wire signed [15:0] oData;
wire [15:0] ReadAddr, RamReadAddr;
//wire [15:0]  RamData;
//reg [15:0] WriteAddr;
reg [15:0] SetupReadAddr;
wire [15:0] iData;


assign RamReadAddr = ena ? ReadAddr : SetupReadAddr;
assign iData = ena ? memory[RamReadAddr]: 16'd0;

fixedDecode2 DUT (
         .iClk(clk), 
         .iRst(rst), 
         .iEnable(ena),
         .iOrder(4'd4),
 	 .StartAddr(16'd4),
	 .iSample(iData),
	 .oData(oData),
	 .ReadAddr(ReadAddr),
     .TestOut(TestOut),
     .SamplesRead(SamplesRead));


    always begin
        #10 clk = !clk;
    end
    
    //integer samples_read;

    

    initial begin
        memory[0] = 16'b0000000000000001;
        memory[1] = 16'b0000000000000010;
        memory[2] = 16'b0000000000000011;
        memory[3] = 16'b0000000000000100;
        memory[4] = 16'b0000001000000100;
        memory[5] = 16'b0100010100110001;
        memory[6] = 16'b0000000000001000;
        memory[7] = 16'b1110101110101100;
        memory[8] = 16'b0001101001011001;
        memory[9] = 16'b1000000000000101;
        memory[10] = 16'b1110000000000000;

	    block_size = 16'd16;
    
        /* Read the memory into the RAM */
        clk = 0; wren = 0; rst = 1; ena = 0; 
        SetupReadAddr = 0;
 
        #20;

        #45 rst = 0; ena = 1;
	end
	
	
  	
    
	always@(posedge clk) begin
	
    //    if (Done) begin
        //    $display ("%d", oData);
        //    $fwrite(file, "%d\n", oData);
      //      samples_read <= samples_read + 1;
     //   end
        
        //if (samples_read == 16) $stop;
        if (SamplesRead == 6'd16) begin
        //    $fclose(file);
            $stop;
        end

	end
    
        
    

endmodule
