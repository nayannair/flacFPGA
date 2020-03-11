/* Module that receives MSB, LSB and Rice Parameter to produce de-mapped values */  
module demapper(input iClk,
input [15:0] iMSB,
input [15:0] iLSB,
input [3:0] iRiceParam,
output signed [15:0] oData);

reg signed [15:0] data;
assign oData = data;

always @(posedge iClk)
begin
    if (iLSB[0] || (iRiceParam == 0 && iMSB[0]))                          /* Checking whether number is even or odd */                
		data <= -(((iMSB << iRiceParam) | iLSB) >> 1'b1) - 1'b1;  /* De-mapping to */
	else                                                              /* original value */ 
		data <= ((iMSB << iRiceParam) | iLSB) >> 1'b1;            /* from mapped values */
end
endmodule 

