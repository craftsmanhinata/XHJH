% ̽�������������ۻ�����OFDM�źŵ���ʶ��--�ྶ
% ���ز��źž����ྶ����˥���ŵ��Ժ����źŰ�����ӷǶԳƸ����ܶȷֲ���
% ������[1]�����ڴ���2 �׵��������ۻ��������������̷��ӶԳƸ����ܶȷֲ�����ô�����������ۻ���������
% ������[1]�����ӷǶԳƸ����ܶȷֲ�������ź��������ۻ���Ϊ����ֵ���� OFDM�źž���������ȩp�ྶ����˥���ŵ�������ڶ��׵��ۻ���ֵ������ 0��
% [1] ������,2009,���ڸ߽��ۻ�����OFDM�źŵ���ʶ�����о�
% �����������ۻ�����ʵ�顣
clc;clear;close all;

n = 1000;
C30_ofdm = zeros(1,n);
C31_ofdm = zeros(1,n);
SNR = 15;

for i = 1:n
    y = genOFDMSignal(SNR);
    
    y = y-mean(y);%ȷ�����ֵ
    %���ʹ�һ��
    nv = sqrt(sum(abs(y).^2)./length(y));
    y = y./nv;
    
    %���������ۻ���C30,C31
    C30_ofdm(i) = cum3x(conj(y),y,y,0,128,0,'biased',0);
    C31_ofdm(i) = cum3x(y,y,y,0,128,0,'biased',0);

end
figure;
subplot(211);plot(C30_ofdm);grid on;
subplot(212);plot(C31_ofdm);grid on;

disp(['C30_ofdm: ',num2str(mean(C30_ofdm))]);
disp(['C31_ofdm: ',num2str(mean(C31_ofdm))]);

% RESULT:
% C30_ofdm: -0.034575
% C31_ofdm: -0.034575
% �õ���Ԥ�ڵ�C31��ֵ��С�Ľ���