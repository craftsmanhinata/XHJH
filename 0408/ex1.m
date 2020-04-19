clc;
clear;
close all;
M = 4;%QPSK
instance_length = 100;%信号数
iq_sample_length = 2^10;%每个信号长
snr_db_vec = -10:1:20;
snr_length = length(snr_db_vec);
 
snr_db = ''; %将噪声功率限制为信号功率的千分之一，近似无噪声

channel_type = ''; % no fading channel.not realistic
channel_fs_hz = 1e6;
max_freq_offset_hz = 0;
max_phase_offset_deg = 0;
iq_from_1st_sample = 1; % no symbol timing error. not realistic
sample_per_symbol = 8;%8bit采样

iq = gen_psk_mod_iq(M, instance_length, iq_sample_length, snr_db, ...
    channel_type, channel_fs_hz, max_freq_offset_hz, max_phase_offset_deg, iq_from_1st_sample, ...
    sample_per_symbol);

feature = compute_feature_of_modulation_signal(iq);

mean(feature)