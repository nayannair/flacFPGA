`timescale 1ns / 1ns
`include "/home/sathwikgs/scl_pdk_180nm/stdlib/fs120/verilog/vcs_sim_model/tsl18fs120_scl.v"
		  
module tb_demapper; 
 
  wire  [15:0]  oData   ; 
  reg  [3:0]  iRiceParam;
  reg   iClk; 
  reg  [15:0] iLSB; 
  reg  [15:0] iMSB;
  
  demapper
   DUT  ( 
       .oData (oData ) ,
      .iRiceParam (iRiceParam ) ,
      .iClk (iClk ) ,
      .iLSB (iLSB ) ,
      .iMSB (iMSB ) ); 



always
  begin
    #10 iClk = !iClk;
  end

  initial
  begin
		#0 iClk = 0;
		#20 iRiceParam = 0; iMSB = 2; iLSB = 0; // 1
		#20 iRiceParam = 0; iMSB = 6; iLSB = 0; // 3
		#20 iRiceParam = 0; iMSB = 3; iLSB = 0; // -2
		#20 iRiceParam = 0; iMSB = 8; iLSB = 0; // 4
		#20 iRiceParam = 0; iMSB = 14; iLSB = 0; // 7
		#20 iRiceParam = 0; iMSB = 100; iLSB = 0; // 50
		#20 iRiceParam = 0; iMSB = 203; iLSB = 0; // -102
		#20 iRiceParam = 0; iMSB = 0; iLSB = 0; /* BLANK */
		#40 iRiceParam = 3; iMSB = 0; iLSB = 2; // 1
		#20 iRiceParam = 3; iMSB = 0; iLSB = 6; // 3
		#20 iRiceParam = 3; iMSB = 0; iLSB = 3; // -2
		#20 iRiceParam = 3; iMSB = 1; iLSB = 0; // 4
		#20 iRiceParam = 3; iMSB = 1; iLSB = 6; // 7
		#20 iRiceParam = 3; iMSB = 12; iLSB = 4; // 50
		#20 iRiceParam = 3; iMSB = 25; iLSB = 3; // -102
  end
  
  	initial
	#1000 $stop;
  
endmodule
