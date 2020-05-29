/**
 * File Name: FlacEncoderFixedOutEnable.v
 * Module Name: FlacEncoderFixedOutEnable
 * Type: Verilog file
 * Description: Encoder that receives input samples, encodes them using a fixed rice parameter, and stores them in memory
 * Author: Joshua D'Cunha
 * Last Modified: 29th May 2020
*/

module FlacEncoderFixedOutEnable(
                        input wire iClock,
                        output wire lpcClock,
                        output wire vreClock,
                        input wire iReset,
                        input wire signed [15:0] numSamples, // signed because we'll be doing operations with this
                        
                        input wire signed [15:0] iSample,
                        input wire [15:0] iAddressStart,
                        output wire [15:0] iAddress,
                        
                        input wire [15:0] oAddressStart,
                        output wire [15:0] oAddress,
                        output wire [15:0] oMemory,
                        
                        output wire [15:0] oMSB,
                        output wire [15:0] oLSB,
                        output wire signed [15:0] oData,
                        
                        output wire oValid,
                        output reg doneReading,
                        output reg doneWriting,
                        output reg doneUnary,
                        output reg doneRiceParam,
                        output wire done,
                        
                        output reg [1:0] state,
                        output reg signed [15:0] warmupCount, // signed because we'll be doing operations with this
                        output reg signed [15:0] sampleCount, // signed because we'll be doing operations with this
                        output reg signed [15:0] samplesRead, // signed because we'll be doing operations with this
                        
                        output reg [15:0] dataSize,
                        output reg [15:0] dataWrite,
                        output reg [4:0] freeMemSpace,
                        output reg [1:0] storeState
                       );
                        
reg lpcReset; // ACTIVE HIGH reset trigger for the LPC encoder module
// ACTIVE HIGH flag to indicate if lpcInSample is valid 
// Must be held HIGH for a number of clock cycles equal to the number of residuals
reg lpcInValid; 
reg signed [15:0] lpcInSample; // Register to hold an incoming sample
wire signed [15:0] lpcResidual; // Residual generated by the 
wire lpcOutValid; // ACTIVE HIGH flag to indicate if lpcResidual is valid
//wire lpcClock;
// doneWriting is set HIGH during posedge of iClock so lpcClock will be stretched as HIGH as long as doneWriting is HIGH
assign lpcClock = doneWriting ? iClock : 1;            
FixedEncoderOrder4 lpc (
                        .iClock(lpcClock),
                        .iReset(lpcReset),
                        .iValid(lpcInValid),
                        .iSample(lpcInSample),
                        .oResidual(lpcResidual),
                        .oValid(lpcOutValid)
                       );
                       
reg vreReset; // ACTIVE HIGH reset trigger for the Rice encoder module
// ACTIVE HIGH flag to indicate if vreInSample is valid 
// Must be held HIGH for a number of clock cycles equal to the number of residuals
wire vreInValid;
assign vreInValid = lpcOutValid;
wire signed [15:0] vreInSample; // Note it is a wire because it is directly connected to output of LPC encoder
assign vreInSample = lpcResidual;
reg [3:0] RICE_PARAM;
// Wire assigned to the unary part of the encoded residual
// Note that it stores the NUMBER of zeros and not the zeros itself
wire signed [15:0] vreMSB;
// Wire assigned to the stop bit and binary part of the encoded residual
wire signed [15:0] vreLSB;
wire vreOutValid; // ACTIVE HIGH flag to indicate if oMSB & oLSB are valid
//wire vreClock;
// doneWriting is set HIGH during posedge of iClock so lpcClock will be stretched as HIGH as long as doneWriting is HIGH
assign vreClock = doneWriting ? iClock : 1;
VariableRiceEncoder vre (
                        .iClock(vreClock),
                        .iReset(vreReset),
                        .iValid(vreInValid),
                        .iSample(vreInSample),
                        .iRiceParam(RICE_PARAM),
                        .oMSB(vreMSB),
                        .oLSB(vreLSB),
                        .oValid(vreOutValid)
                       );

//reg [1:0] state;
//reg [1:0] storeState;
//reg [15:0] warmupCount;
//reg [15:0] sampleCount;
//reg [15:0] samplesRead;

// States of the encoder FSM
// WARM_UP: encoder receives and stores warmup samples
// ENC: encoder calculates residuals, rice encodes them and stores them
// FLUSH: this state is an intermediate state between ENC & DONE that is created 
// because of latency between receiving input samples and generating rice encoded residuals
parameter [1:0] WARM_UP  = 2'b00, ENC = 2'b01, FLUSH = 2'b10, DONE = 2'b11;

reg signed [15:0] BLK_SIZE; // stores the block size (default is 16 samples)
reg signed [15:0] LPC_ORDER; // stores the order of the fixed LPC encoder (default is 4)

reg signed [15:0] oDataReg; // register for oData; may either store a warm-up sample or a residual
assign oData = oDataReg;

reg [15:0] oMSBReg; // MSB is a misnomer, it stores the unary part of the rice encoded residual, if MSB is 5, it means 00000
// LSB is a misnomer, it stores the stop bit and the binary-encoded part of the rice encoded residual. 
// Note that the binary-encoded part is always <RICE_PARAM> bits so it does not get reduced to its smallest form
// Ex: if RICE_PARAM = 3 and binary part is '000', it will remain '000' and not '0'
reg [15:0] oLSBReg; 
assign oMSB = oMSBReg;
assign oLSB = oLSBReg;

reg [15:0] iAddressReg; // stores the address of the input sample in the input memory block
assign iAddress = iAddressReg;

reg oValidReg; // flag to indicate if the output (either oData or oMSB and oLSB) is valid
assign oValid = oValidReg;

// flag to exit the FLUSH state. Because there is a delay from receiving the input sample to residual generation, 
// FLUSH state waits for oValid to go from LOW to HIGH and waits further until it goes from HIGH to LOW before exiting the state
reg finishFlushing; 

reg signed [15:0] samplesInCompletedBlks; //stores the total number of samples in blocks that are COMPLETED
// below three variables are used to determine how long the lpcInValid signal should be valid for
// lpcInValid should be valid for a number of clock cycles equal to the number of residuals to be calculated
// If the number of residuals to calculate is greater than the block size, we set the number of residuals 
// == blkSizeCheck because afterwards a new block is created. Sometimes the number of residuals may be 
// less than the block size (and this number is given by numSamplesCheck) so we set it to this number
// instead. Note LPC_ORDER is subtracted in both cases because they are warm-up samples and not residuals
wire signed [15:0] blkSizeCheck = BLK_SIZE - LPC_ORDER + 1;
wire signed [15:0] numSamplesCheck = numSamples - samplesInCompletedBlks - LPC_ORDER + 1;
wire signed [15:0] validSampleCount = (blkSizeCheck < numSamplesCheck) ? blkSizeCheck : numSamplesCheck;

//reg doneReading; // indicates that encoder has reached DONE state (finished reading required input samples)

reg [15:0] oAddressReg; // stores the address of the output register to write to in the output memory block
assign oAddress = oAddressReg;

reg [15:0] oMemoryReg; // stores the content that will be written to the register addressed by oAddressReg 
assign oMemory = oMemoryReg; 

//reg [4:0] freeMemSpace; // stores the available space  in oMemoryReg
reg [4:0] oRegWidth; // stores the width of the output register (as # of bits)
reg [4:0] sampleWidth; // stores the size of the input samples (as # of bits)

//reg [15:0] dataSize; // stores the required # of bits to be stored to oMemory
//reg [15:0] dataWrite; // stores the # of bits written so far

//reg doneWriting; // indicates that writing to memory is done (for a particular warmup sample or rice-encoded residual)

//reg doneUnary; // indicates if unary part of rice-encoded residual is written to memory
//reg doneRiceParam; // indicates if rice parameter is written to memory (format <warm-up samples><rice param><rice-encoded residuals>)

// We're done only once we've finished reading required number of samples
// AND writing the encoded residual bitstream to memory
assign done = doneReading & doneWriting; 
                       
always @(posedge iClock or posedge iReset) begin
    if (iReset) begin
        BLK_SIZE <= 16;
        LPC_ORDER <= 4;
        state <= WARM_UP;
        // storeState is used to indicate if either a warm-up sample or rice-encoded residual is to be written
        // Hence we need to know only if encoder is or has been in WARM_UP or ENC state
        storeState <= WARM_UP;
        // notice below three counters are initialised to 1 because our first iSample is already calculated before this always block is run
        warmupCount <= 1;
        sampleCount <= 1;
        samplesRead <= 1;
        oDataReg <= 16'bz;
        oMSBReg <= 16'bz;
        oLSBReg <= 16'bz;
        iAddressReg <= iAddressStart; // iAddressStart is used because starting address may not always be zero
        vreReset <= 1;
        lpcReset <= 1;
        lpcInValid <= 0; 
        oValidReg <= 0;
        finishFlushing <= 0;
        RICE_PARAM <= 15;
        samplesInCompletedBlks <= 0;
        doneReading <= 0;
        doneWriting <= 1;
        oAddressReg <= oAddressStart; // oAddressStart is used because starting address may not always be zero
        freeMemSpace <= 16;
        oRegWidth <= 16;
        sampleWidth <= 16;
        oMemoryReg <= 0;
        dataSize <= 0;
        dataWrite <= 0;
        doneUnary <= 1;
        doneRiceParam <= 1;
    end else if (!doneWriting) begin // block to handle writing to memory
        if (dataWrite == dataSize) begin
            doneWriting <= 1;
        end else begin
            if (freeMemSpace == 0) begin // if we don't have available space in oMemoryReg, it means we need to write to a new address
                freeMemSpace <= oRegWidth;
                oAddressReg <= oAddressReg + 16'h0001;
            end else begin
                if (storeState == WARM_UP) begin
                    // ~(16'hFFFF >> (oRegWidth - freeMemSpace)) -> BIT-MASK to ensure we affect only <freeMemSpace> worth of bits
                    // oData << dataWrite -> done to ensure that we don't write parts of oData that have already been written
                    // >> (oRegWidth - freeMemSpace) -> done to ensure that the required part of oData to be written is 
                    //                                  shifted as leftmost as possible without overwriting existing data in oMemoryReg
                    oMemoryReg <= (oMemoryReg & ~(16'hFFFF >> (oRegWidth - freeMemSpace))) | ((oData << dataWrite) >> (oRegWidth - freeMemSpace));
                    // (dataSize - dataWrite) -> the required number of bits to be written
                    // If this is greater than available memory space we write as much as possible 
                    // to current address and invoke a fresh address from the above condition [if (freeMemSpace == 0)]
                    if ((dataSize - dataWrite) >= {11'b00000000000, freeMemSpace}) begin 
                        dataWrite <= dataWrite + {11'b00000000000, freeMemSpace};
                        freeMemSpace <= 0;
                    // Else we can write everything to current register and we update the available memory space accordingly
                    end else begin
                        freeMemSpace <= {11'b00000000000, freeMemSpace} - (dataSize - dataWrite);
                        dataWrite <= dataSize;
                    end
                end else begin
                    if (!doneRiceParam) begin // writing rice parameter to memory block
                        oMemoryReg <= (oMemoryReg & ~(16'hFFFF >> (oRegWidth - freeMemSpace))) | (({RICE_PARAM, 12'h000} << dataWrite) >> (oRegWidth - freeMemSpace));
                        // changed '>=' to '>' because we are actually done when we've finished what needs to be written
                        // (whose size is given by <size of Rice Param> - dataWrite) fits perfectly (hence ==)
                        // in the available memory space (whose size is given by freeMemSpace).
                        // However, we lose a clock cycle because doneRiceParam is not set. To avoid this, we make it
                        // strictly greater than instead of >=
                        if ((16'h0004 - dataWrite) > {11'b00000000000, freeMemSpace}) begin // changed >= to >
                            dataWrite <= dataWrite + {11'b00000000000, freeMemSpace};
                            freeMemSpace <= 0;
                        end else begin
                            freeMemSpace <= {11'b00000000000, freeMemSpace} - (16'h0004 - dataWrite);
                            dataWrite <= 16'h0000;
                            doneRiceParam <= 1;
                        end                    
                    end else if (!doneUnary) begin // writing unary part of rice-encoded residual to memory block
                        oMemoryReg <= (oMemoryReg & ~(16'hFFFF >> (oRegWidth - freeMemSpace)));
                        if ((oMSB - dataWrite) > {11'b00000000000, freeMemSpace}) begin // changed >= to > for similar reasoning as above
                            dataWrite <= dataWrite + {11'b00000000000, freeMemSpace};
                            freeMemSpace <= 0;
                        end else begin
                            freeMemSpace <= {11'b00000000000, freeMemSpace} - (oMSB - dataWrite);
                            dataWrite <= 16'h0000;;
                            doneUnary <= 1;
                        end
                    end else begin // writing stop bit and binary part of rice-encoded residual to memory block
                        oMemoryReg <= (oMemoryReg & ~(16'hFFFF >> (oRegWidth - freeMemSpace))) | ((oLSB << (16'h0010 - ({12'h000, RICE_PARAM} + 16'h0001) + dataWrite)) >> (oRegWidth - freeMemSpace));
                        // changed '>=' to '>' for a similar reasoning except here since actually dataWrite is supposed to reach
                        // length <RICE_PARAM + 1> after which we set it to actual dataSize to set the condition (dataWrite == dataSize) true
                        // if we use == in >= dataWrite can reach the length <RICE_PARAM + 1> and be done but because it's not set to
                        // dataSize in the same clock cycle, we lose one more clock cycle AND since dataWrite != dataSize (but <RICE_PARAM + 1>)
                        // the freeMemSpace == 0 condition is True and another register is invoked (oAddressReg <= oAddressReg + 1) which is
                        // to be avoided because it's not required!
                        if ((({12'h000, RICE_PARAM} + 16'h0001) - dataWrite) > {11'b00000000000, freeMemSpace}) begin 
                            dataWrite <= dataWrite + {11'b00000000000, freeMemSpace};
                            freeMemSpace <= 0;
                        end else begin
                            freeMemSpace <= {11'b00000000000, freeMemSpace} - (({12'h000, RICE_PARAM} + 16'h0001) - dataWrite);
                            dataWrite <= dataSize;
                        end
                    end
                end
            end
        end
    end else begin
        storeState <= ((state == WARM_UP) || (state == ENC)) ? state : storeState;
        case (state)
            WARM_UP: begin
                vreReset <= 0;
                lpcReset <= 0;
                oMSBReg <= 16'bz;
                oLSBReg <= 16'bz;
                oDataReg <= iSample;
                oValidReg <= 1;
                doneWriting <= 0;
                dataWrite <= 0;
                dataSize <= {11'b00000000000, sampleWidth};
                if (samplesRead >= numSamples) begin
                    lpcInValid <= 0;
                    state <= DONE;
                end else begin
                    lpcInSample <= iSample;
                    if (warmupCount == LPC_ORDER) begin
                        doneRiceParam <= 0;
                        state <= ENC;
                    end else begin
                        warmupCount <= warmupCount + 1'b1;
                    end
                    if (sampleCount >= validSampleCount) begin // >= is used instead of == because validSampleCount may be negative (if LPC_ORDER > numSamples) 
                        lpcInValid <= 0;
                    end else begin
                        lpcInValid <= 1;
                    end
                    sampleCount <= sampleCount + 1'b1;
                    iAddressReg <= iAddressReg + 1'b1;
                    samplesRead <= samplesRead + 1'b1;
                end
            end
            ENC: begin
                lpcInSample <= iSample;
                if (samplesRead == numSamples) begin
                    state <= FLUSH;
                end else begin
                    if (sampleCount == BLK_SIZE) begin // if sampleCount reaches BLK_SIZE, we need to wait for encoded residuals to be calcuated before going to next block
                        samplesInCompletedBlks <= samplesInCompletedBlks + BLK_SIZE;
                        state <= FLUSH;
                    end else begin
                        if (sampleCount >= validSampleCount) begin // this is for hey, time to turn off lpcInValid so that you don't calculate more residuals than necessary
                            lpcInValid <= 0;
                        end
                        sampleCount <= sampleCount + 1'b1;
                        iAddressReg <= iAddressReg + 1'b1;
                        samplesRead <= samplesRead + 1'b1;
                    end
                end
                // The following code block in this state is in case BLK_SIZE is so large that the 
                // latency in encoded residual calculation is covered but we're still in ENC state
                if (lpcOutValid) begin
                    oDataReg <= lpcResidual;
                end else begin
                    oDataReg <= 16'bz;
                end
                if (vreOutValid) begin
                    oMSBReg <= vreMSB;
                    oLSBReg <= vreLSB;
                    oValidReg <= 1;
                    dataWrite <= 0;
                    dataSize <= vreMSB + {12'h000, RICE_PARAM} + 16'h0001;
                    doneUnary <= 0;
                    doneWriting <= 0;
                end else begin
                    oMSBReg <= 16'bz;
                    oLSBReg <= 16'bz;
                    oValidReg <= 0;
                end
            end
            FLUSH: begin
                if (lpcOutValid) begin
                    oDataReg <= lpcResidual;
                end else begin
                    oDataReg <= 16'bz;
                end
                if (vreOutValid) begin
                    oMSBReg <= vreMSB;
                    oLSBReg <= vreLSB;
                    oValidReg <= 1;
                    doneUnary <= 0;
                    doneWriting <= 0;
                    dataWrite <= 0;
                    dataSize <= vreMSB + {12'h000, RICE_PARAM} + 16'h0001;
                    finishFlushing <= 1;
                end else begin
                    oMSBReg <= 16'bz;
                    oLSBReg <= 16'bz;
                    oValidReg <= 0;
                    if (finishFlushing) begin // read comment on finishFlushing to understand the purpose of this if block
                        if (samplesRead == numSamples) begin
                            state <= DONE;
                        end else begin
                            warmupCount <= 1;
                            sampleCount <= 1;
                            samplesRead <= samplesRead + 1'b1;
                            iAddressReg <= iAddressReg + 1'b1;
                            vreReset <= 1;
                            lpcReset <= 1;
                            state <= WARM_UP;
                        end
                        finishFlushing <= 0;
                    end
                end                                
            end
            DONE: begin
                // below four assignments are done if the encoder finishes encoding in WARM_UP state
                // oValidReg and oDataReg are not set to 0 and Z respectively
                // oMSBReg and oLSBReg are assigned Z here redundantly
                oValidReg <= 0;
                oMSBReg <= 16'bz;
                oLSBReg <= 16'bz;
                oDataReg <= 16'bz;
                doneReading <= 1;
            end
        endcase
    end
end

endmodule