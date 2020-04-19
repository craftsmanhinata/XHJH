
clc;
clear;
close all;





instance = 100;
symbol_length = 500;
M = 8;
x = randi([0, M-1], 1, symbol_length);
y = pskmod(x, M, 0); %就是符号的映射，无所谓行列值

snr_db = 20;


%y = awgn(y, snr_db, 'measured', 'db');
%scatter(real(y),imag(y),'.');
feature = compute_feature_of_modulation_signal(y)






