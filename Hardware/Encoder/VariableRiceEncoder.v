/**
 * File Name: VariableRiceEncoder.v
 * Module Name: VariableRiceEncoder
 * Type: Verilog file
 * Description: Encodes residuals according to Rice coding
 * Author: Joshua D'Cunha
 * Last Modified: 29th May 2020
*/

module VariableRiceEncoder (
    input wire iClock,
    input wire iReset,
    
    input wire iValid,
    input wire signed [15:0] iSample,
    
    input wire [3:0] iRiceParam,
    
    output wire [15:0] oMSB,
    output wire [15:0] oLSB,
    output wire oValid
//    output wire [15:0] rSample, // just to display reg sample
//    output wire [15:0] uSample, // just to display reg unsigned_sample
//    output wire [3:0] riceParam
    );

reg [15:0] sample, unsigned_sample;
reg [2:0] valid; // 3 bits because it is a 3 stage pipeline
reg [15:0] msb, lsb;
reg [3:0] rice_param, rice_param2; //rice_param2 for correct pipeline design (see diagram)

/*
----------        ------------------------           ----------
| sample  |  ==>  |    unsigned sample   |     ==>   |   msb   |
----------        ------------------------           -----------

----------        ------------------------           ----------
| rice_p  |  ==>  |    rice_param2       |     ==>   |   lsb   |
----------        ------------------------           -----------

----------        ------------------------           -----------
|valid[0] |  ==>  |    valid[1]           |     ==>  |valid[2]  |
----------        ------------------------           -----------
*/

assign oMSB = msb;
assign oLSB = lsb;
assign oValid = valid[2];
//assign uSample = unsigned_sample;
//assign rSample = sample;
//assign riceParam = iRiceParam;

always @(posedge iClock or posedge iReset) begin
    if (iReset) begin
        sample <= 0;
        unsigned_sample <= 0;
        rice_param <= 0;
        msb <= 0;
        lsb <= 0;
        
        valid <= 3'b000;
    end else begin
        rice_param <= iRiceParam;
        /* Register input */
        sample <= iSample;
        valid <= valid<<1 | iValid;
        
        /* Convert sample to unsigned sample */
        if (sample[15]) begin // if a negative number
            // {sample[14:0], 1'b0} -> this does 2*(sample + 2**(n-1)) = 2*sample (where n is the # of bits)
            // ^ 16'hffff -> complement of the number
            // Now -x = x' + 1 => x' = -x - 1 => (2*sample)' = -2*sample - 1    
            unsigned_sample <= {sample[14:0], 1'b0} ^ 16'hffff; // this does the job of (2|n| - 1) trust me!
        end else begin
            unsigned_sample <= {sample[14:0], 1'b0}; // this does the job of 2n
        end
        
        rice_param2 <= rice_param;
        msb <= unsigned_sample >> rice_param2;
        lsb <= 1 << rice_param2 | unsigned_sample & ((1 << rice_param2) - 1);
        
    end
end

endmodule