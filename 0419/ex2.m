clc;clear;close all;

% [1] ������,2009,���ڸ߽��ۻ�����OFDM�źŵ���ʶ�����о�
% [2] ��ͦ�,2007,ͨ���źŵ���ʶ�����о�
% ===========================================================
% ���OFDM�ź�����ڵ��ز��źŶԵ�ʶ��
% ����[1]�У�3.2�ڽ����˻���ż�����ۻ�����OFDM����ʶ���㷨
% ����˼���ǣ�����OFDM�źŵĽ�����˹�ԣ����Ľ��ۻ���Ϊ�㡣�����ز��ź������ǷǸ�˹�ģ����Ľ��ۻ�����Ϊ�㡣
% ���������һ��˼���������

n = 1000;
C40_ofdm = zeros(1,n);
C41_ofdm = zeros(1,n);
C42_ofdm = zeros(1,n);
SNR = 15;

for i = 1:n
    y = genOFDMSignal(SNR);
    %�������Ľ��ۻ���C40,C41,C42
    C40_ofdm(i) = cum4x(y,y,y,y,0,128,0,'biased',0,0);
    C41_ofdm(i) = cum4x(y,y,y,conj(y),0,128,0,'biased',0,0);
    C42_ofdm(i) = cum4x(y,y,conj(y),conj(y),0,128,0,'biased',0,0);
end
figure;
subplot(311);plot(C40_ofdm);grid on;
subplot(312);plot(C41_ofdm);grid on;
subplot(313);plot(C42_ofdm);grid on;

disp(['C40_ofdm: ',num2str(mean(C40_ofdm))]);
disp(['C41_ofdm: ',num2str(mean(C41_ofdm))]);
disp(['C42_ofdm: ',num2str(mean(C42_ofdm))]);
% C40_ofdm: 1.6864e-06
% C41_ofdm: 1.6864e-06
% C42_ofdm: 1.6864e-06      
% �Ľ��ۻ����ǳ��ӽ�0�������о���Ч

