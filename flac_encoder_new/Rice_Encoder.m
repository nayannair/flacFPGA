function y = Rice_Encoder(residual_signal)
  %  def __init__(self, parameter, residual_signal):
   %     self.parameter = parameter
    %    self.residual_signal = residual_signal
    e_x = ceil(sum(abs(residual_signal)) / length(residual_signal));
    ln_2 = log(2);

  if e_x > 0.0 
      parameter=ceil(log2(ln_2 * e_x));
  else 
      parameter=0;
  end



% def get_bits(self):
%  assert self.parameter < 31 % # TODO: For now, we won't support the parameter escape code

%  parameter_bits = bitarray_from_int(self.parameter, 5)
         parameter_bits = dec2bin(parameter, 5);
         encoded_samples = [];

%for sample in self.residual_signal:
         for i=1:length(residual_signal)
            sample=residual_signal(i);
            if sample < 0
              mapped_sample = -2 * sample - 1;
            else
              mapped_sample =   2 * sample;
            end
            % Split the bits of the mapped sample into two halves: the
            % high-order bits and the low-order-bits
            mask = ( bitsll(1,parameter)) - 1;%bitsll left shifts the number->bitsll(number,left shift by amount)
            low_order_bits = bitand(mapped_sample, mask);%bitand is bitwise AND 
            high_order_bits = floor(bitsra(mapped_sample, parameter));%bitsll right shifts the number->bitsra(number,right shift by amount)

            low_order_bitarray = dec2bin(low_order_bits, parameter);%dec2bin converts decimal to binary->dec2bin(value,number of bits to be represented in)
            high_order_bitarray = [];
            for j=1:high_order_bits
                high_order_bitarray = [high_order_bitarray '0'];  %Allocate high_order_bits number of bits
            end            

           encoded_sample = [high_order_bitarray '1' low_order_bitarray];
           % encoded_samples.append(encoded_sample)
           
           encoded_samples = [encoded_samples,  encoded_sample];
         end
         y = [parameter_bits encoded_samples];
end
        
        
        
