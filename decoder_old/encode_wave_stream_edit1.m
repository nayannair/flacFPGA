function y = encode_wave_stream_edit1(input)
frames = []; %Define a list of frames
BLOCK_SIZE      = 4096;  %# Num samples per block
SAMPLE_RATE     = 44100; %# Hz
SAMPLE_SIZE     = 16    ;%# Num bits per sample
NUM_CHANNELS    = 2;
MAX_FIXED_PREDICTOR_ORDER=4;

    [raw,Fs] = audioread(input,'native');
    x1 = typecast(int16(raw(:,1)),'uint16');
    x2 = typecast(int16(raw(:,2)),'uint16');
    y = [x1 x2];
    
    
    sample_size = SAMPLE_SIZE ; %input_file.getsampwidth() * 8          %   # Convert bytes per sample into bits per sample
    sample_rate = SAMPLE_RATE ;%input_file.getframerate()               %  # In Hz
    num_channels = NUM_CHANNELS;%input_file.getnchannels()
    num_samples = length(y);%input_file.getnframes()
   % num_interleaved_samples = num_channels * num_samples;
      % md5_digest = md5(input);
      md5_digest = '11110000111111111010010011001000100001010011011111101000110101001100111111111111010101011110101010101101100001010001100100100111';
       
    for sample_index= 1:BLOCK_SIZE:num_samples %Feed Block size, num_samples
        frame_number = floor((sample_index) / BLOCK_SIZE);
        %sample_index-1 is put here to convert MATLAB 1 to python 0
        subframes = []; %Define a list of subframes

        for chan_ind= 1:num_channels %Iterate over different channel
            
           %subframe_candidates.append(make_subframe_constant(channel, sample_index))
           %subframe_candidates.append(make_subframe_verbatim(channel, sample_index))
            for fixed_predictor_order = 1:MAX_FIXED_PREDICTOR_ORDER
                subframe_sizes = length(make_subframe_fixed(y(:,chan_ind), sample_index, fixed_predictor_order));% Pass each channel into this
            end
             
            % subframe_candidates = filter(None, subframe_candidates) Use
            % this if any subframe candidate is returning null valu
            [~,smallest_subframe_ind] = min(subframe_sizes);
            
            smallest_subframe = make_subframe_fixed(y(:,chan_ind), sample_index, smallest_subframe_ind);
            subframes = [subframes smallest_subframe]; %Add to list of subframes
        end
        if (num_samples - sample_index) < BLOCK_SIZE 
            num_samples_in_frame = (num_samples - sample_index);
        else
            num_samples_in_frame = BLOCK_SIZE;
        end
        frame = Frame(frame_number, num_samples_in_frame, subframes);

        frames = [frames frame];
    end
    
    metadata_block_stream_info = MetadataBlockStreamInfo(num_samples, md5_digest);
    BLOCK_TYPE_STREAMINFO =0;
    metadata_block_header = MetadataBlockHeader( BLOCK_TYPE_STREAMINFO, length(metadata_block_stream_info));
    metadata_block = MetadataBlock(metadata_block_header, metadata_block_stream_info);

    metadata_blocks = metadata_block;

    stream = ['01100110' '01001100' '01100001' '01000011'  metadata_blocks frames];

    y = stream;
end
