function [j,orig,pred] = write_flac(input,pred)
   % res = [];
    Fs = 44100;
    [flac_encoded,orig,pred] = encode_wave_stream_edit1(input,pred);
   % flac_encoded = flac_encoded - '0'
    %flac_encoded = flac_encoded(1:end-16);
    out = [];
    %for i=1:16:length(flac_encoded)-16
    %    y = bi2de(flac_encoded(i:i+15));
    %    out = [out, y];
    %end
        %flac_encoded = typecast( uint8(bin2dec( char(flac_encoded + '0') )), 'uint16'); 

   % audiowrite('output_new1.flac',flac_encoded,Fs);
  % k = fopen('output_1.txt','w');
   %j = fprintf(k,'%c' ,flac_encoded);
  %  k = fopen('output_2.flac','w');
    j=[];

 for i = 1:8:length(flac_encoded)-7
 %u= bin2dec(flac_encoded(1,i:i+7));
 %isNegative = uint8(bitget(u,8));
 %convertedValue = uint8(bitset(u,8,0)) + (-2^7)*isNegative;
  j =[j,bin2dec(flac_encoded(1,i:i+7))];
 end
% j=j./256;
 id2 = fopen('output_new7.txt','w');
 for i = 1 : length(j)
    fprintf(id2,'%c',j(i));
 end   
%audiowrite('output_new6.flac',j,Fs);
end
