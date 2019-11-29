function utf_8_enc = utf_8(input)

if( input < 2^7)
    utf_8_enc = dec2bin(input,8);
elseif(input <2^11)
    temp = bitor(192,floor(bitsra(input,6)));
    bit1 = dec2bin(temp,8);
    temp = bitor(128,bitand(input,63));
    bit2 = dec2bin(temp,8);
    utf_8_enc = [bit1 bit2];
elseif(input <2^16)
    temp = bitor(224,bitsra(input,12));
    bit1 = dec2bin(temp,8);
    temp = bitor(128,bitand(floor(bitsra(input,6)),63));
    bit2 = dec2bin(temp,8);
    temp = bitor(128,bitand(input,63));
    bit3 = dec2bin(temp,8);
    utf_8_enc = [bit1 bit2 bit3];
elseif(input <2^21)
    temp = bitor(240,bitsra(input,18));
    bit1 = dec2bin(temp,8);
    temp = bitor(128,bitand(63,floor(bitsra(input,12))));
    bit2 = dec2bin(temp,8);
    temp = bitor(128,bitand(63,floor(bitsra(input,6))));
    bit3 = dec2bin(temp,8);
    temp = bitor(128,bitand(63,input));
    bit4 = dec2bin(temp,8);
    utf_8_enc = [bit1 bit2 bit3 bit4];
elseif(input <2^26)
    temp = bitor(240,bitsra(input,24));
    bit1 = dec2bin(temp,8);
    temp = bitor(128,bitand(63,floor(bitsra(input,18))));
    bit2 = dec2bin(temp,8);
    temp = bitor(128,bitand(63,floor(bitsra(input,12))));
    bit3 = dec2bin(temp,8);
    temp = bitor(128,bitand(63,floor(bitsra(input,6))));
    bit4 = dec2bin(temp,8);
    temp = bitor(128,bitand(63,input));
    bit5 = dec2bin(temp,8);
    utf_8_enc = [bit1 bit2 bit3 bit4 bit5];
elseif(input <2^31)
    temp = bitor(240,bitsra(input,24));
    bit1 = dec2bin(temp,8);
    temp = bitor(128,bitand(63,floor(bitsra(input,18))));
    bit2 = dec2bin(temp,8);
    temp = bitor(128,bitand(63,floor(bitsra(input,12))));
    bit3 = dec2bin(temp,8);
    temp = bitor(128,bitand(63,floor(bitsra(input,6))));
    bit4 = dec2bin(temp,8);
    temp = bitor(128,bitand(63,input));
    bit5 = dec2bin(temp,8);
    utf_8_enc = [bit1 bit2 bit3 bit4 bit5];    
     
end



end