function crc_8 = crc8(input)

trail_zeros = zeros(1,8);
crc_input = [input trail_zeros];
crc_output = zeros(1,8);

for i=1:length(crc_input)
   data = crc_input(i);
   fb = crc_output(1);
   crc_output(1) = crc_output(2);
   crc_output(2) = crc_output(3);
   crc_output(3) = crc_output(4);
   crc_output(4) = crc_output(5);
   crc_output(5) = crc_output(6);
   crc_output(6) = bitxor(crc_output(7),fb);
   crc_output(7) = bitxor(crc_output(8),fb);
   crc_output(8) = bitxor(data,fb);
end

crc_8 = [input crc_output];
end
