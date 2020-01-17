function [coeffs, resid] = fir_lpc(block, order)

%initialize array of LPC coefficients
coeff_mat = zeros(order);

%generate autocorrelation values for signal block
auto_arr = zeros(1, order+1);
len_block = length(block);

for shift=0:order
    auto_arr(shift+1) = auto_corr(block, len_block, shift);
end

mmse_prev = auto_arr(1);

for j=1:order
    
    %calculate delta
    temp_delta = 0;
    
    for k=1:j-1
        temp_delta = temp_delta + (coeff_mat(j-1,k) * auto_arr(j-k+1));
    end
    
    delta = auto_arr(j+1) - temp_delta;
    
    %calculate gamma
    gamma = delta / mmse_prev;
    coeff_mat(j,j) = gamma;
    
    mmse_curr = mmse_prev * (1 - (gamma^2));
    
    for i=1:j-1
        coeff_mat(j,i) = coeff_mat(j-1,i) - (gamma * coeff_mat(j-1,j-i));
    end
    
    mmse_prev = mmse_curr;
  
end

coeffs = coeff_mat(order,:);
resid = zeros(1, len_block - order);
for ind = order+1:len_block
    pred_sample = 0;
    for coeff=1:order
        pred_sample = pred_sample + (coeffs(coeff) * block(ind-coeff));
    end
    res_sample = block(ind) - pred_sample;
    resid(ind - order) = res_sample;
end

    
    


