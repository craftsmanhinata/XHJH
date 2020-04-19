clc;
clear;
%close all;

symbol_length = 100;%������Ŀ

snr_db_vec = -5:20;
pc = zeros(1,length(snr_db_vec));
for i1 = 1:length(snr_db_vec)
    snr_db = snr_db_vec(i1);
    
    %ͳ��1000��bpsk�ڴ�snr���ж��ٴ���
    correct_bpsk = 0;
    for i2 = 1:1000        
        M = 2;
        x = randi([0, M-1], 1, symbol_length);
        y = pskmod(x, M, 0); %���Ƿ��ŵ�ӳ�䣬����ν����ֵ
        %���ǵ�λ����������
        nv = sqrt(sum(abs(y).^2)./symbol_length);
        y = y./nv;
        y = awgn(y, snr_db, 'measured', 'db');%������
        %�õ��߽��ۻ���
        feature = compute_feature_of_modulation_signal(y);
        if feature(3) >= 1.68
            correct_bpsk = correct_bpsk + 1;
        end
        %abs(cum4x(y,y,y,y,0,128,0,'biased',0,0))-feature(3)
    end %i2
    
    %ͳ��1000��8psk�ڴ�snr���ж��ٴ���
    correct_8psk = 0;
    for i2 = 1:1000        
        M = 8;
        x = randi([0, M-1], 1, symbol_length);
        y = pskmod(x, M, 0); %���Ƿ��ŵ�ӳ�䣬����ν����ֵ
        %���ǵ�λ����������
        nv = sqrt(sum(abs(y).^2)./symbol_length);
        y = y./nv;
        y = awgn(y, snr_db, 'measured', 'db');%������
        %�õ��߽��ۻ���
        feature = compute_feature_of_modulation_signal(y);
        if feature(3) < 0.34
            correct_8psk = correct_8psk + 1;
        end
    end %i2
    
    %ͳ��1000��16qam�ڴ�snr���ж��ٴ���
    correct_16qam = 0;
    for i2 = 1:1000        
        M = 16;
        x = randi([0, M-1], 1, symbol_length);
        y = qammod(x, M); %���Ƿ��ŵ�ӳ�䣬����ν����ֵ
        %���ǵ�λ����������
        nv = sqrt(sum(abs(y).^2)./symbol_length);
        y = y./nv;
        y = awgn(y, snr_db, 'measured', 'db');%������
        %�õ��߽��ۻ���
        feature = compute_feature_of_modulation_signal(y);
        if feature(3) >= 0.34 && feature(3) < 1.02
            correct_16qam = correct_16qam + 1;
        end
    end %i2
    
    %ͳ��1000��4pam�ڴ�snr���ж��ٴ���
    correct_4pam = 0;
    for i2 = 1:1000        
        M = 4;
        x = randi([0, M-1], 1, symbol_length);
        y = pammod(x, M); %���Ƿ��ŵ�ӳ�䣬����ν����ֵ
        %���ǵ�λ����������
        nv = sqrt(sum(abs(y).^2)./symbol_length);
        y = y./nv;
        y = awgn(y, snr_db, 'measured', 'db');%������
        %�õ��߽��ۻ���
        feature = compute_feature_of_modulation_signal(y);
        if feature(3) >= 1.02 && feature(3) < 1.68
            correct_4pam = correct_4pam + 1;
        end
    end %i2
    
%     correct_bpsk
%     correct_8psk
%     correct_16qam
%     correct_4pam
    pc(i1) = (correct_bpsk + correct_8psk + correct_16qam + correct_4pam) / 4000
    
end %i1
%������ͼ��
plot(snr_db_vec,pc)

