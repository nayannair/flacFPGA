function y= SubframeFixed(predictor_order, warmup_samples, residual)
SAMPLE_SIZE =16;
header_bits=[];
header_bits = [header_bits,'0'];
header_bits = [header_bits,'001'];      % header_bits[2:4]      # SUBFRAME_FIXED
header_bits = [header_bits,dec2bin(predictor_order, 3)];    %header_bits[5:7]
header_bits = [header_bits '0'];                            %Wasted bits

       % warmup_sample_bits = bitarray()
 warmup_sample_bits = [];
        for i=1:length(warmup_samples)
                sample = warmup_samples(i);
            %warmup_sample_bits.extend(bitarray_from_signed(sample, SAMPLE_SIZE));
            %.extend is same as .append
                warmup_sample_bits = [warmup_sample_bits dec2bin(sample, SAMPLE_SIZE)];
        %check this again for + operator
        end
        data_bits = [warmup_sample_bits residual];
        %RESIDUAL class in python code
        %RESIDUAL_CODING_METHOD_PARTITIONED_RICE2
    %if coding_method == 0
     %   coding_method_bits = '00';
    %else
     %  coding_method_bits ='01';
    %end
    
    %y = coding_method_bits + partitioned_rice;% check this again for + operator
    
    y = [header_bits data_bits];
end
