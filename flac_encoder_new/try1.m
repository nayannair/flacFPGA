function y = try1()
a= '0110011001100110';
 k = fopen('output_2.txt','w');
 for i = 1:8:length(a)-7
  fprintf(k,'%s' ,bin2dec(a(1,i:i+7)));
 end
end