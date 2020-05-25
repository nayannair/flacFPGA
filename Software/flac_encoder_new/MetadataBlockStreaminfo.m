function y = MetadataBlockStreaminfo(num_samples, md5_digest)  
BLOCK_SIZE      = 4096;  %# Num samples per block
SAMPLE_RATE     = 44100; %# Hz
SAMPLE_SIZE     = 16    ;%# Num bits per sample
NUM_CHANNELS    = 1;

MAX_FIXED_PREDICTOR_ORDER = 4;

        bits = [];

        bits      = [bits,dec2bin(BLOCK_SIZE, 16)];        % Min block size in samples
        bits     = [bits,dec2bin(BLOCK_SIZE, 16)] ;        % Max block size in samples
        bits     = [bits,dec2bin(0,24)]                                  ;       % TODO: Min frame size in bytes
        bits     = [bits,dec2bin(0,24)]                                   ;      % TODO: Max frame size in bytes
        bits    = [bits,dec2bin(SAMPLE_RATE, 20)]   ;     % Sample rate in Hz
        bits   = [bits,dec2bin(NUM_CHANNELS - 1, 3)];    % (Num channels) - 1
        bits   = [bits,dec2bin(SAMPLE_SIZE - 1, 5)];     % (Sample size) - 1 in bits per sample
        bits   = [bits,dec2bin(num_samples, 36)];   % Total num samples
        bits =[bits, md5_digest]  ; %size = 128 bits 
        y = bits;
end
