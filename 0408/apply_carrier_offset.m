function [y] = apply_carrier_offset(y, fs, max_freq_offset_hz, max_phase_offset_deg)
% apply carrier offset to signal

% using comm.PhaseFrequencyOffset system object and step function may be time killer
% when instance length = 10, no offset vs offset = 0.97 min vs 2.05 min
% but when time varying (freq offset, offset), must use comm.PhaseFrequencyOffset
% in my case, only fixed (freq offset, phase offset) is assumed
%
% when instance length = 10, (comm.PhaseFrequencyOffset) using vs not using = 2.05 min vs 1.01 min
using_PhaseFrequencyOffset = 0;

% random selection of freq offset
if max_freq_offset_hz
    freq_offset_hz = randi([-max_freq_offset_hz, max_freq_offset_hz]);
else
    freq_offset_hz = 0; 
end

% random selection of phase offset
if max_phase_offset_deg
    phase_offset_deg = randi([-max_phase_offset_deg, max_phase_offset_deg]);
else
    phase_offset_deg = 0;
end

if using_PhaseFrequencyOffset
    % create phase freq offset object
    h_offset = comm.PhaseFrequencyOffset(...
        'PhaseOffset', phase_offset_deg, ...
        'FrequencyOffset', freq_offset_hz, ...
        'SampleRate', fs);
    
    % apply phase freq offset
    y = step(h_offset, y);
else
    phase_offset_rad = (pi/180) * phase_offset_deg;
    
    % apply phase freq offset
    t = (0 : length(y) - 1)' / fs;
    y = y .* exp(1i * (2 * pi * freq_offset_hz * t + phase_offset_rad));
end

end
