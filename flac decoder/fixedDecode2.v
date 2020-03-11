module fixedDecode2(input iClk,
                    input iRst, 
                    input iEnable, 
                    input [3:0] iOrder, 
		    input [15:0] StartAddr,
                    input signed [15:0] iSample, 
                    output signed [15:0] oData,
		    output [15:0] ReadAddr,
		    output [15:0] TestOut,
		    output [5:0] SamplesRead);
 


reg [15:0]iBlockSize;    
reg [3:0]iPredictorOrder; 
reg [3:0]iPartitionOrder;   
reg [4:0] iStartBit; 
reg [15:0]iStartAddr;
wire signed [15:0] oResidual;
wire oDone;
reg [15:0] iData;
wire [15:0] oReadAddr;
wire [3:0] oCurrBit;  

reg [5:0]sample_count;
reg resD_rst, resD_en;


reg signed [15:0] dataq [0:4];
reg [15:0] warmup_count;
reg [1:0] state;
parameter WARMUP = 2'b00, RES = 2'b01, DEC = 2'b10;


resDecode resD(.iClk(iClk), 
         .iRst(resD_rst), 
         .iEn(resD_en),
         
         .iBlockSize(iBlockSize),
         .iPredictorOrder(iPredictorOrder),
         .iPartitionOrder(iPartitionOrder),
         
         .iStartBit(iStartBit),
         .iStartAddr(iStartAddr),
         
         .oResidual(oResidual),
         .oDone(oDone),
         
 
         .iData(iData),
         .oReadAddr(oReadAddr),
         .oCurrBit(oCurrBit)
         );
  
reg [15:0]out_mem[0:30];
reg [15:0]sample_mem[0:30];
reg [15:0]TestOut_reg;


reg [15:0]curr_addr,store_addr;
reg [5:0] samples_read;

assign oData = state[0]? sample_mem[curr_addr]:iSample ; 
assign ReadAddr = state[0]? oReadAddr:(state[1]? curr_addr:warmup_count);
assign TestOut = TestOut_reg;
assign SamplesRead = sample_count;


always @(posedge iClk)
begin
    if (iRst) begin
	iBlockSize <= 16'd16;
	iPredictorOrder <= iOrder;
	iPartitionOrder <= 4'd0;
	iStartBit <= 5'd15;
	iStartAddr <= 16'd4;  
	state <= 2'b00;

    sample_count <= 6'd4;
	store_addr <= 16'd0;
	samples_read <= 6'd0;

	resD_rst <= 1'b1;
	resD_en <= 1'b0;

        warmup_count <= 16'b0;
        dataq[0] <= 16'b0;
        dataq[1] <= 16'b0;
        dataq[2] <= 16'b0;
        dataq[3] <= 16'b0;
        dataq[4] <= 16'b0;
    end else if (iEnable) begin
	case(state)
	WARMUP:   begin
			resD_en <= 1'b0; 	
			dataq[4] <= dataq[3];
			dataq[3] <= dataq[2];
			dataq[2] <= dataq[1];
			dataq[1] <= dataq[0];
		
		
			iData<= iSample; 
			if (warmup_count < iOrder) begin
			    sample_mem[warmup_count] <= iSample;
			    out_mem[warmup_count] <= iSample;
			    dataq[0] <= iSample;
			    warmup_count <= warmup_count + 1'b1;
			
		        end  else if (warmup_count == iOrder) begin
				curr_addr <= warmup_count;
				
			 	state <= RES;	
				resD_rst <= 1'b0;
				resD_en <= 1'b1;
		
			end

		end

	RES:   begin	
	
			iData <= iSample; 
					
			resD_en <= 1'b1;
			if(oDone) begin
			    out_mem[curr_addr] <= oResidual;
			    curr_addr <= curr_addr + 1'b1;	
	  		    samples_read <= samples_read + 1;		
			end
			
			if(samples_read == iBlockSize-iOrder) begin
			    state <= DEC;
			  
			    resD_en <= 1'b0;
			    curr_addr <= warmup_count;
			    
			end
			
	       end
	

	DEC:   begin
			//if(!first) begin
		   	dataq[4] <= dataq[3];
			dataq[3] <= dataq[2];
			dataq[2] <= dataq[1];
			dataq[1] <= out_mem[curr_addr] + 15'd4*dataq[1] - 15'd6*dataq[2] + 15'd4*dataq[3] - dataq[4];
			
			sample_count <= sample_count + 1'b1;
			TestOut_reg <= out_mem[curr_addr] + 15'd4*dataq[1] - 15'd6*dataq[2] + 15'd4*dataq[3] - dataq[4];
			sample_mem[curr_addr] <= out_mem[curr_addr] + 15'd4*dataq[1] - 15'd6*dataq[2] + 15'd4*dataq[3] - dataq[4];
			curr_addr <= curr_addr + 1'b1;			    
			
			//
			//state <= WARMUP;  
			//end

		end

	endcase
    end
end
endmodule
