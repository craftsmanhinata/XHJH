function [y] = ...
    psk_modulation(M, symbol_length, sample_per_symbol, snr_db, fs, plot_modulated, plot_stella, ...
    chan_type, chan_fs, fd, save_iq, max_freq_offset_hz, max_phase_offset_deg)
% psk modulation
%
% [input]
% - M: mary, mother of jesus. must be power of 2
% - symbol_length:
% - sample_per_symbol:
% - snr_db: snr in db. if empty, noise is NOT added to signal
% - fs: sample rate. 
%   ####### set to 1, not important because only plot_signal function use this.
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
% psk_modulation(2, 2^10, 8, 10, 1, 1, 1, 'gsmRAx6c1', 1e6, 0, 0, 100, 180);
% psk_modulation(2, 2^10, 8, 10, 1, 1, 1, 'gsmRAx6c1', 1e6, 0, 0, 100, 180);
% psk_modulation(4, 2^10, 8, 10, 1, 1, 1, '', 1e6, 0, 0, 0, 180);
% psk_modulation(8, 2^10, 8, 10, 1, 1, 1, 'gsmRAx4c2', 1e6, 0, 1, 100, 0);
% 

% symbol
x = randi([0, M-1], symbol_length, 1);

% psk modulation
ini_phase = 0;
y = pskmod(x, M, ini_phase);

% design raised cosine filter for pulse shaping
rolloff = .25; % roll-off factor
span = 6; % number of symbols
shape = 'sqrt'; % root raised cosine filter
rrc_filter = rcosdesign(rolloff, span, sample_per_symbol, shape);

% upsample and filter modulated signal
y = upfirdn(y, rrc_filter, sample_per_symbol);
length(y);

% remove filter transient
transient_length = (span / 2) * sample_per_symbol;
% transient_length = ((span/2) - 1) * sample_per_symbol + sample_per_symbol / 2;
y = y(transient_length + 1 : end - transient_length);
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
    save(mat_filename, 'y', 'M', 'symbol_length', 'sample_per_symbol', 'snr_db', 'fs', ...
        'chan_type', 'chan_fs', 'fd', 'max_freq_offset_hz', 'max_phase_offset_deg');
end

if plot_modulated
    plot_signal(y, fs, 'modulated');
end

if plot_stella
    % rrc filter and down sample
    y_rx = upfirdn(y, rrc_filter, 1, sample_per_symbol);
    % remove filter transient
    y_rx = y_rx(span + 1 : end - span);
    length(y_rx);
    
    plot_constellation(y_rx, sprintf('%dpsk', M));
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


