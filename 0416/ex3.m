clc;
clear;
close all;

randn('seed',0);
x=randn(64,64); y=x.*x;
figure;
dbic=bispecdx(x,x,y,128,5);
figure;
dbic1=bispecdx(x,x,x,128,5);