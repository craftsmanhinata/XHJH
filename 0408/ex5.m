
clc;
clear;
close all;

instance = 100;
symbol_length = 500;
feature = zeros(instance,5);

for i = 1:instance
    M = 4;
    x = randi([0, M-1], 1, symbol_length);
    y = pammod(x, M);
    %考虑单位能量的限制
    nv = sqrt(sum(abs(y).^2)./symbol_length);
    y = y./nv;


    %y = awgn(y, snr_db, 'measured', 'db');
    %scatter(real(y),imag(y),'.');
    feature(i,:) = compute_feature_of_modulation_signal(y);
end
mean(feature)


