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
    %计算其四阶累积量C40,C41,C42
    C40_ofdm(i) = cum4x(y,y,y,y,0,128,0,'biased',0,0);
    C41_ofdm(i) = cum4x(y,y,y,conj(y),0,128,0,'biased',0,0);
    C42_ofdm(i) = cum4x(y,y,conj(y),conj(y),0,128,0,'biased',0,0);
end
figure;
subplot(311);plot(C40_ofdm);grid on;
subplot(312);plot(C41_ofdm);grid on;
subplot(313);plot(C42_ofdm);grid on;

disp(['C40_ofdm: ',num2str(mean(C40_ofdm))]);
disp(['C41_ofdm: ',num2str(mean(C41_ofdm))]);
disp(['C42_ofdm: ',num2str(mean(C42_ofdm))]);
% C40_ofdm: 1.6864e-06
% C41_ofdm: 1.6864e-06
% C42_ofdm: 1.6864e-06      
% 四阶累积量非常接近0，文献判据有效

