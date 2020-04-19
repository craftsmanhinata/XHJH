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
    
    y = y-mean(y);%ȷ�����ֵ
    %���ʹ�һ��
    nv = sqrt(sum(abs(y).^2)./length(y));
    y = y./nv;
    %�������Ľ��ۻ���C40,C41,C42
    C40_ofdm(i) = cum4x(y,y,y,y,0,128,0,'biased',0,0);
    C41_ofdm(i) = cum4x(y,y,y,conj(y),0,128,0,'biased',0,0);
    C42_ofdm(i) = cum4x(y,y,conj(y),conj(y),0,128,0,'biased',0,0);
    C20 = cum2x(conj(y),y);
    C21 = cum2x(y,y);
    C40_ofdm(i) = abs(C40_ofdm(i))/(C21^2);
    C42_ofdm(i) = abs(C42_ofdm(i))/(C21^2);
    
end
figure;
subplot(311);plot(C40_ofdm);grid on;
subplot(312);plot(C41_ofdm);grid on;
subplot(313);plot(C42_ofdm);grid on;

disp(['C40_ofdm: ',num2str(mean(C40_ofdm))]);
disp(['C41_ofdm: ',num2str(mean(C41_ofdm))]);
disp(['C42_ofdm: ',num2str(mean(C42_ofdm))]);
% C40_ofdm: 0.015808
% C41_ofdm: 0.0056221
% C42_ofdm: 0.015808    
% �Ľ��ۻ����ǳ��ӽ�0�������о���Ч

