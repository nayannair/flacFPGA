module resDecode(input iClk,
input iRst,
input iEn,
input [1:0] iData,
input [3:0] iRiceParam, 
output reg [15:0] oMSB,
output reg [15:0] oLSB,
output oDone);
/* This module analyses the data stream and outputs the current LSBs and MSBs 
   for the stream. Whenever the done flag is raised, you can sample the correct LSBs and MSBs
*/

    reg [15:0] tempMSBs, tempLSBs;
    
    parameter IDLE = 2'b00, UNARY = 2'b01, REMAINDER = 2'b10;
    
    reg [1:0] state;
    reg done;
    
    assign oDone = done;
                         
    reg [3:0] rem_bits;
    
    always @(posedge iClk) begin
        if (iRst) begin
            state <= UNARY;
            done <= 0;
            tempLSBs <= 0;
            tempMSBs <= 0;
            oMSB <= 0;
            oLSB <= 0;
        end else if (iEn) begin
            case (state)
                UNARY:
                    begin
                        case (iData)
                        2'b00:
                            begin
                            tempMSBs <= tempMSBs + 2;
                            rem_bits <= rem_bits;
                            tempLSBs <= 0;
                            state <= UNARY;
                            done <= 0;
                            end
                        2'b01:
                            begin
                            tempMSBs <= tempMSBs + 1;
                            rem_bits <= iRiceParam - 1;
                            tempLSBs <= 0;
                            state <= REMAINDER;
                            done <= 0;
                            end
                        2'b10:
                            begin
                            tempMSBs <= tempMSBs;
                            rem_bits <= iRiceParam - 2;
                            tempLSBs <= 0;
                            state <= REMAINDER;
                            done <= 0;
                            end
                        2'b11:
                            begin
                            tempMSBs <= tempMSBs;
                            rem_bits <= iRiceParam - 2;
                            tempLSBs[iRiceParam - 1] <= 1;
                            state <= REMAINDER;
                            done <= 0;
                            end
                        endcase
                    end
                REMAINDER:
                    begin
                        if (rem_bits == 0) begin
                            oMSB <= tempMSBs;
                            oLSB <= tempLSBs | iData[1];
                            done <= 1;
                            if (iData[0] == 0) begin
                                tempMSBs <= 1;
                                state <= UNARY;
                            end else begin
                                tempMSBs <= 0;
                                tempLSBs <= 0;
                                state <= REMAINDER;
                                rem_bits <= iRiceParam - 1;
                            end
                            
                        end else if (rem_bits == 1) begin
                            oLSB <= tempLSBs | iData;
                            oMSB <= tempMSBs;
                            tempMSBs <= 0;
                            
                            done <= 1;
                            state <= UNARY;
                        end else begin
                            done <= 0;
                            tempLSBs <= (iData << (rem_bits - 1)) | tempLSBs;
                            rem_bits <= rem_bits - 2;
                            state <= REMAINDER;
                        end
                    end
            endcase
        end
    end
        
endmodule
