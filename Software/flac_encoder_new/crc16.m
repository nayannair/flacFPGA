function crc_16 = crc16(input)

trail_zeros = zeros(1,16);
crc_input = [input trail_zeros];
%crc_input = input;
crc_output = zeros(1,16);

for i=1:length(crc_input)
   data = crc_input(i);
   
   fb = crc_output(1);
   
   crc_output(1) = bitxor(fb,crc_output(2));
   crc_output(2) = crc_output(3);
   crc_output(3) = crc_output(4);
   crc_output(4) = crc_output(5); 
   crc_output(5) = crc_output(6); 
   crc_output(6) = crc_output(7);
   crc_output(7) = crc_output(8);
   crc_output(8) = crc_output(9);
   crc_output(9) = crc_output(10);
   crc_output(10) = crc_output(11);
   crc_output(11) = crc_output(12);
   crc_output(12) = crc_output(13);
   crc_output(13) = crc_output(14);
   crc_output(14) = bitxor(fb,crc_output(15));
   crc_output(15) = crc_output(16);
 
   crc_output(16) = bitxor(fb,data);
   
   
end

crc_16 = crc_output;
%crc_16 = crc_output;
end
