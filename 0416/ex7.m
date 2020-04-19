load ma1;
q = maorder(y,0,6);

clc;clear;close;
rand('seed',0); randn('seed',0);
u=rpiid(1024*8,'exp'); n=25;
%y=filter([1,-2], [1,-1.3,0.52,-0.06], u);
%y=filter([1,-2], [1,-2,1.43,-0.424,0.042], u);
y=filter([1,1.5857,1.3,0.9604], [1], u);
q1 = maorder(y,0,6);