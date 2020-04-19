load ofdmRx_data.mat
y = ofdmRx_data;
nv = sqrt(sum(abs(y).^2)./symbol_length);
y = y./nv;
feature = compute_feature_of_modulation_signal(y)