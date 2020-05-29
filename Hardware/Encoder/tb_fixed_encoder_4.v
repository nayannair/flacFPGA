/**
 * File Name: tb_fixed_encoder_4.v
 * Module Name: FixedEncoderOrder4TB
 * Type: Verilog file
 * Description: Testbench for FixedEncoderOrder4 module
 * Author: Joshua D'Cunha
 * Last Modified: 29th May 2020
*/

`timescale 1ns / 100ps

module FixedEncoderOrder4TB;

    reg iClock;
    reg iValid;
    reg iReset;
    reg signed [15:0] iSample;
    wire signed [15:0] oResidual;
//    wire signed [15:0] datum;
    wire oValid;
    
    FixedEncoderOrder4 DUT (
                            .iClock(iClock),
                            .iValid(iValid),
                            .iReset(iReset),
                            .iSample(iSample),
                            .oResidual(oResidual),
//                            .datum(datum),
                            .oValid(oValid)
                           );
  
    always
    begin
        #0 iClock = 0;
        #125 iClock = 1;
        #125 iClock = 0;
    end

    initial
    begin
        iReset = 1; iValid = 0; iSample = 0;
        
        #250 iReset = 0;
        
        #125 iSample = 20; iValid = 1;  
    
        #250 iSample = 10;
    
        #250 iSample = -7;
        
        #250 iSample = -4;
    
        #250 iSample = 8;
    
        #250 iSample = 0;
    
        #250 iSample = 2;
    
        #250 iSample = -3;
    
        #250 iSample = 1;
    
        #250 iValid = 0; iSample = 0;
        
        #2000
        
        $stop;
    end
    
  /* Expected output: -38, -18, 59, -47, 33, -30, 20, -7, 1 */
  
endmodule