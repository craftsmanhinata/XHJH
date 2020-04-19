fs = 10e3;
t = 0:1/fs:2;
x = vco(sin(2*pi*t),[0.1 0.4]*fs,fs);
stft(x,fs,'Window',kaiser(256,5),'OverlapLength',220,'FFTLength',512);