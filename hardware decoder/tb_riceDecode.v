`timescale 1ns / 1ns
`include "/home/sathwikgs/scl_pdk_180nm/stdlib/fs120/verilog/vcs_sim_model/tsl18fs120_scl.v"
module tb_riceDecode;
 
  reg iClk, rst, en;
  reg [1:0] data;
  reg [3:0] rice_param;
  wire done;
  wire  [15:0] MSB, LSB;
  
  riceDecode DUT (.iClk(iClk),.iRst(rst), .iEn(en), .iData(data), .iRiceParam(rice_param), .oMSB(MSB), .oLSB(LSB), .oDone(done));

always
  begin
    #10 iClk = !iClk;
  end

  initial
  begin
  #0 iClk = 0; rst = 1; en = 0; data = 0; rice_param = 3;
  #20
  #10 en = 1; rst = 0;
      data = 2'b00;
  #20 data = 2'b00;
  #20 data = 2'b01;// 5 msbs
  #20 data = 2'b10;
  #20 data = 2'b10; // 5 lsbs == -23
  
  #20 data = 2'b01; // 2 msbs
  #20 data = 2'b11; // 6lsbs
  
  #20 data = 2'b01; // 0 msbs
  #20 data = 2'b01;
  #20 data = 2'b00; // 2 lsbs == 
  
  #20 data = 2'b00;
  #20 data = 2'b00;
  #20 data = 2'b11; // 5 msbs
  #20 data = 2'b11; // 7 lsbs
  #20 data = 2'b00;
  #20 data = 2'b00;
  #20 data = 2'b00;
  #20 data = 2'b00;
  #20 data = 2'b00;
  #20 data = 2'b01; // 11 msbs
  #20 data = 2'b00;
  #20 data = 2'b11; // 1 lsbs
  
  #20 $stop;
  end
endmodule
