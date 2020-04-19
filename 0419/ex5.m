clc;clear;close all;
% Reference：
% [1]A. Swami和B. M. Sadler, 《Hierarchical digital modulation classification using cumulants》, IEEE Trans. Commun., 卷 48, 期 3, 页 416–429, 3月 2000, doi: 10.1109/26.837045.


%计算一下PAM信号的四阶累积量
n = 1000;
C40 = zeros(1,n);
C41 = zeros(1,n);
C42 = zeros(1,n);
SNR = 15;
Mn = [4,8,16,32,64,128]
for mn = 1:length(Mn)
    for i = 1:n    
        M = Mn(mn); % QAM
        symbol_length = 256*4;
        x = randi([0, M-1], 1, symbol_length);
        y = pammod(x, M); % 就是符号的映射，无所谓行列值
        y = y - mean(y); % 零均值
        %功率归一化
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

    disp(['  ',num2str(M),'PAM']);
    disp(['    C40: ',num2str(mean(C40))]);
    disp(['    C41: ',num2str(mean(C41))]);
    disp(['    C42: ',num2str(mean(C42))]);
end %mn
% RESULT:
%   4PAM
%     C40: -1.3573
%     C41: -1.3573
%     C42: -1.3573
%   8PAM
%     C40: -1.2362
%     C41: -1.2362
%     C42: -1.2362
%   16PAM
%     C40: -1.2053
%     C41: -1.2053
%     C42: -1.2053
%   32PAM
%     C40: -1.2008
%     C41: -1.2008
%     C42: -1.2008
%   64PAM
%     C40: -1.1989
%     C41: -1.1989
%     C42: -1.1989
%   128PAM
%     C40: -1.1997
%     C41: -1.1997
%     C42: -1.1997