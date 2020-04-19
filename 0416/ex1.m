clc;clear;close;
rand('seed',0); randn('seed',0);
u=rpiid(1024,'exp'); n=25;
y=filter([1,-2], [1,-1.5,0.8], u);
for k=-n:n
    cmat(:,k+n+1)=cumest(y,3,n,128,0,'biased',k);
end
figure;
subplot(121), mesh(-n:n, -n:n, cmat)
subplot(122), contour(-n:n, -n:n, cmat, 16)

% %¿Ì¬€÷µ
% 
% cmatT = cumtrue ([1,-2], [1,-1.5,0.8], 3, n, 0);
% figure;
% subplot(121), mesh(-n:n, -n:n, cmatT)
% subplot(122), contour(-n:n, -n:n, cmatT, 16)