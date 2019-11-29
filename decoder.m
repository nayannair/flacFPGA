function [y,j] = decoder(input_flac)
 id = fopen(input_flac,'r');
 input_data=[];
 input_data= fscanf(id,'%s');

 k = dec2bin(input_data,8);
 k = k(:,7:end);
 j=[];
 counter =1;
 for i=1:length(k)
    j = [j k(i,:)];
 end
 
 if(~(strcmp(j(1,1:32),'01100110010011000110000101000011')))
   return;
 else
     % Metadata Block Header
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     counter = 33;
     if( j(1,counter) ~= '1') %Checking for last metadata block
        return
     end
     counter = counter + 1;
     if( j(1,counter:counter+6) ~= '0000000') %Checking for metadatablock type
         return
     end
     counter =counter + 7;
     meta_length = j(1,counter:counter+23);
     counter = counter +24;
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     % Metadata Block Streaminfo
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     min_block_size = j(1,counter:counter+15);
     counter = counter+16;
     max_block_size = j(1,counter:counter+15);
     counter = counter+16;
     min_frame_size = '000000000000000000000000'; %Framze size given zero in input file
     max_frame_size = '000000000000000000000000';
     counter = counter +48;
     sample_rate = j(1,counter:counter+19);
     counter = counter+20;
     num_channels = j(1,counter:counter+2);
     counter = counter+3;
     bits_per_sample = j(1,counter:counter+4);
     counter = counter+5;
     total_samples = j(1,counter:counter+35);
     counter = counter+36;
     md5 = j(1,counter:counter+127);
     counter = counter+128;
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 end
 
 %min_blk_size = input_data(1,1:4)
end