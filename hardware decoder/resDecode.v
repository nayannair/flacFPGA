module resDecode(input iClk, 
         input iRst, 
         input iEn,
         
         input [15:0] iBlockSize,
         input [3:0] iPredictorOrder,
         input [3:0] iPartitionOrder,
         
         input [4:0] iStartBit,
         input [15:0] iStartAddr,
         
         output signed [15:0] oResidual,
         output oDone,
         
  
         input [15:0] iData,
         output [15:0] oReadAddr,
         output [3:0] oCurrBit
         );

reg [15:0] data_buffer;
reg [15:0] rd_addr;
reg need_data;
reg [4:0] curr_bit;

reg wait_rd;
reg rs_idata, rs_enable, rs_rst;
wire rs_done;
wire signed [15:0] rd_odata;

wire [15:0] MSBs, LSBs;
wire [3:0] RiceParam;

reg done;

assign oResidual = rd_odata;
assign oDone = done;
assign oReadAddr = rd_addr;
assign oCurrBit = curr_bit;

demapper rd (.oData(rd_odata),
                .iRiceParam (RiceParam),
                .iClk (iClk),
                .iLSB (LSBs),
                .iMSB (MSBs));
                
riceDecode rs (.iClk(iClk),
                     .iRst(rs_rst),
                     .iEn(rs_enable),
                     .iData(rs_idata),
                     .iBlockSize(iBlockSize),
                     .iPredictorOrder(iPredictorOrder),
                     .iPartitionOrder(iPartitionOrder),
                     .oMSB(MSBs),
                     .oLSB(LSBs),
                     .oRiceParam(RiceParam),
                     .oDone(rs_done));

reg first;


always @(posedge iClk) begin
    if (iRst) begin
        curr_bit <= iStartBit;
        rd_addr <= iStartAddr;
        

        need_data <= 1'b0;
        
        rs_idata <= 1'b0;
        rs_enable <= 1'b0;
        rs_rst <= 1'b1;
	
	data_buffer <= iData;
 
       	done <= 1'b0;
	first <= 1'b1;
        
    end else if (iEn & !(first) ) begin
        if (need_data) begin
	    //data_buffer <= iData;
            rd_addr <= rd_addr + 1'b1;
            need_data <= 1'b0;
        end
	    

        done <= 1'b0;
        rs_rst <= 1'b0;
        rs_enable <= 1'b1;
        
        rs_idata <= data_buffer[4'd15];
        data_buffer <= {data_buffer[14:0], 1'b0};
        curr_bit <= curr_bit - 1'b1;
        
        if (curr_bit == 5'b0) begin
            data_buffer[15:0] <= iData;
            curr_bit <= 5'd15;
            need_data <= 1'b1;
        end
        
        if (rs_done) done <= 1'b1;
	
    end else if (iEn & first) begin
		first <=1'b0;	
		data_buffer <= iData;
	end
end
    
endmodule
