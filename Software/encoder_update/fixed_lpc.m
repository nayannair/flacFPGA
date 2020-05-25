function [residual,pred_samp] = fixed_lpc(signal, order)

fixedArrPred = [0 0 0 0; 1 0 0 0; 2 -1 0 0; 3 -3 1 0; 4 -6 4 -1];
pred_samp = [];

len_sig = length(signal);
residual = zeros(1, len_sig - order);

for ind = order+1:len_sig
    pred_sample = 0;
    for coeff = 1:1:order
        pred_sample = pred_sample + (fixedArrPred(order+1, coeff) * signal(ind - coeff));
    end
    res_sample = signal(ind) - pred_sample;
    residual(ind - order) = res_sample;
   % X = ['residual',ind,residual]
   % disp(residual);
   pred_samp = [pred_samp,pred_sample];
end

end    
    
