/**
 * File Name: RiceEncoder.v
 * Module Name: RiceEncoder
 * Type: Verilog file
 * Description: Encodes residuals according to Rice coding with a fixed (parametrized) rice parameter
 * Authors: Stephan Sunny, Joshua D'Cunha
 * Last Modified: 3rd June 2020
*/

`timescale 1ns / 100ps

module RiceEncoder (
    input wire iClock,
    input wire iReset,
    
    input wire iValid,
    input wire signed [15:0] iSample, 
    output wire [15:0] oMSB,
    output wire [15:0] oLSB, 
    output wire [15:0] oBitsUsed,
    output wire oValid
    );

parameter [3:0] rice_param = 4;

reg [15:0] sample, unsigned_sample;
reg [2:0] valid; // 3 bits because it is a 3 stage pipeline
reg [15:0] msb, lsb, total;

/*
----------        ------------------------           ----------
| sample  |  ==>  |    unsigned sample   |     ==>   |   msb   |
----------        ------------------------           -----------

----------        ------------------------           -----------
|valid[0] |  ==>  |    valid[1]           |     ==>  |valid[2]  |
----------        ------------------------           -----------
*/

assign oMSB = msb;
assign oLSB = lsb;
assign oBitsUsed = total;
assign oValid = valid[2];


always @(posedge iClock) begin
    if (iReset) begin
        sample <= 0;
        unsigned_sample <= 0;
        
        msb <= 0;
        lsb <= 0;
        total <= 0;
        
        valid <= 0;
    end else begin
        /* Register input */
        sample <= iSample;
        valid <= (valid << 1) | iValid;
        
        /* Convert sample to unsigned sample */
        // if a negative number
        // {sample[14:0], 1'b0} -> this does 2*(sample + 2**(n-1)) = 2*sample (where n is the # of bits)
        // ^ 16'hffff -> complement of the number
        // Now -x = x' + 1 => x' = -x - 1 => (2*sample)' = -2*sample - 1
        if (sample[15]) begin
            unsigned_sample <= {sample[14:0], 1'b0} ^ 16'hffff; // does the job of -2n-1
        end else begin
            unsigned_sample <= {sample[14:0], 1'b0}; // does the job of 2n
        end
        
        msb <= unsigned_sample[15:rice_param];
        lsb <=  {1'b1, unsigned_sample[rice_param - 1:0]};
        total <= unsigned_sample[15:rice_param] + rice_param + 1;
        
    end
end

endmodule