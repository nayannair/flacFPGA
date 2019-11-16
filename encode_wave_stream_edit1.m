function y = encode_wave_stream_edit1(wave_stream)
frames = []; %Define a list of frames

    for sample_index= 1:BLOCK_SIZE:wave_stream.num_samples %Feed Block size, num_samples
        frame_number = floor((sample_index-1) / BLOCK_SIZE);
        %sample_index-1 is put here to convert MATLAB 1 to python 0
        subframes = []; %Define a list of subframes

        for chan_ind= 1:wave_stream.num_channels %Iterate over different channel
            
           %subframe_candidates.append(make_subframe_constant(channel, sample_index))
           %subframe_candidates.append(make_subframe_verbatim(channel, sample_index))
            for fixed_predictor_order = 1:MAX_FIXED_PREDICTOR_ORDER
                subframe_sizes = length(make_subframe_fixed(wave_stream.channel(chan_ind), sample_index-1, fixed_predictor_order));% Pass each channel into this
            end
             
            % subframe_candidates = filter(None, subframe_candidates) Use
            % this if any subframe candidate is returning null valu
            [~,smallest_subframe_ind] = min(subframe_sizes);
            smallest_subframe = make_subframe_fixed(chan_ind, sample_index-1, smallest_subframe_ind);
            subframes = [subframes smallest_subframe]; %Add to list of subframes
        end
        if (wave_stream.num_samples - sample_index-1) < BLOCK_SIZE 
            num_samples_in_frame = (wave_stream.num_samples - sample_index);
        else
            num_samples_in_frame = BLOCK_SIZE;
        end
        frame = Frame(frame_number, num_samples_in_frame, subframes);

        frames = [frames frame];
    end
    
    metadata_block_stream_info = MetadataBlockStreamInfo(wave_stream.num_samples, wave_stream.md5_digest);
    metadata_block_header = MetadataBlockHeader(True, BLOCK_TYPE_STREAMINFO, length(metadata_block_stream_info));
    metadata_block = MetadataBlock(metadata_block_header, metadata_block_stream_info);

    metadata_blocks = metadata_block;

    stream = ['fLaC' metadata_blocks frames];

    y = stream;
