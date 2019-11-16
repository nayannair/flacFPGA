function y = Frame(frame_number, num_samples_in_frame, subframes)


    bits = [];                       %  # Only the first 32 bits are fixed

        bits  = [bits,'11111111111110'];   % # Sync code
        bits    = [bits,'0']  ;                          % # Mandatory Value
        bits    = [bits,'0' ]  ;                          %# Fixed blocksize stream
        k='1100';
        if num_samples ~= BLOCK_SIZE
            k = '0111'   ;  %     # Num samples should be retrieved from a separate 16-bit field (custom_block_size_bits)
        end
            bits    = [bits,k ];             %# Num samples, hardcoded to 4096 samples per block. Per the spec, n = 12 ==> 1100. See below for exception.
        bits    = [bits,('1001') ] ;            %# Sample rate, hardcoded to 44.1 kHz
        bits    = [bits,('0001')]   ;           %# Channel assignment, hardcoded to independent stereo
        bits    = [bits,('100')]    ;           %# Sample size, hardcoded to 16 bits per sample
        bits    = [bits,'0' ]               ;             %# Mandatory Value
    
        frame_number_bits =   utf_8(frame_number);
        
        

            custom_block_size_bits = dec2bin(num_samples - 1, 16);
           %edit the crc part below 
             crc_input = [bits frame_number_bits custom_block_size_bits];
             crc_inp = crc_input-'0';
             crc_bytes = crc8(crc_inp);
        
        header= [crc_input crc_bytes];
        %ADD header
        
        num_padding_bits = 0;
        
        %ADD subframes
    
        if mod(length(subframes),8)
            num_padding_bits = 8 - mod(length(subframe_bits),8);
        end
        padding_bits = [];
        for i=1:num_padding_bits
            padding_bits = [padding_bits '0'];   % Allocate padding bits 
        %ADD padding_bits
        end                      % Set them all to zero
        
        crc_input = [header subframes padding_bits];
        crc_input = crc_input-'0';
        footer = crc16(crc_input); %Check what the <H struct.pack was being used for.
        
        y = [header subframes padding_bits footer];
end