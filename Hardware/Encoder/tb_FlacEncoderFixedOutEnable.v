/**
 * File Name: FlacEncoderFixedOutEnable.v
 * Module Name: FlacEncoderFixedOutEnableTB
 * Type: Verilog file
 * Description: Testbench for FlacEncoderFixedOutEnable module
 * Author: Joshua D'Cunha
 * Last Modified: 29th May 2020
 * Note: Ensure that rice parameter and number of samples have been set appropriately before running simulation
*/

`timescale 1ns / 100ps

module FlacEncoderFixedOutEnableTB;

reg iClock;
wire lpcClock;
wire vreClock;
reg iReset;
reg [15:0] numSamples;

reg signed [15:0] iSample;
reg [15:0] iAddressStart;
wire [15:0] iAddress;

reg [15:0] oAddressStart;
wire [15:0] oAddress;
wire [15:0] oMemoryVal;

wire [15:0] oMSB;
wire [15:0] oLSB;
wire signed [15:0] oData;

wire oValid;
wire doneReading;
wire doneWriting;
wire doneUnary;
wire doneRiceParam;
wire done;

wire [1:0] state;
wire [15:0] warmupCount;
wire [15:0] sampleCount;
wire [15:0] samplesRead;

wire [15:0] dataSize;
wire [15:0] dataWrite;
wire [4:0] freeMemSpace;
wire [1:0] storeState;

FlacEncoderFixedOutEnable DUT (
                        .iClock(iClock),
                        .lpcClock(lpcClock),
                        .vreClock(vreClock),
                        .iReset(iReset),
                        .numSamples(numSamples),
                        
                        .iSample(iSample),
                        .iAddressStart(iAddressStart),
                        .iAddress(iAddress),
                        
                        .oAddressStart(oAddressStart),
                        .oAddress(oAddress),
                        .oMemory(oMemoryVal),
                        
                        .oMSB(oMSB),
                        .oLSB(oLSB),
                        .oData(oData),
                        
                        .oValid(oValid),
                        .doneReading(doneReading),
                        .doneWriting(doneWriting),
                        .doneUnary(doneUnary),
                        .doneRiceParam(doneRiceParam),
                        .done(done),
                        
                        .state(state),
                        .warmupCount(warmupCount),
                        .sampleCount(sampleCount),
                        .samplesRead(samplesRead),
                        
                        .dataSize(dataSize),
                        .dataWrite(dataWrite),
                        .freeMemSpace(freeMemSpace),
                        .storeState(storeState)
                     );

reg signed [15:0] iMemory [0:35];
reg signed [15:0] oMemory [0:99];
integer i;
// Output file to write bitstream for a given rice parameter from 1 to given number of samples
integer file;
// Register for displaying output from memory block to Tcl console  
reg [15:0] oAddressDisplay;

always begin
    #0 iClock = 0;
    #125 iClock = 1;
    #125 iClock = 0;
end

initial begin

//    iMemory[0] = 20;
//    iMemory[1] = 10;
//    iMemory[2] = -7;
//    iMemory[3] = -4;
//    iMemory[4] = 8;
//    iMemory[5] = 0;
//    iMemory[6] = 2;
//    iMemory[7] = -3;
//    iMemory[8] = 1;

//    iMemory[0] = 1;
//    iMemory[1] = 1;
//    iMemory[2] = 2;
//    iMemory[3] = 2;
//    iMemory[4] = 3;
//    iMemory[5] = 3;
//    iMemory[6] = 4;
//    iMemory[7] = 4;
//    iMemory[8] = 4;
//    iMemory[9] = 5;
//    iMemory[10] = 4;
//    iMemory[11] = 5;
//    iMemory[12] = 5;
//    iMemory[13] = 5;
//    iMemory[14] = 6;
//    iMemory[15] = 7;

    iMemory[0] = -715;
    iMemory[1] = -715;
    iMemory[2] = -721;
    iMemory[3] = -718;
    iMemory[4] = -721;
    iMemory[5] = -721;
    iMemory[6] = -721;
    iMemory[7] = -720;
    iMemory[8] = -731;
    iMemory[9] = -736;
    iMemory[10] = -725;
    iMemory[11] = -715;
    iMemory[12] = -706;
    iMemory[13] = -708;
    iMemory[14] = -701;
    iMemory[15] = -704;
    iMemory[16] = -706;
    iMemory[17] = -703;
    iMemory[18] = -713;
    iMemory[19] = -720;
    iMemory[20] = -729;
    iMemory[21] = -724;
    iMemory[22] = -726;
    iMemory[23] = -723;
    iMemory[24] = -730;
    iMemory[25] = -737;
    iMemory[26] = -746;
    iMemory[27] = -760;
    iMemory[28] = -759;
    iMemory[29] = -754;
    iMemory[30] = -759;
    iMemory[31] = -754;
    iMemory[32] = -749;
    iMemory[33] = -757;
    iMemory[34] = -756;
    iMemory[35] = -746;
    
    for (i = 0; i < 100; i = i + 1) begin // reset output memory initially
        oMemory[i] = 0;
    end
    
    /* UNCOMMENT BLOCK FOR TESTING MULTIPLE NUMBER OF SAMPLES AND GIVEN RICE PARAMETER */
    // -------------------------------START----------------------------------------- 
    file = $fopen("D:\\Documents\\output-15.txt", "w"); // CHANGE THIS TO A SUITABLE FILE NAME
    numSamples = 1;
    while (numSamples <= 36) begin
        oAddressDisplay = 0; //make sure oAddressDisplay == oAddressStart!    
        iAddressStart = 0; oAddressStart = 0;
        iReset = 1;
        #250 iReset = 0;
        // Go to Flow Navigator > Simulation > Simulation Settings > [Tab] Simulation 
        // Set xsim.simulation.runtime* to '-all' to make this while loop run all the way
        while (done != 1'b1) begin
            #250;
        end
        while (oAddressDisplay <= oAddress) begin
            $fwrite(file, "%h", oMemory[oAddressDisplay]);
            oAddressDisplay = oAddressDisplay + 16'h0001;
        end
        $fwrite(file, "\n");
        numSamples = numSamples + 16'h0001;
    end
    $fclose(file);
    // --------------------------END------------------------------------------------
    
    /* UNCOMMENT BLOCK FOR TESTING A PARTICULAR NUMBER OF SAMPLES AND GIVEN RICE PARAMAETER
    // ------------------------------START--------------------------------------
    //make sure oAddressDisplay == oAddressStart!
    oAddressDisplay = 0; iAddressStart = 0; oAddressStart = 0; iReset = 1; numSamples = 5;
    #250 iReset = 0;
    
    // Go to Flow Navigator > Simulation > Simulation Settings > [Tab] Simulation 
    // Set xsim.simulation.runtime* to '-all' to make this while loop run all the way
    while (done != 1'b1) begin
        #250;
    end
    
    $write("\n");
    while (oAddressDisplay <= oAddress) begin
        $write("%h", oMemory[oAddressDisplay]);
        oAddressDisplay = oAddressDisplay + 16'h0001;
    end
    $write("\n");
    */
    // -----------------------------END----------------------------------------------
    
    $finish;
end

// interpret this as preparing the input sample for next posedge of iClock
always @(negedge iClock) begin 
    iSample <= iMemory[iAddress];
end

// interpret this as writing the output generated from previous posedge of iClock
always @(negedge iClock) begin 
    oMemory[oAddress] <= oMemoryVal;
end

endmodule