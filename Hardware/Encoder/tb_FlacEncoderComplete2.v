/**
 * File Name: tb_FlacEncoderComplete2.v
 * Module Name: FlacEncoderCompleteTB2
 * Type: Verilog file
 * Description: Testbench for FlacEncoderComplete module designed to read input samples from a text file
 * Author: Joshua D'Cunha
 * Last Modified: 2nd June 2020
 * Note: Ensure that rice parameter and number of samples have been set appropriately before running simulation
*/

`timescale 1ns / 100ps

module FlacEncoderCompleteTB2;

reg iClock;
//wire lpcClock;
//wire vreClock;
//wire roClock;
//wire rbClock;
reg iReset;
reg [15:0] numSamples;

reg signed [15:0] iSample;
reg [15:0] iAddressStart;
wire [15:0] iAddress;

reg [15:0] oAddressStart;
wire [15:0] oAddress;
wire [15:0] oMemoryVal;

//wire lpcOutValid;
//wire roOutReady;
//wire rbOutValid;

//wire [15:0] oMSB;
//wire [15:0] oLSB;
//wire signed [15:0] oData;
//wire [31:0] roOutTot;
//wire signed [15:0] validSampleCount;
//wire [3:0] riceParam;

//wire oValid;
//wire doneReading;
//wire doneWriting;
//wire doneUnary;
//wire doneRiceParam;
wire done;

//wire [1:0] state;
//wire [15:0] warmupCount;
//wire [15:0] sampleCount;
//wire [15:0] samplesRead;

//wire [15:0] dataSize;
//wire [15:0] dataWrite;
//wire [4:0] freeMemSpace;
//wire [1:0] storeState;

FlacEncoderComplete DUT (
                        .iClock(iClock),
//                        .lpcClock(lpcClock),
//                        .vreClock(vreClock),
//                        .roClock(roClock),
//                        .rbClock(rbClock),
                        .iReset(iReset),
                        .numSamples(numSamples),
                        
                        .iSample(iSample),
                        .iAddressStart(iAddressStart),
                        .iAddress(iAddress),
                        
                        .oAddressStart(oAddressStart),
                        .oAddress(oAddress),
                        .oMemory(oMemoryVal),
                        
//                        .lpcOutValid(lpcOutValid),
//                        .roOutReady(roOutReady),
//                        .rbOutValid(rbOutValid),
                        
//                        .oMSB(oMSB),
//                        .oLSB(oLSB),
//                        .oData(oData),
//                        .roOutTot(roOutTot),
//                        .validSampleCount(validSampleCount),
//                        .riceParam(riceParam),
                        
//                        .oValid(oValid),
//                        .doneReading(doneReading),
//                        .doneWriting(doneWriting),
//                        .doneUnary(doneUnary),
//                        .doneRiceParam(doneRiceParam),
                        .done(done)
                        
//                        .state(state),
//                        .warmupCount(warmupCount),
//                        .sampleCount(sampleCount),
//                        .samplesRead(samplesRead),
                        
//                        .dataSize(dataSize),
//                        .dataWrite(dataWrite),
//                        .freeMemSpace(freeMemSpace),
//                        .storeState(storeState)
                     );
                     
// Input file containing 16-bit signed PCM samples
integer file_in, scan_in;
// Register for displaying output from memory block to Tcl console  
reg [15:0] oAddressDisplay;
// Register for reading input from input file to encoder
reg [15:0] iAddressRead;

/* FOR DEBUGGING PURPOSES: Create an output memory block for module to write to and print contents on TCL console */
//integer i;
//reg signed [15:0] oMemory [0:99];

always begin
    #0 iClock = 0;
    #5 iClock = 1;
    #5 iClock = 0;
end

initial begin

/* FOR DEBUGGING PURPOSES: Create an output memory block for module to write to and print contents on TCL console */
//    for (i = 0; i < 100; i = i + 1) begin // reset output memory initially
//        oMemory[i] = 0;
//    end

    // ENSURE THIS IS A VALID FILE PATH!
    file_in = $fopen("D:\\Documents\\College\\Final Year\\Major Project\\8th Sem Work\\Test Sounds\\044i.txt", "r");
  
    //make sure oAddressDisplay == oAddressStart!
    oAddressDisplay = 0; iAddressRead = 16'hFFFF; 
    iAddressStart = 0; oAddressStart = 0;
    // For large # of samples, it may be useful to disable the waveform
    // Go to Flow Navigator > Simulation > Simulation Settings > [Tab] Elaboration
    // Set xsim.elaborate.debug_level from 'typical' to 'off'
    iReset = 1; numSamples = 60000; // ENSURE numSamples does not exceed number of samples in input text file!
    
    #10 iReset = 0;
    
    // Go to Flow Navigator > Simulation > Simulation Settings > [Tab] Simulation 
    // Set xsim.simulation.runtime* from '1500ns' to '-all' to make this while loop run all the way
    while (done != 1'b1) begin
        #10;
    end
    
/* FOR DEBUGGING PURPOSES: Create an output memory block for module to write to and print contents on TCL console */    
//    $write("\n");
//    while (oAddressDisplay <= oAddress) begin
//        $write("%h", oMemory[oAddressDisplay]);
//        oAddressDisplay = oAddressDisplay + 16'h0001;
//    end    
//    $write("\n");
    
    $finish;
end

// interpret this as preparing the input sample for next posedge of iClock
always @(negedge iClock) begin 
    if (iAddressRead != iAddress) begin
        scan_in = $fscanf(file_in, "%d\n", iSample);
        iAddressRead = iAddress;
    end
end

/* FOR DEBUGGING PURPOSES: Create an output memory block for module to write to and print contents on TCL console */
// interpret this as writing the output generated from previous posedge of iClock
//always @(negedge iClock) begin 
//    oMemory[oAddress] <= oMemoryVal;
//end

endmodule