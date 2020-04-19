function [iq] = gen_psk_mod_iq(M, instance_length, iq_sample_length, snr_db, ...
    chan_type, chan_fs, max_freq_offset_hz, max_phase_offset_deg, iq_from_1st_sample, sample_per_symbol)

plot_modulated = 0;
plot_stella = 0;
fd = 0;
save_iq = 0;
% max_phase_offset_deg = 180;
% sample_per_symbol = 8;
fs = 1;

symbol_length = round(iq_sample_length * 2 / sample_per_symbol);
% max_start_idx = round(iq_sample_length * .5);

iq = zeros(instance_length, iq_sample_length);
for n = 1 : instance_length
    [pre_iq] = ...
        psk_modulation(M, symbol_length, sample_per_symbol, snr_db, fs, plot_modulated, plot_stella, ...
        chan_type, chan_fs, fd, save_iq, max_freq_offset_hz, max_phase_offset_deg);
    
    if iq_from_1st_sample
        start_idx = 1;
    else
        start_idx = randi([2, sample_per_symbol]);
%         start_idx = randi(max_start_idx);
    end
    
    pre_iq = pre_iq(start_idx : start_idx + iq_sample_length - 1);
    
    % ##############################################################
    % #### normalize is needed?
    % #### it give "nan" when all pre_iq is zero
    % ##############################################################
    % normalize
    pre_iq = pre_iq / max(abs(pre_iq));
    
    % vertical stack into iq
    iq(n, :) = pre_iq;
end

end

