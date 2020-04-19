clc;
clear;
close all;
M = 4;%QPSK
instance_length = 100;%�ź���
iq_sample_length = 2^10;%ÿ���źų�
snr_db_vec = -10:1:20;
snr_length = length(snr_db_vec);
 
snr_db = ''; %��������������Ϊ�źŹ��ʵ�ǧ��֮һ������������

channel_type = ''; % no fading channel.not realistic
channel_fs_hz = 1e6;
max_freq_offset_hz = 0;
max_phase_offset_deg = 0;
iq_from_1st_sample = 1; % no symbol timing error. not realistic
sample_per_symbol = 8;%8bit����

iq = gen_psk_mod_iq(M, instance_length, iq_sample_length, snr_db, ...
    channel_type, channel_fs_hz, max_freq_offset_hz, max_phase_offset_deg, iq_from_1st_sample, ...
    sample_per_symbol);

feature = compute_feature_of_modulation_signal(iq);

mean(feature)