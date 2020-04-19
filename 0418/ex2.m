clc;clear;close all;
%load handel.mat
%[y,Fs] = audioread('C:\Users\Public\Music\Sample Music\Kalimba.mp3');
[y,Fs] = audioread('C:\Users\zjw\Downloads\pconline1552926819117.mp3');
[s,f,t] = stft(y(:,2),Fs,'Window',kaiser(256,5),'OverlapLength',220,'FFTLength',512);
mesh(t,f,abs(s))