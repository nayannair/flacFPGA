/**
 * File Name: tb_VariableRiceEncoder.v
 * Module Name: VariableRiceEncoderTB
 * Type: Verilog file
 * Description: Testbench for VariableRiceEncoder module
 * Author: Joshua D'Cunha
 * Last Modified: 3rd June 2020
 * NOTE: MAKE SURE THE MODULE IS TRIGGERED (@posedge) FOR TESTBENCH TO WORK!
*/

`timescale 1ns / 100ps

module VariableRiceEncoderTB;

reg clk, rst;

always begin
    #0 clk = 0;
    #125 clk = 1;
    #125 clk = 0;
end

reg valid;
reg signed [15:0] residual;

reg [3:0] vre_rp;
wire [15:0] vre_msb, vre_lsb;
//wire [15:0] uSample;
//wire [15:0] rSample;
wire vre_valid;

VariableRiceEncoder vre (
    .iClock(clk),
    .iReset(rst),
    
    .iValid(valid),
    .iSample(residual), 
    
    .iRiceParam(vre_rp),
    .oMSB(vre_msb),
    .oLSB(vre_lsb),
    .oValid(vre_valid)
//    .rSample(rSample),
//    .uSample(uSample)
    
    );

initial begin
    valid = 0; rst = 1; vre_rp = 0; residual = 0;
    
    #125 rst = 0;
    
    #125 valid = 1; vre_rp = 0; residual = 20;    
    
    #250 vre_rp = 4; residual = -123;
    
    #250 vre_rp = 6; residual = 31;
    
    #250 valid = 0;
    
    #2500
        
    $stop;
end

endmodule