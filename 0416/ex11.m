clc;clear;close;
load ofdmRx_data.mat
rand('seed',0); randn('seed',0);

n=25;
y = ofdmRx_data;
for k=-n:n
    cmat(:,k+n+1)=cumest(y,4,n,128,0,'biased',0,1);
end
figure;
subplot(121), mesh(-n:n, -n:n, cmat)
subplot(122), contour(-n:n, -n:n, cmat, 16)