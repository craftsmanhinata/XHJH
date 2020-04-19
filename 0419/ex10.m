% 探索基于奇数阶累积量的OFDM信号调制识别。--多径
% 单载波信号经过多径瑞利衰落信道以后，其信号包络服从非对称概率密度分布。
% 由文献[1]，对于大于2 阶的奇数阶累积量，如果随机过程服从对称概率密度分布，那么它的奇数阶累积量趋于零
% 由文献[1]，服从非对称概率密度分布的随机信号奇数阶累积量为非零值，而 OFDM信号经过低信噪比﹑多径瑞利衰落信道后，其大于二阶的累积量值仍趋于 0。
% [1] 王永娟,2009,基于高阶累积量的OFDM信号调制识别技术研究
% 这里用三阶累积量做实验。
clc;clear;close all;

n = 1000;
C30_ofdm = zeros(1,n);
C31_ofdm = zeros(1,n);
SNR = 15;

for i = 1:n
    y = genOFDMSignal(SNR);
    
    y = y-mean(y);%确保零均值
    %功率归一化
    nv = sqrt(sum(abs(y).^2)./length(y));
    y = y./nv;
    
    %计算三阶累积量C30,C31
    C30_ofdm(i) = cum3x(conj(y),y,y,0,128,0,'biased',0);
    C31_ofdm(i) = cum3x(y,y,y,0,128,0,'biased',0);

end
figure;
subplot(211);plot(C30_ofdm);grid on;
subplot(212);plot(C31_ofdm);grid on;

disp(['C30_ofdm: ',num2str(mean(C30_ofdm))]);
disp(['C31_ofdm: ',num2str(mean(C31_ofdm))]);

% RESULT:
% C30_ofdm: -0.034575
% C31_ofdm: -0.034575
% 得到了预期的C31的值很小的结论