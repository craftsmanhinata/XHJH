clc;
clear;
close all;

load nl1
figure;
[bicx,wx] = bicoherx(x,x,y);
figure;
mesh(wx, wx, bicx)

figure;
[bicx1,wx1] = bicoherx(x,x,x);
figure;
mesh(wx1, wx1, bicx1)

y2 = x.*x;
figure;
[bicx2,wx2] = bicoherx(x,x,y2);
figure;
mesh(wx2, wx2, bicx2)