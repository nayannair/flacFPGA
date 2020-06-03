/**
 * File Name: ResidualBuffer.v
 * Module Name: ResidualBuffer
 * Type: Verilog file
 * Description: Stores residuals from LPC encoder and outputs them in order of receiving 
 * Author: Joshua D'Cunha
 * Last Modified: 3rd June 2020
*/

`timescale 1ns / 100ps

module ResidualBuffer (
    input iClock,
    input iValid,
    input iReset,
    input oEnable,
    input signed [15:0] iResidual,

    output signed [15:0] oResidual,
    output oValid
    );
    
parameter blkSize = 16; // Maximum size of residual buffer

reg signed [15:0] buffer [0:blkSize-1];

integer i;

assign oResidual =  buffer[counter];

reg oValidReg;
assign oValid = oValidReg;

reg [4:0] counter; // Keeps track of # of residuals stored in the buffer

/*
                     ||
                     \/
            ---------------------
counter =>  |     buffer[0]     | => oResidual
(initial)   ---------------------
            ---------------------
            |     buffer[1]     | 
            ---------------------
            ---------------------
            |     buffer[2]     |
            ---------------------
                     .
                     .
                     .
            ---------------------
            | buffer[blkSize-1] |
            ---------------------
*/

always @(posedge iClock or posedge iReset) begin
    if (iReset) begin
        for (i = 0; i < blkSize; i = i + 1) begin
            buffer[i] <= 0;
        end
        oValidReg <= 0;
        counter <= 0;
    end else if (iValid) begin
        for (i = 1; i < blkSize; i = i + 1) begin
            buffer[i] <= buffer[i - 1];
        end
        buffer[0] <= iResidual; 
        counter <= counter + 1;
    end else if (oEnable) begin
        if (counter > 0) begin
            oValidReg <= 1;
            counter <= counter - 1;
        end else begin
            oValidReg <= 0;
        end
    end
end
endmodule