clc;clear;close all;
% Reference：
% [1]A. Swami和B. M. Sadler, 《Hierarchical digital modulation classification using cumulants》, IEEE Trans. Commun., 卷 48, 期 3, 页 416–429, 3月 2000, doi: 10.1109/26.837045.


%计算一下PSK信号的四阶累积量
n = 1000;
C40 = zeros(1,n);
C41 = zeros(1,n);
C42 = zeros(1,n);
SNR = 15;
Mn = [2,4,8,16,32];
for mn = 1:length(Mn)
    for i = 1:n    
        M = Mn(mn); % PSK
        symbol_length = 256;
        x = randi([0, M-1], 1, symbol_length);
        y = pskmod(x, M, 0); %就是符号的映射，无所谓行列值

        %y = awgn(y,SNR);
        %rch = rayleighchan(1,0.1,[0 0.01 0.02],[1 10 20]);
        rayChan = comm.RayleighChannel(...
            'SampleRate',1, ...
            'PathDelays',[0 0.1 0.2], ...
            'AveragePathGains',[1 5 10], ...
            'NormalizePathGains',true, ...
            'MaximumDopplerShift',0, ...
            'DopplerSpectrum',{doppler('Gaussian',0.6),doppler('Gaussian',0.6),doppler('Flat')}, ...
            'RandomStream','mt19937ar with seed', ...
            'Seed',22, ...
            'PathGainsOutputPort',true);
        [y,pg1] = rayChan(y.');
        y = y.';
        %单位能量限制
        nv = sqrt(sum(abs(y).^2)./symbol_length);
        y = y./nv;

        %计算其四阶累积量C40,C41,C42
        C40(i) = cum4x(conj(y),y,y,conj(y),0,length(y),0,'biased',0,0);
        C41(i) = cum4x(conj(y),y,y,y,0,length(y),0,'biased',0,0);
        C42(i) = cum4x(conj(y),y,conj(y),y,0,length(y),0,'biased',0,0);
    end
    figure;
    subplot(311);plot(real(C40));grid on;
    subplot(312);plot(real(C41));grid on;
    subplot(313);plot(real(C42));grid on;

    disp(['  ',num2str(M),'PSK']);
    disp(['    C40: ',num2str(mean(C40))]);
    disp(['    C41: ',num2str(mean(C41))]);
    disp(['    C42: ',num2str(mean(C42))]);
end %mn
% RESULT:
%   2PSK
%     C40: -1.9691+4.8228e-16i
%     C41: -1.9691+2.4114e-16i
%     C42: -1.9691-2.2335e-32i
%   4PSK
%     C40: 0.97322-5.0763e-05i
%     C41: -0.0026789-0.00054817i
%     C42: -0.98805-8.471e-20i
%   8PSK
%     C40: -0.0020408-0.00045839i
%     C41: 0.0021065-0.0033651i
%     C42: -0.98852+1.8907e-19i
%   16PSK
%     C40: 0.0020617-0.00089368i
%     C41: 0.0051224-0.0010308i
%     C42: -0.98809-1.3724e-19i
%   32PSK
%     C40: 0.00017837-0.0008498i
%     C41: -0.0014142-0.0011623i
%     C42: -0.98861-1.9436e-20i
%从结论也可以看出来，利用C40和C42来区分PSK是有效的，这个结果是符合文献[1]中的表1.


