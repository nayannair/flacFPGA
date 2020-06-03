/**
 * File Name: RiceOptimizer.v
 * Module Name: RiceOptimizer
 * Type: Verilog file
 * Description: Module to calculate optimum rice parameter by selecting parameter associated with minimum total bits
 * Authors: Stephan Sunny, Joshua D'Cunha
 * Last Modified: 3rd June 2020
*/

`timescale 1ns / 100ps

module RiceOptimizer (
    input iClock,
    input iEnable,                  // enable to the comparator module
    input iReset,                   // reset for top-module and sub-modules
    
    input [15:0] iNSamples,         // # of residuals to be encoded
    input iValid,                   // iValid == HIGH => incoming residual is valid 
    input signed [15:0] iResidual,  // incoming residual
    
    output [3:0] oBest,             // optimum rice parameter
    output [31:0] oTot,             // total # of bits required to encode all residuals using <oBest>
    output oDone,                   // oDone == HIGH => received <iNSamples> residuals
    output oReady                   // oReady == HIGH => found the optimum rice parameter
    );

reg [15:0] sample_count; // counter to track # of samples received so far
wire re_rst;             // reset wire for all the rice encoder sub-modules
reg done;                // reg done <=> wire oDone
reg flag;                // flag == HIGH => We've received AT LEAST 1 valid residual
reg [4:0] count;         // counter to track latency from input to output
reg ready;               // reg ready <=> wire oReady

// Rice Encoder module for Rice Parameter = 0
wire [15:0] r0_bu;
wire r0_v;
RiceEncoder0 r0 (
    .iClock(iClock), 
    .iReset(re_rst), 
    .iValid(iValid), 
    .iSample(iResidual), 
    .oBitsUsed(r0_bu),
    .oValid(r0_v));

// Rice Encoder module for Rice Parameter = 1
wire [15:0] r1_bu;
wire r1_v;
RiceEncoder #(.rice_param(1)) r1 (
    .iClock(iClock), 
    .iReset(re_rst), 
    .iValid(iValid), 
    .iSample(iResidual), 
    .oBitsUsed(r1_bu),
    .oValid(r1_v));

// Rice Encoder module for Rice Parameter = 2
wire [15:0] r2_bu;
wire r2_v;
RiceEncoder #(.rice_param(2)) r2 (
    .iClock(iClock), 
    .iReset(re_rst), 
    .iValid(iValid), 
    .iSample(iResidual), 
    .oBitsUsed(r2_bu),
    .oValid(r2_v));

// Rice Encoder module for Rice Parameter = 3
wire [15:0] r3_bu;
wire r3_v;
RiceEncoder #(.rice_param(3)) r3 (
    .iClock(iClock), 
    .iReset(re_rst), 
    .iValid(iValid), 
    .iSample(iResidual), 
    .oBitsUsed(r3_bu),
    .oValid(r3_v));

// Rice Encoder module for Rice Parameter = 4
wire [15:0] r4_bu;
wire r4_v;
RiceEncoder #(.rice_param(4)) r4 (
    .iClock(iClock), 
    .iReset(re_rst), 
    .iValid(iValid), 
    .iSample(iResidual), 
    .oBitsUsed(r4_bu),
    .oValid(r4_v));

// Rice Encoder module for Rice Parameter = 5
wire [15:0] r5_bu;
wire r5_v;
RiceEncoder #(.rice_param(5)) r5 (
    .iClock(iClock), 
    .iReset(re_rst), 
    .iValid(iValid), 
    .iSample(iResidual), 
    .oBitsUsed(r5_bu),
    .oValid(r5_v));

// Rice Encoder module for Rice Parameter = 6
wire [15:0] r6_bu;
wire r6_v;
RiceEncoder #(.rice_param(6)) r6 (
    .iClock(iClock), 
    .iReset(re_rst), 
    .iValid(iValid), 
    .iSample(iResidual), 
    .oBitsUsed(r6_bu),
    .oValid(r6_v));

// Rice Encoder module for Rice Parameter = 7
wire [15:0] r7_bu;
wire r7_v;
RiceEncoder #(.rice_param(7)) r7 (
    .iClock(iClock), 
    .iReset(re_rst), 
    .iValid(iValid), 
    .iSample(iResidual), 
    .oBitsUsed(r7_bu),
    .oValid(r7_v));

// Rice Encoder module for Rice Parameter = 8
wire [15:0] r8_bu;
wire r8_v;
RiceEncoder #(.rice_param(8)) r8 (
    .iClock(iClock), 
    .iReset(re_rst), 
    .iValid(iValid), 
    .iSample(iResidual), 
    .oBitsUsed(r8_bu),
    .oValid(r8_v));

// Rice Encoder module for Rice Parameter = 9
wire [15:0] r9_bu;
wire r9_v;
RiceEncoder #(.rice_param(9)) r9 (
    .iClock(iClock), 
    .iReset(re_rst), 
    .iValid(iValid), 
    .iSample(iResidual), 
    .oBitsUsed(r9_bu),
    .oValid(r9_v));

// Rice Encoder module for Rice Parameter = 10
wire [15:0] r10_bu;
wire r10_v;
RiceEncoder #(.rice_param(10)) r10 (
    .iClock(iClock), 
    .iReset(re_rst), 
    .iValid(iValid), 
    .iSample(iResidual), 
    .oBitsUsed(r10_bu),
    .oValid(r10_v));

// Rice Encoder module for Rice Parameter = 11
wire [15:0] r11_bu;
wire r11_v;
RiceEncoder #(.rice_param(11)) r11 (
    .iClock(iClock), 
    .iReset(re_rst), 
    .iValid(iValid), 
    .iSample(iResidual), 
    .oBitsUsed(r11_bu),
    .oValid(r11_v));

// Rice Encoder module for Rice Parameter = 12
wire [15:0] r12_bu;
wire r12_v;
RiceEncoder #(.rice_param(12)) r12 (
    .iClock(iClock), 
    .iReset(re_rst), 
    .iValid(iValid), 
    .iSample(iResidual), 
    .oBitsUsed(r12_bu),
    .oValid(r12_v));

// Rice Encoder module for Rice Parameter = 13
wire [15:0] r13_bu;
wire r13_v;
RiceEncoder  #(.rice_param(13)) r13 (
    .iClock(iClock), 
    .iReset(re_rst), 
    .iValid(iValid), 
    .iSample(iResidual), 
    .oBitsUsed(r13_bu),
    .oValid(r13_v));

// Rice Encoder module for Rice Parameter = 14
wire [15:0] r14_bu;
wire r14_v;
RiceEncoder #(.rice_param(14)) r14 (
    .iClock(iClock), 
    .iReset(re_rst), 
    .iValid(iValid), 
    .iSample(iResidual), 
    .oBitsUsed(r14_bu),
    .oValid(r14_v));


// Running totals to store the total # of bits required to encode <iNSamples> residuals for each rice parameter
reg [31:0] r0_total;
reg [31:0] r1_total;
reg [31:0] r2_total;
reg [31:0] r3_total;
reg [31:0] r4_total;
reg [31:0] r5_total;
reg [31:0] r6_total;
reg [31:0] r7_total;
reg [31:0] r8_total;
reg [31:0] r9_total;
reg [31:0] r10_total;
reg [31:0] r11_total;
reg [31:0] r12_total;
reg [31:0] r13_total;
reg [31:0] r14_total;

wire [3:0] best; // optimum rice parameter calculated from Compare15 module [wire best <=> wire oBest]
wire [31:0] sum; // total # of bits required to encode all residuals using <best> [wire sum <=> wire oTot]

Compare15 c15 (
    .iClock(iClock),
    .iEnable(iEnable),
    
    .iIn0(r0_total),
    .iIn1(r1_total),
    .iIn2(r2_total),
    .iIn3(r3_total),
    .iIn4(r4_total),
    .iIn5(r5_total),
    .iIn6(r6_total),
    .iIn7(r7_total),
    .iIn8(r8_total),
    .iIn9(r9_total),
    .iIn10(r10_total),
    .iIn11(r11_total),
    .iIn12(r12_total),
    .iIn13(r13_total),
    .iIn14(r14_total),
    .oMinimum(best),
    .oSum(sum));

assign oReady = ready;
assign oDone = done;
assign oBest = best;
assign oTot = sum;
assign re_rst = iReset;

// The module stores iNSamples in a register in case iNSamples changes unexpectedly during operation
reg [15:0] iNSamplesReg; 

always @(posedge iClock or posedge iReset) begin
    if (iReset) begin
        r0_total  <= 0;
        r1_total  <= 0;
        r2_total  <= 0;
        r3_total  <= 0;
        r4_total  <= 0;
        r5_total  <= 0;
        r6_total  <= 0;
        r7_total  <= 0;
        r8_total  <= 0;
        r9_total  <= 0;
        r10_total <= 0;
        r11_total <= 0;
        r12_total <= 0;
        r13_total <= 0;
        r14_total <= 0;
        flag <= 0;
        done <= 0;
        count <= 0;
        ready <= 0;
        sample_count <= 0;
        iNSamplesReg <= iNSamples;
    end else begin
            
        // reset <flag> so <count> doesn't continue counting
        // reset <count> to 0 as well
        if (ready) begin
            count <= 0;
            flag <= 0;
        end
            
        // increment <count> only if we've received at least one valid residual
        if (flag) begin  
            count <= count + 1;
        end
            
        // after latency from input to output, our output signals are now valid so set ready == HIGH
        if (count == iNSamplesReg + 16'h0006 - 1) begin
            ready <= 1;
        end
        
        // only add to <sample_count> if we received a VALID residual    
        if (iValid) begin
            sample_count <= sample_count + 1;
            flag <= 1;
        end
        
        // only add the bits used to the running totals if they are VALID 
        if (r0_v) r0_total <= r0_total + r0_bu;
        if (r1_v) r1_total <= r1_total + r1_bu;
        if (r2_v) r2_total <= r2_total + r2_bu;
        if (r3_v) r3_total <= r3_total + r3_bu;
        if (r4_v) r4_total <= r4_total + r4_bu;
        if (r5_v) r5_total <= r5_total + r5_bu;
        if (r6_v) r6_total <= r6_total + r6_bu;
        if (r7_v) r7_total <= r7_total + r7_bu;
        if (r8_v) r8_total <= r8_total + r8_bu;
        if (r9_v) r9_total <= r9_total + r9_bu;
        if (r10_v) r10_total <= r10_total + r10_bu;
        if (r11_v) r11_total <= r11_total + r11_bu;
        if (r12_v) r12_total <= r12_total + r12_bu;
        if (r13_v) r13_total <= r13_total + r13_bu;
        if (r14_v) r14_total <= r14_total + r14_bu;
        
        // '-2' is to account for latency
        if (sample_count == (iNSamplesReg - 2)) begin
            done <= 1;
        end
        
        // reset done after it is set to HIGH
        if (done == 1) done <= 0;
    end
end


endmodule