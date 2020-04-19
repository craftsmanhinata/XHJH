N     = 256;
Ncp   = 64;
M     = 16;             %16QAM
Pav   = 2*(M-1)/3.0;    % average power of each subcarrier
PavdB = 10*log10(Pav/N);% average power of time signal in dB
SNRdB = 20;
SNR   = 10.^(SNRdB/10); 
SymbolRate = 20e6;      % Sampling Rate
Ts         = 1/SymbolRate;   
chtype     = 2;         % Channel Type
NoSymbols  = 1000;      % OFDM Symbol number to simulate
% Set channel parametes and Compute theory SER 
if chtype == 1  % AWGN
    % SER of OFDM in AWGN Channel
    Pm = 2*(1-1/sqrt(M))*Q(sqrt(3*SNR/(M-1)));
    thySER   = 1-(1-Pm).^2
    maxChTap = N;
else            % SUI-3
    Tau = [ 0.0 0.4 0.9 ]*1.0e-6;  % tap delay in s
    PdB = [ 0 -5 -10 ];            % power in each tap in dB
    Fdop = 0;                      % Quasi-static channel
    ch   = rayleighchan(Ts, Fdop, Tau, PdB);
    ChFilterDelay = ch.ChannelFilterDelay;
    ChTap    = round(Tau/Ts) + 1;
    maxChTap = max(ChTap);
    % SER of OFDM in Fading Channel
    a2 = 3 * SNR  /(2 * (M-1));
    a  = sqrt (a2);
    thySER = 1/M * ((M-1) - 2 * a * (sqrt(M)-1) ./ sqrt(1+ a2) ...
        - 4 * a .*(sqrt(M)-1)^2 ./ (pi * sqrt(1 + a2)) ...
        .*  atan( a./ sqrt(1+a2)))
end

hzero = zeros(1,maxChTap);
numSimSymbols = 0;
totErrSymbols = 0;
numSimSymbols = 0;

for numSimSymbols = 1 : NoSymbols
    curErrSymbols = 0;
    % Step 1: Generate random digital message
    x = randint(1,N,M); % Message signal
    % Step 2: M-QAM modulation.
    y = qammod(x,M);
    % Step 3: IFFT, generate time field signal, 
    % i.e., modulate at frequency Field, 
    y = ifft(y);         
    sig = [y(N-Ncp+1:end),y];   % Add CP
    % Step 4: Transmit through Channel
    h = hzero;        
    if chtype == 1
        SigCh = sig;
        h(1)  = 1;
        H     = ones(1,N);
    else
        SigCh    = filter(ch, sig);
        h(ChTap) = ch.PathGains;
        H        = fft(h,N);
    end
    % Step 5: AWGN
    SigNoisy = awgn(SigCh,SNRdB,PavdB);
    % Step 6: FFT, Come back to Frequency Field
    SigNoisy = SigNoisy(Ncp+1:end);  % Delete CP
    SigFF    = fft(SigNoisy);
    % Step 7: Frequency domain equalization
    Zzf      = 1./H;
    SigZf    = SigFF .* Zzf;
    % Step 8: Demodulate, to recover the message.
    zzf      = qamdemod(SigZf,M);
    % Step 9: Compute symbol error rate.
    ErrZf    = x - zzf;
    curErrSymbols = length(find(ErrZf~= 0));        
    totErrSymbols = totErrSymbols + curErrSymbols;

    % Step 10: Show simulation results
    curSER = curErrSymbols / N;
    totSER = totErrSymbols / (N*numSimSymbols);
end
totSER