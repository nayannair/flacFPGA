function out = auto_corr(in, len, shift)

%check is shift is valid
%if shift >= len
%    disp('Invalid shift. Must be lesser than length of signal');
%else
    %initialise out [autocorr(shift)]
    out = 0;
    %start multiplying signal values only from 'shift' index
    for i = shift:1:len-1
        % '+1' to account for MATLAB indexing
        out = out + in(i + 1) * in(i - shift + 1);
    end
%end


