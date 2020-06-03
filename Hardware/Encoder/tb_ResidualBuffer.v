/**
 * File Name: tb_ResidualBuffer.v
 * Module Name: ResidualBufferTB
 * Type: Verilog file
 * Description: Testbench for ResidualBuffer module
 * Author: Joshua D'Cunha
 * Last Modified: 3rd June 2020
 * NOTE: MAKE SURE THE MODULE IS TRIGGERED (@posedge) FOR THIS TESTBENCH TO WORK!
*/

`timescale 1ns / 100ps

module ResidualBufferTB;

reg iClock;
reg iValid;
reg iReset;
reg oEnable;
reg signed [15:0] iResidual;
wire signed [15:0] oResidual;
wire oValid;
wire [4:0] counter;

ResidualBuffer DUT (
                    .iClock(iClock),
                    .iValid(iValid),
                    .iReset(iReset),
                    .oEnable(oEnable),
                    .iResidual(iResidual),
                    .oResidual(oResidual),
                    .oValid(oValid),
                    .counter(counter)
                   );
always begin
    #0 iClock = 0;
    #125 iClock = 1;
    #125 iClock = 0;
end

initial begin
    iReset = 1; iValid = 0; oEnable = 0;
    
    #125 iReset = 0;
    
    #125 iValid = 1; iResidual = 20;

    #250 iResidual = -123;

    #250 iResidual = 31;
    
    #250 iResidual = 100;
    
    #250 iResidual = 16;
     
    #250 iResidual = 32;
    
    #250 iResidual = 64;
    
    #250 iResidual = -123;

    #250 iResidual = 31;
    
    #250 iResidual = 100;
    
    #250 iResidual = 16;
     
    #250 iResidual = 32;    
    
    #250 iValid = 0; iResidual = 0;
    
    #250;
    
    #250 oEnable = 1;

    while (counter > 5'b00000) begin
        #250;
    end
    
    #250;

    $finish;
end

endmodule