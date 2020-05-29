/**
 * File Name: fixed_encoder_4.v
 * Module Name: FixedEncoderOrder4
 * Type: Verilog file
 * Description: Fixed 4th order LPC encoder
 * Author: Joshua D'Cunha
 * Last Modified: 29th May 2020
 * Note: Calculates residuals not the predictions
*/

module FixedEncoderOrder4 (input wire iClock,
                           input wire iReset, 
                           input wire iValid,
                           input wire signed [15:0] iSample,
                           output wire signed [15:0] oResidual,
//                           output wire signed [15:0] datum,
                           output wire oValid
                           );
/* 
 * This is the slowest, i.e. longest latency, encoder
 * Latency is 8 cycles after enable signal
 */
 
reg signed [15:0] dataq [0:4];
// Calculation of residual using 4th order LPC
// data = data0 - 4data1 + 6data2 - 4data3 + data4
// A = d0 + d4 | B = d1 << 2 + d3 << 2 | C = d2 << 2 + d2 << 1
// residual = A - B + C
reg signed [15:0] termA, termB, termC, termCd1, termD;
reg signed [15:0] residual;
// counter to keep track of data queue being filled
reg [2:0] warmup_count;
// Latency of 8 clock cycles from input to output so we have this 
// register that keeps track of input changing to output. 
reg [7:0] valid;

integer i;

//assign datum = dataq[0];
assign oResidual = residual;
// After 8 clock cycles, if the input is valid, output will be valid and valid[7] will be set HIGH
assign oValid = valid[7];

always @(negedge iClock or posedge iReset)
begin
    if (iReset) begin
        warmup_count <= 0;
        for (i = 0; i <= 4; i = i + 1) begin
            dataq[i] <= 16'b0;
        end
        residual <= 16'b0;
        termA <= 16'b0;
        termB <= 16'b0;
        termC <= 16'b0;
        termD <= 16'b0;
        termCd1 <= 16'b0;
        valid <= 0;
    end else begin
    
        valid <= valid<<1 | iValid;
        // Shift the data queue down
        for (i = 1; i <= 4; i = i + 1) begin
            dataq[i] <= dataq[i - 1];
        end
        
        // Register the input and feed the queue
        dataq[0] <= iSample;
        
        // Wait until the queue is filled 
        if (warmup_count <= 4) begin
            warmup_count <= warmup_count + 1;
        end else begin
            // Unpipelined version
            //residual <= dataq[0] - 4*dataq[1] + 6*dataq[2] - 4*dataq[3] + dataq[4]; 
            
            // Pipelined version
            // Phase 1 of pipeline
            termA <= dataq[0] + dataq[4];
            termB <= (dataq[1] << 2) + (dataq[3] << 2);
            termC <= (dataq[2] << 2) + (dataq[2] << 1);
            
            // Phase 2 of pipeline
            termD <= termA - termB;
            termCd1 <= termC;
            
            // Phase 3 of pipeline
            residual <= termD + termCd1;
        end
    end
end

endmodule