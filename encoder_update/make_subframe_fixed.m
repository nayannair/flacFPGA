function [y,pred] = make_subframe_fixed(channel, sample_index, predictor_order, num_samples)
BLOCK_SIZE      = 4096;
    
    if (num_samples - sample_index) < BLOCK_SIZE-1 
            signal = channel(sample_index : end);
    else
            signal = channel(sample_index : sample_index + BLOCK_SIZE-1);
    end
    
    warmup_samples = channel(sample_index : sample_index + predictor_order-1);
    
    if (length(signal) <= predictor_order) || (length(warmup_samples) < predictor_order) %Maybe a better approach for encoding the last sample
        y = 0;%replace none with valid value
    else
        
        [residual_signal,pred] = fixed_lpc(signal, predictor_order);% Change this to fixed LPC function
        partition_order = 0;% # TODO: We don't yet support partitioning
        
        %parameter = rice_parameter(residual_signal);
        %rice_partitions = Rice2Partition(parameter, residual_signal);%syntax not proper
        %partitioned_rice = PartitionedRice(partition_order, rice_partitions);
        RESIDUAL_CODING_METHOD_PARTITIONED_RICE2 = '01';
        partitioned_rice = Rice_Encoder(residual_signal); %Returns the paramter along with encoded residuals
        partitioned_rice = ['0000' partitioned_rice]; %'0000' is the order of the partition
        residual = [RESIDUAL_CODING_METHOD_PARTITIONED_RICE2 partitioned_rice];

        y= SubframeFixed(predictor_order, warmup_samples, residual);
    end
    end