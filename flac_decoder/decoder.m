meta_length = j(1,counter:counter+23);
     counter = counter +24;
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     % Metadata Block Streaminfo

    % Metadata Block Streaminfo
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     min_block_size = j(1,counter:counter+15);
     counter = counter+16;
@@ -47,91 +48,118 @@
     counter = counter+36;
     md5 = j(1,counter:counter+127);
     counter = counter+128;

     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     %Frame
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

     counter=counter+32;
        %to skip utf8 bits
         temp= j(1,counter:counter+7);
         temp1 =bin2dec(temp);
         var = bin2dec('11111111') %0xFF
            while (temp1>=bin2dec('11000000'))
                counter = counter+8;
                temp1 = bitand(bitsll(1,temp1),var);
            end
      counter = counter +8;% skip 8 crc bits
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     %subframe
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    counter = counter+8;% 6 bits are for switching subframe type
    result = j(1,counter:counter+63);% 64 = 16 * 4 
    counter = counter + 64;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %rice decode
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    residual_signal = [];
    counter = counter +2;% residual coding method
    counter = counter +4;%partition order
    parameter = j(1,counter:counter+4);%5 bits for rice parameter
    num_samples_part = 4092;
    high_order_bits =0;
    low_order_bits =0;
        while num_samples_part >0
            num_samples_part= num_samples_part-1;
            while j(1,counter) == 0
                counter = counter +1;
                high_order_bits =high_order_bits+1; 
            end    
                high_order_bits = dec2bin(high_order_bits);
                counter = counter +1;
                low_order_bits =j(1,counter:counter+parameter -1);
                low_order_bits= num2str(low_order_bits);
                low_order_bits(isspace(low_order_bits)) = '';
                sample_bits = [high_order_bits low_order_bits];
                mapped_sample = bin2dec(sample_bits);

                if(rem(mapped_sample,2)==0)
                    sample = mapped_sample/2;
                else 
                    sample = -((mapped_sample+1)/2);

                end
                residual_signal = [residual_signal sample];
        end

 end


   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Fixed LPC Decoder

   %signal = [3 7 8 5 4 9 16 23 2 8 5 6 5 7 7 1]; 
   fixedArrCoeff = [4 -6 4 -1];                    % fixed order 4 co-efficients
   orig_samp = [3 7 8 5];
   %residual = [7 -2 -8 2 -26 83 -91 49 -19 11 -10 1]; 
     unencoded_stream = [];

 while 1

        counter=counter+32;
           %to skip utf8 bits
            temp= j(1,counter:counter+7);
            temp1 =bin2dec(temp);
            var = bin2dec('11111111') %0xFF
               while (temp1>=bin2dec('11000000'))
                   counter = counter+8;
                   temp1 = bitand(bitsll(1,temp1),var);
               end
         counter = counter +8;% skip 8 crc bits
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %subframe
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       counter = counter+8;% 6 bits are for switching subframe type

       orig_samp = j(1,counter:counter+63);% 64 = 16 * 4 
       orig_samp1 = orig_samp(1:16);
       orig_samp1 = num2str(orig_samp1);
       orig_samp1(isspace(orig_samp1)) = '';
       orig_samp1 = bin2dec(orig_samp1);
       orig_samp2 = orig_samp(17:32);
       orig_samp2 = num2str(orig_samp2);
       orig_samp2(isspace(orig_samp2)) = '';
       orig_samp2 = bin2dec(orig_samp2);
       orig_samp3 = orig_samp(33:48);
       orig_samp3 = num2str(orig_samp3);
       orig_samp3(isspace(orig_samp3)) = '';
       orig_samp3 = bin2dec(orig_samp3);
       orig_samp4 = orig_samp(49:64);
       orig_samp4 = num2str(orig_samp4);
       orig_samp4(isspace(orig_samp4)) = '';
       orig_samp4 = bin2dec(orig_samp4);
       orig_samp = [orig_samp1 orig_samp2 orig_samp3 orig_samp4];

       counter = counter + 64;
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       %rice decode
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       residual_signal = [];
       counter = counter +2;% residual coding method
       counter = counter +4;%partition order
       parameter = j(1,counter:counter+4);%5 bits for rice parameter
       num_samples_part = 4092;
       high_order_bits =0;
       low_order_bits =0;
           while num_samples_part >0
               num_samples_part= num_samples_part-1;
               while j(1,counter) == 0
                   counter = counter +1;
                   high_order_bits =high_order_bits+1; 
               end    
                   high_order_bits = dec2bin(high_order_bits);
                   counter = counter +1;
                   low_order_bits =j(1,counter:counter+parameter -1);
                   low_order_bits= num2str(low_order_bits);
                   low_order_bits(isspace(low_order_bits)) = '';
                   sample_bits = [high_order_bits low_order_bits];
                   mapped_sample = bin2dec(sample_bits);
                   counter = counter +parameter;

   order = 4;    % lpc order  
   length = 4096;  % frame size
   k = 1;
                   if(rem(mapped_sample,2)==0)
                       sample = mapped_sample/2;
                   else 
                       sample = -((mapped_sample+1)/2);

   for i = order+1:length
       disp(orig_samp);
       pred_samp = 0;
       for j = 1:1:4
           pred_samp = pred_samp + fixedArrCoeff(j)*orig_samp(4+k-j);
           %disp(pred_samp);
       end
       %disp(pred_samp);
       %disp(residual((i + 12) - 16));
       pred_samp = pred_samp + residual_signal((i + 4092) - 4096);
       orig_samp = [orig_samp , pred_samp]
       %disp(orig_samp);
       k = k + 1;
   end 

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


                   end
                   residual_signal = [residual_signal sample];
           end

    end


      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       %Fixed LPC Decoder

      %signal = [3 7 8 5 4 9 16 23 2 8 5 6 5 7 7 1]; 
      fixedArrCoeff = [4 -6 4 -1];                    % fixed order 4 co-efficients
      orig_samp = [3 7 8 5];
      %residual = [7 -2 -8 2 -26 83 -91 49 -19 11 -10 1]; 

      order = 4;    % lpc order  
      length = 4096;  % frame size
      k = 1;

      for i = order+1:length
          disp(orig_samp);
          pred_samp = 0;
          for j = 1:1:4
              pred_samp = pred_samp + fixedArrCoeff(j)*orig_samp(4+k-j);
              %disp(pred_samp);
          end
          %disp(pred_samp);
          %disp(residual((i + 12) - 16));
          pred_samp = pred_samp + residual_signal((i + 4092) - 4096);
          orig_samp = [orig_samp , pred_samp]
          %disp(orig_samp);
          k = k + 1;
      end 
      unencoded_stream = [unencoded_stream orig_samp];
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

      if(counter==length(j))
         break;
      end
end
   
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   sampledepth=16;
   numchannels =1;
   
   sampledatalen = total_samples * numchannels * (sampledepth / 8);%total samples is defined above in the code
   id2 = fopen('decoder_output.wav','w');
   orig_signal =[];
   orig_signal =  [orig_signal,'01010010' '01001001' '01000110' '01000110'] %RIFF 
   orig_signal =[orig_signal,uint32(sampledatalen+32)];
  orig_signal =  [orig_signal, '01010111' '01000001' '01010110' '01000101'];
  orig_signal =  [orig_signal,'01100110' '01101101' '01110100' ];
  orig_signal =  [orig_signal,uint32(16),uint16(0x0001),uint16(numchannels),uint32(samplerate) ,uint32(samplerate * numchannels * (sampledepth/8)) ,uint16(numchannels * (sampledepth / 8)),uint16( sampledepth)];
  orig_signal =  [orig_signal,'01100100' '01100001' '01110100' '01100001' ];
  orig_signal =  [orig_signal,uint32(sampledatalen)];
  fprintf(id2,,orig_signal);
   
   
   
 %min_blk_size = input_data(1,1:4)
end
