clc;clear;close all;

load ma1
bvec = maest(y,3,3,128);

load ar1
ar(:,1)=arrcest (y,2,0,2,12,128);
ar(:,2)=arrcest (y,2,0,3,12,128);
ar(:,3)=arrcest (y,2,0,4,12,128);
ar(:,4)=arrcest (y,2,0,-3,12,128);
ar(:,5)=arrcest (y,2,0,-4,12,128);
disp(ar)

load arma1
p = arorder(y,3)


clc;clear;close;
rand('seed',0); randn('seed',0);
u=rpiid(1024,'exp'); n=25;
%y=filter([1,-2], [1,-1.3,0.52,-0.06], u);
%y=filter([1,-2], [1,-2,1.43,-0.424,0.042], u);
y=filter([1,1.5857,0.9604], [1,-1.6408,2.2044,-1.4808,0.8145], u);

p = arorder(y,3)
