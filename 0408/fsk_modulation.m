function [y] = ...
    fsk_modulation(M, freq_sep, symbol_length, sample_per_symbol, snr_db, fs, plot_modulated, plot_stella, ...
    chan_type, chan_fs, fd, save_iq, max_freq_offset_hz, max_phase_offset_deg)
% fsk modulation
% see also "fsk_comm_modulation.m"
%
% [input]
% - M: mary, mother of jesus. must be power of 2.
% - freq_sep: fsk freq separation. (M-1) * freq_sep <= fs. 
%   ##### as fs = 1, must be (M-1) * freq_sep <= 1.
%   the desired separation between successive frequencies
%   see "learn_fsk_modulation_index.m"
%   important factor in fsk modulation: freq spectrum depend on freq_sep
% - symbol_length:
% - sample_per_symbol: sample per symbol
% - snr_db:
% - fs: sample rate. ####### set to 1.
%   (1) fs = 1, freq_sep = .2
%   (2) fs = 1e3, freq_sep = 200 (= 1e3 * .2)
%   above two case give same y (iq sample). see "inside_fskmod.m".
% - plot_modulated: boolean
% - plot_stella: boolean
% - chan_type: standard fading channel(rician). one of 'gsmRAx6c1', 'gsmRAx4c2', 'cost207RAx6', 'cost207RAx4'
%   for details, use "help stdchan" in matlab command window
%   if empty, no fading channel
% - chan_fs: channel fs. used for sample period in constructing fading channel object.
%   even if chan_type is empty, "apply_carrier_offset" function use it.
% - fd: max doppler freq in hz. used in constructing fading channel object. 
%   recommend = 0. dont use fd > 0 (##### you may restart matlab program)
%   if chan_type is empty, dont care
% - save_iq: 0 = no save, 1 = save iq into 'nbfm_modulation.mat' file.
% - max_freq_offset_hz: freq offset = randi([-max_freq_offset_hz, max_freq_offset_hz]). 
%   if 0, no freq offset
% - max_phase_offset_deg: phase offset = randi([-max_phase_offset_deg, max_phase_offset_deg]). 
%   if 0, no phase offset
%
% [usage]
% (modulation index = 2)
% fsk_modulation(2, .25, 2^8, 8, 10, 1, 1, 1, 'gsmRAx6c1', 1e6, 0, 0, 100, 180);
%
% (modulation index = 1.5)
% fsk_modulation(4, .1875, 2^8, 8, 10, 1, 1, 1, '', 1e6, 0, 0, 100, 180);
%
% (modulation index = 0.32, bluetooth basic rate)
% fsk_modulation(2, .04, 2^8, 8, 10, 1, 1, 1, '', 1e6, 0, 0, 0, 0);
%
% (modulation index = 0.27, digital mobile radio)
% fsk_modulation(4, .0338, 2^8, 8, 10, 1, 1, 1, '', 1e6, 0, 0, 0, 0);
% 
% #####################################################################################################
% ### [reference]
% ### https://www.silabs.com/community/wireless/proprietary/knowledge-base.entry.html/2015/02/04/calculation_of_them-Vx5f
% ###
% ### 2fsk modulation index = 2 * deviation / symbol_rate, where deviation = high freq from carrier
% ### 4fsk modulation index = 2 * inner_deviation / symbol_rate, where inner_deviation = inner high freq from carrier
% ###
% ### when 4fsk, outer_deviation = 3 * inner_deviation
% #####################################################################################################
%
% ####### fsk example in real life ########
%
% [2fsk = bluetooth basic rate] (see "intro_to_bluetooth_test(basic rate, gfsk).pdf")
% binary gfsk(gaussian fsk), 1 Msymbol/sec (= 1Mbps)
% fsk modulation index = 0.32 nominal
% freq deviation between two peaks = 166e3 * 2 (two peaks from carrier = +-166e3)
% pulse shaping = gaussian filter
% bandwidth bit period product, BT = 0.5 (gaussian filter cut-off freq = 500e3)
%
% [4fsk = digital mobile radio] (see "digital mobile radio air interface protocol(2016).pdf")
% rf carrier bandwidth = 12.5e3
% symbol rate = 4800 symbols/sec
% symbol mapping to 4fsk freq deviation from carrier center: 
% (bit1,bit0) = [(0,1),(0,0),(1,0),(1,1)], symbol = [+3,+1,-1,-3], freq = [+1.944e3,+0.648e3,-0.648e3,-1.944e3]
% modulation index = 0.27
% pulse shaping = root raised cosine filter
% 

% symbol
x = randi([0, M-1], symbol_length, 1);

if (M - 1) * freq_sep > fs
    error('must satisfy (M - 1) * freq_sep <= fs');
end

% fsk modulation
% must satisfy (M-1) * freq_sep <= fs
y = fskmod(x, M, freq_sep, sample_per_symbol, fs);
length(y);

% apply fading channel
if ~isempty(chan_type)
    y = apply_fading_channel(y, chan_type, chan_fs, fd);
end

% apply carrier offset
if max_freq_offset_hz || max_phase_offset_deg
    % ##########################################################
    % #### must have chan_fs input, NOT fs
    % #### in later, must write (fs, chan_fs) unified version
    % ##########################################################
    y = apply_carrier_offset(y, chan_fs, max_freq_offset_hz, max_phase_offset_deg);
end

% add noise
if ~isempty(snr_db)
    y = awgn(y, snr_db, 'measured', 'db');
end

% save iq into mat file
if save_iq
    mat_filename = sprintf('%d%s.mat', M, mfilename);
    save(mat_filename, 'y', 'M', 'freq_sep', 'symbol_length', 'sample_per_symbol', 'snr_db', 'fs', ...
        'chan_type', 'chan_fs', 'fd');
end

if plot_modulated
    plot_signal(y, fs, sprintf('[%dfsk] freq sep = %g, snr = %d dB, sps = %d', ...
        M, freq_sep, snr_db, sample_per_symbol));
end

if plot_stella   
    y_rx = fskdemod(y, M, freq_sep, sample_per_symbol, fs);
    [number, ratio] = symerr(x, y_rx);
    
    plot_constellation(y, sprintf('[%dfsk] freq sep = %g, snr = %d dB, symbol error rate = %g', ...
        M, freq_sep, snr_db, ratio));
end

end

% % matlab digital modulation function
% %
% % pskmod(x, M, ini_phase)
% % fskmod(x, M, freq_sep, nsamp, fs) % phase_cont = 'cont' (default)
% % fskmod(x, M, freq_sep, nsamp, fs, phase_cont)
% % qammod(x, M, ini_phase)
% % mskmod(x, nsamp)
% % dpskmod(x, M)
% % oqpskmod(x)
% %


