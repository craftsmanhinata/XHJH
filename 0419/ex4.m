clc;clear;close all;
% Reference：
% [1]A. Swami和B. M. Sadler, 《Hierarchical digital modulation classification using cumulants》, IEEE Trans. Commun., 卷 48, 期 3, 页 416–429, 3月 2000, doi: 10.1109/26.837045.


%计算一下QAM信号的四阶累积量
n = 1000;
C40 = zeros(1,n);
C41 = zeros(1,n);
C42 = zeros(1,n);
SNR = 15;
Mn = [4*4,8*8,16*16,32*32,64*64,128*128];
for mn = 1:length(Mn)
    for i = 1:n    
        M = Mn(mn); % QAM
        symbol_length = 256*4;
        x = randi([0, M-1], 1, symbol_length);
        y = qammod(x, M); % 就是符号的映射，无所谓行列值
        y = y - mean(y); % 零均值
        %单位能量
        nv = sqrt(sum(abs(y).^2)./symbol_length);
        y = y./nv;

        %mean(y)
        %scatterplot(y); % 观察星座图
        %计算其四阶累积量C40,C41,C42
        C40(i) = cum4x(conj(y),y,y,conj(y),0,length(y),0,'biased',0,0);
        C41(i) = cum4x(conj(y),y,y,y,0,length(y),0,'biased',0,0);
        C42(i) = cum4x(conj(y),y,conj(y),y,0,length(y),0,'biased',0,0);
    end
    figure;
    subplot(311);plot(real(C40));grid on;
    subplot(312);plot(real(C41));grid on;
    subplot(313);plot(real(C42));grid on;

    disp(['  ',num2str(M),'QAM']);
    disp(['    C40: ',num2str(mean(C40))]);
    disp(['    C41: ',num2str(mean(C41))]);
    disp(['    C42: ',num2str(mean(C42))]);
end %mn  
% RESULT:
%   16QAM
%     C40: -0.67537+0.00053354i
%     C41: -0.0012028+0.00023785i
%     C42: -0.68035+8.4607e-19i
%   64QAM
%     C40: -0.61567-0.00020462i
%     C41: 6.1934e-05-9.6162e-05i
%     C42: -0.6191-4.8408e-20i
%   256QAM
%     C40: -0.60148-0.00065965i
%     C41: 0.00089115-0.0023884i
%     C42: -0.60478+2.1224e-19i
%   1024QAM
%     C40: -0.59754-0.001621i
%     C41: 0.00053113+0.00023378i
%     C42: -0.60203+1.197e-19i
%   4096QAM
%     C40: -0.5987-0.0015795i
%     C41: 0.00039267-0.0004495i
%     C42: -0.60082+6.085e-20i
%   16384QAM
%     C40: -0.59574-7.9731e-05i
%     C41: -0.002462+0.00055998i
%     C42: -0.60014-1.5036e-19i