%通过音频文件体验一下多径
clc;clear;close all;
load handel.mat
%[y,Fs] = audioread('C:\Users\Public\Music\Sample Music\Kalimba.mp3');
%加上高斯白噪声
% y1 = awgn(y,40);
% sound(y1,Fs)
%瑞利单信道
% rch1 = rayleighchan(1/Fs,0);
% y2 = filter(rch1,y);
% y2 = real(y2);
% sound(y2,Fs)
%瑞利多径，选择性衰落
% rch1 = rayleighchan(1/Fs,10,[0 0.01 0.02],[1 10 20]);
% y2 = filter(rch1,y);
% y3 = real(y2);
% sound(y3,Fs)
% y1 = [ones(1,10000) y'];
% y2 = [y' ones(1,10000)];
% sound(y1+y2,Fs)
rayChan = comm.RayleighChannel(...
    'SampleRate',Fs, ...
    'PathDelays',[0 1], ...
    'AveragePathGains',[1 10], ...
    'NormalizePathGains',true, ...
    'MaximumDopplerShift',0, ...
    'DopplerSpectrum',{doppler('Gaussian',0.6),doppler('Flat')}, ...
    'RandomStream','mt19937ar with seed', ...
    'Seed',22, ...
    'PathGainsOutputPort',true);
[y1,pg1] = rayChan(y);
y3 = imag(y1);
sound(y3,Fs)