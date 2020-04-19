clc;clear;close all;

% [1] 王永娟,2009,基于高阶累积量的OFDM信号调制识别技术研究
% [2] 吕挺岑,2007,通信信号调制识别技术研究
% ===========================================================
% 针对OFDM信号相对于单载波信号对的识别
% 文献[1]中，3.2节介绍了基于偶数阶累积量的OFDM调制识别算法
% 基本思想是：由于OFDM信号的渐近高斯性，其四阶累积量为零。而单载波信号由于是非高斯的，其四阶累积量不为零。
% 下面针对这一个思想进行试验

n = 1000;
C40_ofdm = zeros(1,n);
C41_ofdm = zeros(1,n);
C42_ofdm = zeros(1,n);
SNR = 15;

for i = 1:n
    y = genOFDMSignal(SNR);
    
    y = y-mean(y);%确保零均值
    %功率归一化
    nv = sqrt(sum(abs(y).^2)./length(y));
    y = y./nv;
    %计算其四阶累积量C40,C41,C42
    C40_ofdm(i) = cum4x(y,y,y,y,0,128,0,'biased',0,0);
    C41_ofdm(i) = cum4x(y,y,y,conj(y),0,128,0,'biased',0,0);
    C42_ofdm(i) = cum4x(y,y,conj(y),conj(y),0,128,0,'biased',0,0);
    C20 = cum2x(conj(y),y);
    C21 = cum2x(y,y);
    C40_ofdm(i) = abs(C40_ofdm(i))/(C21^2);
    C42_ofdm(i) = abs(C42_ofdm(i))/(C21^2);
    
end
figure;
subplot(311);plot(C40_ofdm);grid on;
subplot(312);plot(C41_ofdm);grid on;
subplot(313);plot(C42_ofdm);grid on;

disp(['C40_ofdm: ',num2str(mean(C40_ofdm))]);
disp(['C41_ofdm: ',num2str(mean(C41_ofdm))]);
disp(['C42_ofdm: ',num2str(mean(C42_ofdm))]);
% C40_ofdm: 0.015808
% C41_ofdm: 0.0056221
% C42_ofdm: 0.015808    
% 四阶累积量非常接近0，文献判据有效

