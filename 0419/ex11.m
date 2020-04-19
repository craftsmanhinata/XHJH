%��ex10���Ƚ�,��PSK�źŵ����
clc;clear;close all;

%����һ��PSK�źŵ��Ľ��ۻ���
n = 1000;
C30 = zeros(1,n);
C31 = zeros(1,n);
SNR = 15;
Mn = [2,4,8,16,32];
for mn = 1:length(Mn)
    for i = 1:n    
        M = Mn(mn); % PSK
        symbol_length = 256;
        x = randi([0, M-1], 1, symbol_length);
        y = pskmod(x, M, 0); %���Ƿ��ŵ�ӳ�䣬����ν����ֵ

        %y = awgn(y,SNR);
        %rch = rayleighchan(1,0.1,[0 0.01 0.02],[1 10 20]);
        rayChan = comm.RayleighChannel(...
            'SampleRate',1, ...
            'PathDelays',[0 0.1 0.22], ...
            'AveragePathGains',[1 0.5 0.1], ...
            'NormalizePathGains',true, ...
            'MaximumDopplerShift',0.1, ...
            'DopplerSpectrum',{doppler('Flat'),doppler('Flat'),doppler('Flat')}, ...
            'RandomStream','mt19937ar with seed', ...
            'Seed',22, ...
            'PathGainsOutputPort',true);
        [y,pg1] = rayChan(y.');
        y = y.';
        %���ֵ
        y = y - mean(y);
        %��λ��������
        nv = sqrt(sum(abs(y).^2)./length(y));
        y = y./nv;

        %���������ۻ���C30,C31
        C30(i) = cum3x(conj(y),y,y);
        C31(i) = cum3x(y,y,y);
    end
    figure;
    subplot(211);plot(real(C30));grid on;
    subplot(212);plot(real(C31));grid on;

    disp(['  ',num2str(M),'PSK']);
    disp(['    C30: ',num2str(mean(C30))]);
    disp(['    C31: ',num2str(mean(C31))]);
    
end %mn

% 2PSK
%     C30: 0.00266-0.001331i
%     C31: 0.0028457+0.00020599i
%   4PSK
%     C30: 0.00052375-0.0017807i
%     C31: -5.5424e-06+0.0014263i
%   8PSK
%     C30: -0.0019471+0.0051894i
%     C31: -0.0014265-0.00035876i
%   16PSK
%     C30: 0.00044633+0.0051365i
%     C31: -0.001037-0.0015095i
%   32PSK
%     C30: 0.0017558-0.0038197i
%     C31: 0.0026154+0.00081589i

% ����Ľ�������ǲ���ȷ�ġ�ԭ���Ƿ����ԭ��û����ȷ�ķ����������˥���ŵ���