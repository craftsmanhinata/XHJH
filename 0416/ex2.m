clc;clear;close all;
load qpc
figure;
bspec=bispeci(zmat,21,64,0,'unbiased',128,1);
figure;
dbspec=bispecdx(zmat,zmat,zmat,128,3,64,0);