clc;clear;close all;

ma=[1 -2]; ar=[1 -0.8 0.65];

figure;%»­Ë«Æ×
bisp=bispect (ma,ar,128);

cmat=cumtrue(ma,ar,3,25);
figure;%»­Èý½×ÀÛ»ýÁ¿
mesh(-25:25,-25:25,cmat)
contour(-25:25,-25:25,cmat,8),grid on

%¶¯»­ÈýÆ×ÇÐÆ¬
figure;
nfft=64;
n=100; 
M=moviein(2*n+1);
M1=moviein(2*n+1);

for k=-n:n
    [tspec,waxis] = trispect(ma,ar,nfft,k/(2*n));
    M(:,k+n+1)=getframe;
    mesh(waxis,waxis,abs(tspec));
    M1(:,k+n+1)=getframe;
end
%movie (M)
%clear M