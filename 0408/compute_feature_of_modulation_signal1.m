function [feature] = ...
    compute_feature_of_modulation_signal(iqn)
% compute feature of modulation signal for modulation classification
%
% [input]
% - iqn: iq sample normized for every instance. dimension = instance_length x iq_sample_length
% - amplitude_threshold: amplitude threshold. signal below threshold is discarded as noise
% - feature_name_cell: feature name cell array
% - fs: sample rate. only used in computing sigma_af feature
%
% [ouput]
% - feature: feature. dimension = instance_length x feature_length
%

% ################################################################################################################
% [reference]
% (1) zhu, nandi, "automatic modulation classification: principles, algorithms, and applications", wiley, 2015
% (2) azzouz, nandi, "automatic modulation recognition of communication signals", kluwer, 1996
% (3) Jung Hwan Lee et al., "Robust Automatic Modulation Classification Technique 
%     for Fading Channels via Deep Neural Network", entropy, 2017
% (4) swami, sadler, "Hierarchical Digital Modulation Classification Using Cumulants", ieee trans. comm., 2000
% (5) abdelmutalab et al., "Automatic modulation classification based on 
%     high order cumulants and hierarchical polynomial classifiers", physical comm., 2016
% (6) Aslam et al., "Automatic Modulation Classification Using Combination of Genetic Programming and KNN", 
%     IEEE TRANSACTIONS ON WIRELESS COMMUNICATIONS, VOL. 11, NO. 8, AUGUST 2012
% ################################################################################################################

% ################################################################################################################
% signal feature for modulation classification:
% (1) gamma_max: 
%     maximum value of spectral power density of normalized and centred instantaneous amplitude of received signal
% (2) sigma_ap:
%     standard deviation of absolute value of non-linear component of instantaneous phase
% (3) sigma_dp:
%     standard deviation of non-linear component of direct instantaneous phase
% (4) P:
%     spectrum symmetry around carrier frequency
% (5) sigma_aa:
%     standard deviation of absolute value of normalized and centred instantaneous amplitude of signal samples
% (6) sigma_af:
%     standard deviation of absolute value of normalized and centred instantaneous frequency
% (7) sigma_a:
%     standard deviation of normalized and centred instantaneous amplitude
% (8) mu_a42:
%     kurtosis of normalized and centred instantaneous amplitude
% (9) mu_f42:
%     kurtosis of normalized and centred instantaneous frequency
% (10) C20: see [reference (4)]
% (11) C21: see [reference (4)]
% (12) C40: see [reference (4)]
% (13) C41: see [reference (4)]
% (14) C42: see [reference (4)]
% (15) C60: see [reference (5),(6)]
% (16) C61: see [reference (5),(6)]
% (17) C62: see [reference (5),(6)]
% (18) C63: see [reference (5),(6)]
%
%
% [question]
% what is non-linear component of instantaneous phase? 
% [answer]
% phase excluding linear phase component due to carrier component (see [reference (2)] pdf page 30)
%
% how we get non-linear component of instantaneous phase?
% this need carrier freq offset compensation. not easy job
% 
% ################################################################################################################

[instance_length, iq_sample_length] = size(iqn);

feature_length = 5;
feature = zeros(instance_length, feature_length);

for n = 1 : instance_length
    iq = iqn(n, :);   
    feature(n, 1) = feature_C20(iq);
    feature(n, 2) = feature_C21(iq);
    feature(n, 3) = feature_C40(iq);
    feature(n, 4) = feature_C41(iq);
    feature(n, 5) = feature_C42(iq);
end

end

%% 
function [gamma_max] = feature_gamma_max(iq)
%
% [input]
% - iq: iq sample. dimension = 1 * iq_sample_length
%
% [output]
% - gamma_max: dimension = scalar
%

% ####################################################################
% see [reference (1)] eq(5.1) ~ eq(5.3)
% reference page 69: 
% {AM, SSB, M-ASK, M-PAM, M-PSK, M-QAM} => large gamma_max
% {FM, M-FSK} => small gamma_max
% ####################################################################

% ###############################################################
% computation show good result:
% modulation_name_cell = {'amsc','ssb','nbfm','wbfm','bpsk','qpsk','2fsk','4fsk','16qam'}
% gamma_max = 
% ###############################################################

sample_length = length(iq);

% amplitude of iq sample
amp_iq = abs(iq);

% mean of amplitude of iq sample
mu_iq = mean(amp_iq);
% mu_iq = sum(amp_iq) / sample_length;

% normalized and centered instantenous amplitude of iq sample
cn_amp_iq = (amp_iq / mu_iq) - 1;

gamma_max = max(abs(fft(cn_amp_iq)) .^ 2) / sample_length;

end

%% 
function [sigma_ap] = feature_sigma_ap(iq, amplitude_threshold)
%
% [input]
% - iq: iq sample. dimension = 1 * iq_sample_length
% - amplitude_threshold: amplitude threshold
%
% [output]
% - sigma_ap: dimension = scalar
%

% ##########################################################
% see [reference (1)] eq(5.4)
% reference (1) page 69: 
% {FM, SSB, M-FSK, M-PSK(M > 2), M-QAM} => large sigma_ap
% {AM, M-ASK, BPSK} => small sigma_ap
% ##########################################################

% #######################################################################
% only when convert negative component(real, imaginary) to positive,
% computation show good result:
% modulation_name_cell = {'amsc','ssb','nbfm','wbfm','bpsk','qpsk','2fsk','4fsk','16qam'}
% sigma_ap = 0.0620, 0.4529, 0.1382, 0.3739, 0.0495, 0.5943, 0.5187, 0.4537, 0.4100
%
% why confining iq phasor in 1st quadrant is needed?
% reference (1) never say this procedure.
% ##########################################################################################

% sample_length = length(iq);

% amplitude of iq sample
amp_iq = abs(iq);

% mean of amplitude of iq sample
mu_iq = mean(amp_iq);
% mu_iq = sum(amp_iq) / sample_length;

% normalized instantenous amplitude of iq sample
n_amp_iq = amp_iq / mu_iq;

% select iq sample whose amplitude is greater than threshold
valid_idx = n_amp_iq > amplitude_threshold;
iq = iq(valid_idx);
% sample_length = length(iq);

% convert negative real component to positive
idx = real(iq) < 0;
iq(idx) = complex(real(iq(idx)) * -1, imag(iq(idx)));

% convert negative imaginary component to positive
idx = imag(iq) < 0;
iq(idx) = complex(real(iq(idx)), imag(iq(idx)) * -1);

phase_iq = angle(iq);

sigma_ap = std(abs(phase_iq));
% below line give same result as above line which is much simple
% sigma_ap = sqrt(sum(phase_iq .^ 2) / sample_length - (sum(abs(phase_iq)) / sample_length) ^ 2);

end

%% 
function [sigma_dp] = feature_sigma_dp(iq, amplitude_threshold)
%
% [input]
% - iq: iq sample. dimension = 1 * iq_sample_length
% - amplitude_threshold: amplitude threshold
%
% [output]
% - sigma_dp: dimension = scalar
%

% ##################################################################################################
% see [reference (1)] eq(5.5)
% reference (1) page 69: 
% {FM, SSB, M-FSK, M-PSK, M-QAM} => large sigma_dp
% {AM, M-ASK} => small sigma_dp
% Being similar to sigma_ap, 
% sigma_dp provides ability to distinguish BPSK from other modulations without phase information.
% ##################################################################################################

% ##########################################################################################
% computation show bad result:
% modulation_name_cell = {'amsc','ssb','nbfm','wbfm','bpsk','qpsk','2fsk','4fsk','16qam'}
% sigma_dp = 2.1764, 1.8099, 0.2049, 0.8254, 2.1778, 1.8587, 1.8314, 1.8136, 1.8007
% ##########################################################################################

% % ################################
% % i remove this feature(sigma_dp)
% % ################################
% sigma_dp = 0;

% sample_length = length(iq);

% amplitude of iq sample
amp_iq = abs(iq);

% mean of amplitude of iq sample
mu_iq = mean(amp_iq);
% mu_iq = sum(amp_iq) / sample_length;

% normalized instantenous amplitude of iq sample
n_amp_iq = amp_iq / mu_iq;

% select iq sample whose amplitude is greater than threshold
valid_idx = n_amp_iq > amplitude_threshold;
iq = iq(valid_idx);
% sample_length = length(iq);

% % convert negative real component to positive
% idx = real(iq) < 0;
% iq(idx) = complex(real(iq(idx)) * -1, imag(iq(idx)));

% #############################################
% this is right?
% #############################################
% convert negative imaginary component to positive
idx = imag(iq) < 0;
iq(idx) = complex(real(iq(idx)), imag(iq(idx)) * -1);

phase_iq = angle(iq);

sigma_dp = std(phase_iq);
% below line give same result as above line which is much simple
% sigma_ap = sqrt(sum(phase_iq .^ 2) / sample_length - (sum(phase_iq) / sample_length) ^ 2);

end

%% 
function [P] = feature_P(iq)
%
% [input]
% - iq: iq sample. dimension = 1 * iq_sample_length
%
% [output]
% - P: dimension = scalar
%

% ##################################################################################################
% see [reference (1)] eq(5.6) ~ eq(5.9)
% reference (1) page 69: 
% {SSB, VSB} => large P
% {AM, M-ASK} => small P
%
% eq(5.7), eq(5.8): fourier transform of signal xc[n]
% what is xc[n], not x[n]?
% i cant find the definition of xc[n]
% i quess xc[n] is x[n] centered around zero, by which carrier freq is removed
% see "learn_carrier_freq_removal.m"
%
% DONT REMOVE carrier freq! (180420)
% ##################################################################################################

% ##########################################################################################
% computation show good result:
% modulation_name_cell = {'amsc','ssb','nbfm','wbfm','bpsk','qpsk','2fsk','4fsk','16qam'}
% P = 0.0022, 0.9844, 0.9430, 0.5314, 0.0024, 0.0295, 0.0410, 0.0325, 0.0317
% ##########################################################################################

sample_length = length(iq);
half_length = fix(sample_length / 2);

% #################### dont use below ##################
% % remove carrier freq
% iq = iq - mean(abs(iq));
% size(iq);

p = abs(fftshift(fft(iq))).^2;
size(p);

p_lower = sum(p(1 : half_length));
p_upper = sum(p(half_length + 1 : end));

P = abs((p_lower - p_upper) / (p_lower + p_upper));

end

%% 
function [sigma_aa] = feature_sigma_aa(iq)
%
% [input]
% - iq: iq sample. dimension = 1 * iq_sample_length
%
% [output]
% - sigma_aa: dimension = scalar
%

% ######################################
% see [reference (1)] eq(5.10)
% reference (1) page 69: 
% {M-ASK(M > 2)} => large sigma_aa
% {2-ASK} => small sigma_aa
% ######################################

% ####################################
% i remove this feature(sigma_aa):
% because M-ASK is not my concern
% ####################################
% sigma_aa = 0;

% sample_length = length(iq);

% amplitude of iq sample
amp_iq = abs(iq);

% mean of amplitude of iq sample
mu_iq = mean(amp_iq);
% mu_iq = sum(amp_iq) / sample_length;

% normalized and centered instantenous amplitude of iq sample
cn_amp_iq = (amp_iq / mu_iq) - 1;

sigma_aa = std(abs(cn_amp_iq));

% % convert negative real component to positive
% idx = real(iq) < 0;
% iq(idx) = complex(real(iq(idx)) * -1, imag(iq(idx)));
% 
% % convert negative imaginary component to positive
% idx = imag(iq) < 0;
% iq(idx) = complex(real(iq(idx)), imag(iq(idx)) * -1);

end

%% 
function [sigma_af] = feature_sigma_af(iq, amplitude_threshold, fs)
%
% [input]
% - iq: iq sample. dimension = 1 * iq_sample_length
% - amplitude_threshold: amplitude threshold
% - fs: sample rate
%
% [output]
% - sigma_af: dimension = scalar
%

% #########################################
% see [reference (1)] eq(5.11) ~ eq(5.14)
% reference (1) page 70: 
% {M-FSK(M > 2)} => large sigma_af
% {2-FSK} => small sigma_af
% #########################################

% ##########################################################################################
% only when convert negative component(real, imaginary) to positive,
% computation show good result:
% modulation_name_cell = {'amsc','ssb','nbfm','wbfm','bpsk','qpsk','2fsk','4fsk','16qam'}
% sigma_af = 0.0562, 0.1097, 0.0533, 0.0706, 0.0454, 0.1332, 0.0828, 0.3626, 0.1752
%
% why confining iq phasor in 1st quadrant is needed?
% reference (1) never say this procedure.
% 
% this is not good feature because it depend on fs(sample rate)
% more study is needed (180419)
% ##########################################################################################

% % #########################
% % i remove sigma_af
% % #########################
% sigma_af = 0;

% sample_length = length(iq);

% amplitude of iq sample
amp_iq = abs(iq);

% mean of amplitude of iq sample
mu_iq = mean(amp_iq);
% mu_iq = sum(amp_iq) / sample_length;

% normalized instantenous amplitude of iq sample
n_amp_iq = amp_iq / mu_iq;

% select iq sample whose amplitude is greater than threshold
valid_idx = n_amp_iq > amplitude_threshold;
iq = iq(valid_idx);
% sample_length = length(iq);

% convert negative real component to positive
idx = real(iq) < 0;
iq(idx) = complex(real(iq(idx)) * -1, imag(iq(idx)));

% convert negative imaginary component to positive
idx = imag(iq) < 0;
iq(idx) = complex(real(iq(idx)), imag(iq(idx)) * -1);

% get freq which is phase difference
freq_iq = diff(angle(iq)) * fs;

% centered instantenous freq using freq mean: see reference (1), eq.(5.13)
freq_iq = freq_iq - mean(freq_iq);

% freq is normalized by fs: see reference (1), eq.(5.12)
freq_iq = freq_iq / fs;

sigma_af = std(abs(freq_iq));

end

%% 
function [sigma_a] = feature_sigma_a(iq, amplitude_threshold)
%
% [input]
% - iq: iq sample. dimension = 1 * iq_sample_length
% - amplitude_threshold: amplitude threshold
%
% [output]
% - sigma_a: dimension = scalar
%

% #######################################################
% see [reference (1)] eq(5.15)
% 
% reference (1) page 71 (decision tree):
% {DSB} => large sigma_a
% {BPSK} => small sigma_a
%
% reference (1) have no reasoning to use this feature
% this feature is good to classify modulation?
% #######################################################

% ########################################################################################
% computation show bad result:
% modulation_name_cell = {'amsc','ssb','nbfm','wbfm','bpsk','qpsk','2fsk','4fsk','16qam'}
% sigma_a = 0.4522, 0.3522, 0.0708, 0.0707, 0.2595, 0.2102, 0.0704, 0.0704, 0.3014
% ########################################################################################

% % ####################
% % i remove sigma_a
% % ####################
% sigma_a = 0;

% sample_length = length(iq);

% amplitude of iq sample
amp_iq = abs(iq);

% mean of amplitude of iq sample
mu_iq = mean(amp_iq);
% mu_iq = sum(amp_iq) / sample_length;

% normalized instantenous amplitude of iq sample
n_amp_iq = amp_iq / mu_iq;

% select iq sample whose amplitude is greater than threshold
valid_idx = n_amp_iq > amplitude_threshold;
iq = iq(valid_idx);

% sample_length = length(iq);

% amplitude of iq sample
amp_iq = abs(iq);

% mean of amplitude of iq sample
mu_iq = mean(amp_iq);
% mu_iq = sum(amp_iq) / sample_length;

% normalized and centered instantenous amplitude of iq sample
cn_amp_iq = (amp_iq / mu_iq) - 1;

sigma_a = std(cn_amp_iq);

end

%% 
function [mu_a42] = feature_mu_a42(iq)
%
% [input]
% - iq: iq sample. dimension = 1 * iq_sample_length
%
% [output]
% - mu_a42: dimension = scalar
%

% #########################################
% see [reference (1)] eq(5.16)
% reference (1) page 70: 
% {M-ASK} => large mu_a42
% {AM} => small mu_a42
% #########################################

% #############################################################
% not used: M-ASK is not my concern
% AM is 'amfc'(am with full carrier), which is not my concern
% my concern is 'amsc'(am with suppressed carrier)
% #############################################################
% mu_a42 = 0;

% amplitude of iq sample
amp_iq = abs(iq);

% mean of amplitude of iq sample
mu_iq = mean(amp_iq);
% mu_iq = sum(amp_iq) / sample_length;

% normalized and centered instantenous amplitude of iq sample
cn_amp_iq = (amp_iq / mu_iq) - 1;

mu_a42 = mean(cn_amp_iq.^4) / (mean(cn_amp_iq.^2)^2);

end

%% 
function [mu_f42] = feature_mu_f42(iq, fs)
%
% [input]
% - iq: iq sample. dimension = 1 * iq_sample_length
% - fs: sample rate
%
% [output]
% - mu_f42: dimension = scalar
%

% #########################################
% see [reference (1)] eq(5.17)
% reference (1) page 70: 
% {FM, AM} => large mu_f42
% {M-FSK} => small mu_f42
% #########################################

% #######################################################################################
% computation show bad result:
% modulation_name_cell = {'amsc','ssb','nbfm','wbfm','bpsk','qpsk','2fsk','4fsk','16qam'}
% mu_f42 = 3.9525, 35.3762, 3.0111, 56.9378, 3.8478, 14.9876, 6.1242, 3.4636, 25.4112
%
% (confining iq phasor in 1st quadrant)
% mu_f42 = 12.6205, 7.7217, 3.2382, 3.0485, 17.6126, 7.5508, 1.0498, 2.1093, 6.5132
% #######################################################################################

% #########################
% remove feature
% #########################
% mu_f42 = 0;

% get freq which is phase difference
freq_iq = diff(angle(iq)) * fs;

% centered instantenous freq using freq mean: see reference (1), eq.(5.13)
freq_iq = freq_iq - mean(freq_iq);

% freq is normalized by fs: see reference (1), eq.(5.12)
freq_iq = freq_iq / fs;

mu_f42 = mean(freq_iq.^4) / (mean(freq_iq.^2)^2);

% % % convert negative real component to positive
% % idx = real(iq) < 0;
% % iq(idx) = complex(real(iq(idx)) * -1, imag(iq(idx)));
% % 
% % % convert negative imaginary component to positive
% % idx = imag(iq) < 0;
% % iq(idx) = complex(real(iq(idx)), imag(iq(idx)) * -1);
% 
% % get freq which is phase difference
% freq_iq = diff(angle(iq)) * fs;
% 
% freq_iq = freq_iq - mean(freq_iq);
% 
% freq_iq = freq_iq / fs;
% 
% mu_f42 = mean(freq_iq.^4) / mean(freq_iq.^2)^2;

end

%% 
function [C20] = feature_C20(iq)
%
% [input]
% - iq: iq sample. dimension = 1 * iq_sample_length
%
% [output]
% - C20: dimension = scalar
%

% #########################################
% see [reference (4)] eq(5)
% #########################################

% #######################################################################################
% computation show:
% modulation_name_cell = {'amsc','ssb','nbfm','wbfm','bpsk','qpsk','2fsk','4fsk','16qam'}
% C20 = 0.2306, 0.1856, 0.0339, 0.4543, 0.5405, 0.3031, 0.6371, 0.6357, 0.2164
% #######################################################################################

sample_length = length(iq);

C20 = sum(iq.^2) / sample_length;
% "abs" make C20 real value, not complex (see [ref (4)] table 1)
C20 = abs(C20);

end

%% 
function [C21] = feature_C21(iq)
%
% [input]
% - iq: iq sample. dimension = 1 * iq_sample_length
%
% [output]
% - C21: dimension = scalar
%

% #########################################
% see [reference (4)] eq(5)
% #########################################

% #######################################################################################
% computation show:
% modulation_name_cell = {'amsc','ssb','nbfm','wbfm','bpsk','qpsk','2fsk','4fsk','16qam'}
% C21 = 0.2111, 0.3834, 0.0444, 0.5560, 0.5408, 0.6359, 1.2643, 1.2688, 0.4720
% #######################################################################################

sample_length = length(iq);
C21 = sum(abs(iq).^2) / sample_length;
C21 = abs(C21);

end

%% 
function [C40] = feature_C40(iq)
%
% [input]
% - iq: iq sample. dimension = 1 * iq_sample_length
%
% [output]
% - C40: dimension = scalar
%

% #########################################
% see [reference (4)] eq(6)
% #########################################

% #######################################################################################
% computation show:
% modulation_name_cell = {'amsc','ssb','nbfm','wbfm','bpsk','qpsk','2fsk','4fsk','16qam'}
% C40 = 
% #######################################################################################

sample_length = length(iq);

C20 = sum(iq.^2) / sample_length;
C21 = abs(sum(iq .* iq(:)') / sample_length);

C40 = sum(iq.^4) / sample_length - 3 * C20^2;
C40 = abs(C40);
C40 = C40 / (C21^2);
end

%% 
function [C41] = feature_C41(iq)
%
% [input]
% - iq: iq sample. dimension = 1 * iq_sample_length
%
% [output]
% - C41: dimension = scalar
%

% #########################################
% see [reference (4)] eq(6)
% #########################################

% #######################################################################################
% computation show:
% modulation_name_cell = {'amsc','ssb','nbfm','wbfm','bpsk','qpsk','2fsk','4fsk','16qam'}
% C41 = 
% #######################################################################################

sample_length = length(iq);

% make mean to zero
iq = iq - mean(abs(iq));

C20 = sum(iq.^2) / sample_length;
C21 = sum(abs(iq).^2) / sample_length;

C41 = abs(sum((iq.^3) .* (iq(:)')) / sample_length) - 3 * C20 * C21;
C41 = abs(C41);
C41 = C41 / (C21^2);
end

%% 
function [C42] = feature_C42(iq)
%
% [input]
% - iq: iq sample. dimension = 1 * iq_sample_length
%
% [output]
% - C42: dimension = scalar
%

% #########################################
% see [reference (4)] eq(6)
% #########################################

% #######################################################################################
% computation show:
% modulation_name_cell = {'amsc','ssb','nbfm','wbfm','bpsk','qpsk','2fsk','4fsk','16qam'}
% C42 = 
% #######################################################################################

sample_length = length(iq);

% make mean to zero
iq = iq - mean(abs(iq));

C20 = sum(iq.^2) / sample_length;
C21 = sum(abs(iq).^2) / sample_length;

C42 = (sum(abs(iq).^4) / sample_length) - abs(C20)^2 - 2 * (C21^2);
C42 = abs(C42);
C42 = C42 / (C21^2);
end

%% 
function [C60] = feature_C60(iq)
%
% [input]
% - iq: iq sample. dimension = 1 * iq_sample_length
%
% [output]
% - C60: dimension = scalar
%

% #########################################
% see [reference (6)] eq(2)
% #########################################

% #######################################################################################
% computation show:
% modulation_name_cell = {'amsc','ssb','nbfm','wbfm','bpsk','qpsk','2fsk','4fsk','16qam'}
% C60 = 
% #######################################################################################

sample_length = length(iq);

% make mean to zero
iq = iq - mean(abs(iq));

M20 = sum(iq.^2) / sample_length;
M40 = sum(iq.^4) / sample_length;
M60 = sum(iq.^6) / sample_length;

C60 = M60 - 15 * M20 * M40 + 3 * M20^3;
C60 = abs(C60);

end

%% 
function [C61] = feature_C61(iq)
%
% [input]
% - iq: iq sample. dimension = 1 * iq_sample_length
%
% [output]
% - C61: dimension = scalar
%

% #########################################
% see [reference (6)] eq(2)
% #########################################

% #######################################################################################
% computation show:
% modulation_name_cell = {'amsc','ssb','nbfm','wbfm','bpsk','qpsk','2fsk','4fsk','16qam'}
% C61 = 
% #######################################################################################

sample_length = length(iq);

% make mean to zero
iq = iq - mean(abs(iq));

M61 = sum(iq.^6 .* iq(:)') / sample_length;
M21 = sum(iq.^2 .* iq(:)') / sample_length;
M40 = sum(iq.^4) / sample_length;
M20 = sum(iq.^2) / sample_length;
M41 = sum(iq.^4 .* iq(:)') / sample_length;

C61 = M61 - 5 * M21 * M40 - 10 * M20 * M41 + 30 * M20^2 * M21;
C61 = abs(C61);

end

%% 
function [C62] = feature_C62(iq)
%
% [input]
% - iq: iq sample. dimension = 1 * iq_sample_length
%
% [output]
% - C62: dimension = scalar
%

% #########################################
% see [reference (6)] eq(2)
% #########################################

% #######################################################################################
% computation show:
% modulation_name_cell = {'amsc','ssb','nbfm','wbfm','bpsk','qpsk','2fsk','4fsk','16qam'}
% C62 = 
% #######################################################################################

sample_length = length(iq);

% make mean to zero
iq = iq - mean(abs(iq));

M62 = sum(iq.^6 .* (iq(:)').^2) / sample_length;
M40 = sum(iq.^4) / sample_length;
M20 = sum(iq.^2) / sample_length;
M42 = sum(iq.^4 .* (iq(:)').^2) / sample_length;
M21 = sum(iq.^2 .* iq(:)') / sample_length;
M41 = sum(iq.^4 .* iq(:)') / sample_length;
M22 = sum(iq.^2 .* (iq(:)').^2) / sample_length;

C62 = M62 - 6 * M20 * M42 - 8 * M21 * M41 - M22 * M40 + 6 * M20^2 * M22 + 24 * M21^2 * M20;
C62 = abs(C62);

end

%% 
function [C63] = feature_C63(iq)
%
% [input]
% - iq: iq sample. dimension = 1 * iq_sample_length
%
% [output]
% - C63: dimension = scalar
%

% #########################################
% see [reference (6)] eq(2)
% #########################################

% #######################################################################################
% computation show:
% modulation_name_cell = {'amsc','ssb','nbfm','wbfm','bpsk','qpsk','2fsk','4fsk','16qam'}
% C63 = 
% #######################################################################################

sample_length = length(iq);

% make mean to zero
iq = iq - mean(abs(iq));

M63 = sum(iq.^6 .* (iq(:)').^3) / sample_length;
M20 = sum(iq.^2) / sample_length;
M42 = sum(iq.^4 .* (iq(:)').^2) / sample_length;
M21 = sum(iq.^2 .* iq(:)') / sample_length;
M41 = sum(iq.^4 .* iq(:)') / sample_length;
M22 = sum(iq.^2 .* (iq(:)').^2) / sample_length;
M43 = sum(iq.^4 .* (iq(:)').^3) / sample_length;

C63 = M63 - 9 * M21 * M42 + 12 * M21^3 - 3 * M20 * M43 - 3 * M22 * M41 + 18 * M20 * M21 * M22;
C63 = abs(C63);

end

