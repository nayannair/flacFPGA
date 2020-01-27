`timescale 1ns / 1ns
`include "/home/sathwikgs/scl_pdk_180nm/stdlib/fs120/verilog/vcs_sim_model/tsl18fs120_scl.v"

		  
module tb_fixedDecoderlpc;
 
  reg    iEnable;
  reg    iRst;
  wire  signed [15:0]  oData;
  reg  [7:0] iOrder;
  reg    iClk;
  reg signed  [15:0]  iSample;
 fixedDecoderlpc 
   DUT  ( 
       .iEnable (iEnable ) ,
      .iRst (iRst ) ,
      .oData (oData ) ,
      .iOrder (iOrder ) ,
      .iClk (iClk ) ,
      .iSample (iSample ) ); 
  
  always
  begin
    #10 iClk = !iClk;
  end

  initial
  begin
		#0 iClk = 0;
		/*#20 iRst = 1;
		#20 iRst = 0; iEnable = 1;
		#20 iOrder = 0; 
		    iSample = 10;
		#20 iSample = -7; `assert(iSample, 10)
		#20 iSample = -4;
		#20 iSample = 8;
		#20 iSample = 2;
		#20 iSample = -3;
		#20 iSample = 1;
		#20 iSample = 0;
		
		#20 iRst = 1;
		#20 iRst = 0; iEnable = 1;
		#20 iOrder = 1; // dataq[0] <= iSample + dataq[1];   
            iSample = 10;
		#20 iSample = -7; // No out
		#20 iSample = -4; // 3
		#20 iSample = 8;  // -1 
		#20 iSample = 2; // 7
		#20 iSample = -3; // 9
		#20 iSample = 1; // 6
		#20 iSample = 0; // 7
		
		#20 iRst = 1;
		#20 iRst = 0; iEnable = 1; iOrder = 2; //dataq[0] <= iSample + 2*dataq[1] - dataq[2]; 
            iSample = 10; 
		#20 iSample = -7; 
		#20 iSample = -4; 
		#20 iSample = 8;
		#20 iEnable = 0;
		#20 iSample = 2;
		#20 iSample = -3;
		#20 iSample = 1;
		#20 iSample = 0;*/
		
		#20 iRst = 1; iEnable = 0; iOrder = 3; iSample = 0;
		#30 iRst = 0; iEnable = 1; iOrder = 3; 
            iSample = 20;
		#20 iSample = 10;
		#20 iSample = -7;
		#20 iSample = -4;
		#20 iSample = 8;
        #20 iSample = 0;
		#20 iSample = 2;
		#20 iSample = -3;
		#20 iSample = 1;
		#20 iSample = 0;
		#20;
		#20;
		#20;
		#20;
		#20;
		#20;
		#20 $stop;
		// Output. 0, 20, 10, -7, -35, -66, -100, -135, -174, -216, -261, -309, 
		//         -360, -414, -471, -531, -595
		
  end
  
	initial
	#1000 $stop;
	
endmodule
