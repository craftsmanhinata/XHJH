clc;clear;close all;
% Reference：
% [1]A. Swami和B. M. Sadler, 《Hierarchical digital modulation classification using cumulants》, IEEE Trans. Commun., 卷 48, 期 3, 页 416–429, 3月 2000, doi: 10.1109/26.837045.
% [2]王永娟, 《基于高阶累积量的OFDM信号调制识别技术研究》, 硕士, 西安电子科技大学, 西安, 2009.


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
            'PathDelays',[0 0.1 0.2 0.3 0.4 0.5], ...
            'AveragePathGains',[1 2 3 4 5 6], ...
            'NormalizePathGains',true, ...
            'MaximumDopplerShift',0.1, ...
            'DopplerSpectrum',{doppler('Gaussian',0.6),doppler('Gaussian',0.6),doppler('Flat'),doppler('Gaussian',0.6),doppler('Flat'),doppler('Gaussian',0.6)}, ...
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
        %按照文献[2]重新构造C40和C40
        C20 = cum2x(conj(y),y);
        C21 = cum2x(y,y);
        C40(i) = abs(C40(i))/(C21^2);
        C42(i) = abs(C42(i))/(C21^2);
                
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
%   
%   2PSK
%     C40: 0.55081
%     C41: -0.27732-0.14378i
%     C42: 0.77813
%   4PSK
%     C40: 0.36213
%     C41: 0.0051808+0.0072277i
%     C42: 0.31194
%   8PSK
%     C40: 0.35512
%     C41: 0.0014402+0.00454i
%     C42: 0.30471
%   16PSK
%     C40: 0.35149
%     C41: -0.0005917+0.0050158i
%     C42: 0.30747
%   32PSK
%     C40: 0.35576
%     C41: -0.00085479-0.0040977i
%     C42: 0.30394

%经过对比，高于4的PSK的C40非零了。
