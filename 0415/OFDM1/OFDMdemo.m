clear;
close all;
carrier_count=200;%���ز���
symbols_per_carrier=12;%ÿ���ز���������
bits_per_symbol=4;%ÿ���ź�������,16QAM����
IFFT_bin_length=512;%FFT����
PrefixRatio=1/4;%���������OFDM���ݵı��� 1/6~1/4
GI=PrefixRatio*IFFT_bin_length ;%ÿһ��OFDM������ӵ�ѭ��ǰ׺����Ϊ1/4*IFFT_bin_length  �������������Ϊ128
beta=1/32;%����������ϵ��
GIP=beta*(IFFT_bin_length+GI);%ѭ����׺�ĳ���20
SNR=15; %�����dB
%==================================================
%================�źŲ���===================================
baseband_out_length = carrier_count * symbols_per_carrier * bits_per_symbol;%������ı�����Ŀ
carriers = (1:carrier_count) + (floor(IFFT_bin_length/4) - floor(carrier_count/2));%����Գ����ز�ӳ��  �������ݶ�Ӧ��IFFT������
conjugate_carriers = IFFT_bin_length - carriers + 2;%����Գ����ز�ӳ��  �������Ӧ��IFFT������
rand( 'twister',0);
baseband_out=round(rand(1,baseband_out_length));%��������ƵĶ����Ʊ�����
%==============16QAM����====================================

complex_carrier_matrix=qam16(baseband_out);%������

complex_carrier_matrix=reshape(complex_carrier_matrix',carrier_count,symbols_per_carrier)';%symbols_per_carrier*carrier_count ����

figure(1);
plot(complex_carrier_matrix,'*r');%16QAM���ƺ�����ͼ
axis([-4, 4, -4, 4]);
grid on
%=================IFFT===========================
IFFT_modulation=zeros(symbols_per_carrier,IFFT_bin_length);%��0���IFFT_bin_length IFFT ���� 
IFFT_modulation(:,carriers ) = complex_carrier_matrix ;%δ��ӵ�Ƶ�ź� �����ز�ӳ���ڴ˴�
IFFT_modulation(:,conjugate_carriers ) = conj(complex_carrier_matrix);%�����ӳ��
%========================================================
figure(2);
stem(0:IFFT_bin_length-1, abs(IFFT_modulation(2,1:IFFT_bin_length)),'b*-')%��һ��OFDM���ŵ�Ƶ��
grid on
axis ([0 IFFT_bin_length -0.5 4.5]);
ylabel('Magnitude');
xlabel('IFFT Bin');
title('OFDM Carrier Frequency Magnitude');

figure(3);
plot(0:IFFT_bin_length-1, (180/pi)*angle(IFFT_modulation(2,1:IFFT_bin_length)), 'go')
hold on
stem(0:carriers-1, (180/pi)*angle(IFFT_modulation(2,1:carriers)),'b*-');%��һ��OFDM���ŵ���λ
stem(0:conjugate_carriers-1, (180/pi)*angle(IFFT_modulation(2,1:conjugate_carriers)),'b*-');
axis ([0 IFFT_bin_length -200 +200])
grid on
ylabel('Phase (degrees)')
xlabel('IFFT Bin')
title('OFDM Carrier Phase')
%=================================================================
signal_after_IFFT=ifft(IFFT_modulation,IFFT_bin_length,2);%OFDM���� ��IFFT�任
time_wave_matrix =signal_after_IFFT;%ʱ���ξ�����Ϊÿ�ز���������������ITTF������N�����ز�ӳ�������ڣ�ÿһ�м�Ϊһ��OFDM����
figure(4);
subplot(3,1,1);
plot(0:IFFT_bin_length-1,time_wave_matrix(2,:));%��һ�����ŵĲ���
axis([0, 700, -0.2, 0.2]);
grid on;
ylabel('Amplitude');
xlabel('Time');
title('OFDM Time Signal, One Symbol Period');

%===========================================================
%=====================���ѭ��ǰ׺���׺====================================
XX=zeros(symbols_per_carrier,IFFT_bin_length+GI+GIP);
for k=1:symbols_per_carrier;
    for i=1:IFFT_bin_length;
        XX(k,i+GI)=signal_after_IFFT(k,i);
    end
    for i=1:GI;
        XX(k,i)=signal_after_IFFT(k,i+IFFT_bin_length-GI);%���ѭ��ǰ׺
    end
    for j=1:GIP;
        XX(k,IFFT_bin_length+GI+j)=signal_after_IFFT(k,j);%���ѭ����׺
    end
end

time_wave_matrix_cp=XX;%�����ѭ��ǰ׺���׺��ʱ���źž���,��ʱһ��OFDM���ų���ΪIFFT_bin_length+GI+GIP=660
subplot(3,1,2);
plot(0:length(time_wave_matrix_cp)-1,time_wave_matrix_cp(2,:));%��һ���������ѭ��ǰ׺��Ĳ���
axis([0, 700, -0.2, 0.2]);
grid on;
ylabel('Amplitude');
xlabel('Time');
title('OFDM Time Signal with CP, One Symbol Period');
%==============OFDM���żӴ�==========================================
windowed_time_wave_matrix_cp=zeros(1,IFFT_bin_length+GI+GIP);
for i = 1:symbols_per_carrier 
windowed_time_wave_matrix_cp(i,:) = real(time_wave_matrix_cp(i,:)).*rcoswindow(beta,IFFT_bin_length+GI)';%�Ӵ�  �����Ҵ�
end  
subplot(3,1,3);
plot(0:IFFT_bin_length-1+GI+GIP,windowed_time_wave_matrix_cp(2,:));%��һ�����ŵĲ���
axis([0, 700, -0.2, 0.2]);
grid on;
ylabel('Amplitude');
xlabel('Time');
title('OFDM Time Signal Apply a Window , One Symbol Period');

%========================���ɷ����źţ������任==================================================
windowed_Tx_data=zeros(1,symbols_per_carrier*(IFFT_bin_length+GI)+GIP);
windowed_Tx_data(1:IFFT_bin_length+GI+GIP)=windowed_time_wave_matrix_cp(1,:);
for i = 1:symbols_per_carrier-1 ;
    windowed_Tx_data((IFFT_bin_length+GI)*i+1:(IFFT_bin_length+GI)*(i+1)+GIP)=windowed_time_wave_matrix_cp(i+1,:);%����ת����ѭ����׺��ѭ��ǰ׺�����
end

%=======================================================
Tx_data_withoutwindow =reshape(time_wave_matrix_cp',(symbols_per_carrier)*(IFFT_bin_length+GI+GIP),1)';%û�мӴ���ֻ���ѭ��ǰ׺���׺�Ĵ����ź�
Tx_data =reshape(windowed_time_wave_matrix_cp',(symbols_per_carrier)*(IFFT_bin_length+GI+GIP),1)';%�Ӵ��� ѭ��ǰ׺���׺������ �Ĵ����ź�
%=================================================================
temp_time1 = (symbols_per_carrier)*(IFFT_bin_length+GI+GIP);%�Ӵ��� ѭ��ǰ׺���׺������ ������λ��
figure (5)
subplot(2,1,1);
plot(0:temp_time1-1,Tx_data );%ѭ��ǰ׺���׺������ ���͵��źŲ���
grid on
ylabel('Amplitude (volts)')
xlabel('Time (samples)')
title('OFDM Time Signal')
temp_time2 =symbols_per_carrier*(IFFT_bin_length+GI)+GIP;
subplot(2,1,2);
plot(0:temp_time2-1,windowed_Tx_data);%ѭ����׺��ѭ��ǰ׺����� �����źŲ���
grid on
ylabel('Amplitude (volts)')
xlabel('Time (samples)')
title('OFDM Time Signal')

%=================δ�Ӵ������ź�Ƶ��==================================
symbols_per_average = ceil(symbols_per_carrier/5);%��������1/5��10��
avg_temp_time = (IFFT_bin_length+GI+GIP)*symbols_per_average;%������10�����ݣ�10������
averages = floor(temp_time1/avg_temp_time);
average_fft(1:avg_temp_time) = 0;%�ֳ�5��
for a = 0:(averages-1)
 subset_ofdm = Tx_data_withoutwindow (((a*avg_temp_time)+1):((a+1)*avg_temp_time));%
 subset_ofdm_f = abs(fft(subset_ofdm));%�������źŷֶ���Ƶ��
 average_fft = average_fft + (subset_ofdm_f/averages);%�ܹ������ݷ�Ϊ5�Σ��ֶν���FFT��ƽ�����
end
average_fft_log = 20*log10(average_fft);
figure (6)
subplot(2,1,1);
plot((0:(avg_temp_time-1))/avg_temp_time, average_fft_log)%��һ��  0/avg_temp_time  :  (avg_temp_time-1)/avg_temp_time
hold on
plot(0:1/IFFT_bin_length:1, -35, 'rd')
grid on
axis([0 0.5 -40 max(average_fft_log)])
ylabel('Magnitude (dB)')
xlabel('Normalized Frequency (0.5 = fs/2)')
title('OFDM Signal Spectrum without windowing')
%===============�Ӵ��ķ����ź�Ƶ��=================================
symbols_per_average = ceil(symbols_per_carrier/5);%��������1/5��10��
avg_temp_time = (IFFT_bin_length+GI+GIP)*symbols_per_average;%������10�����ݣ�10������
averages = floor(temp_time1/avg_temp_time);
average_fft(1:avg_temp_time) = 0;%�ֳ�5��
for a = 0:(averages-1)
 subset_ofdm = Tx_data(((a*avg_temp_time)+1):((a+1)*avg_temp_time));%����ѭ��ǰ׺��׺δ���ӵĴ��мӴ��źż���Ƶ��
 subset_ofdm_f = abs(fft(subset_ofdm));%�ֶ���Ƶ��
 average_fft = average_fft + (subset_ofdm_f/averages);%�ܹ������ݷ�Ϊ5�Σ��ֶν���FFT��ƽ�����
end
average_fft_log = 20*log10(average_fft);
subplot(2,1,2)
plot((0:(avg_temp_time-1))/avg_temp_time, average_fft_log)%��һ��  0/avg_temp_time  :  (avg_temp_time-1)/avg_temp_time
hold on
plot(0:1/IFFT_bin_length:1, -35, 'rd')
grid on
axis([0 0.5 -40 max(average_fft_log)])
ylabel('Magnitude (dB)')
xlabel('Normalized Frequency (0.5 = fs/2)')
title('Windowed OFDM Signal Spectrum')
%====================�������============================================
Tx_signal_power = var(windowed_Tx_data);%�����źŹ���
linear_SNR=10^(SNR/10);%��������� 
noise_sigma=Tx_signal_power/linear_SNR;
noise_scale_factor = sqrt(noise_sigma);%��׼��sigma
noise=randn(1,((symbols_per_carrier)*(IFFT_bin_length+GI))+GIP)*noise_scale_factor;%������̬�ֲ���������

%noise=wgn(1,length(windowed_Tx_data),noise_sigma,'complex');%������GAUSS�������ź� 

Rx_data=windowed_Tx_data +noise;%���յ����źż�����
%=====================�����ź�  ��/���任 ȥ��ǰ׺���׺==========================================
Rx_data_matrix=zeros(symbols_per_carrier,IFFT_bin_length+GI+GIP);
for i=1:symbols_per_carrier;
    Rx_data_matrix(i,:)=Rx_data(1,(i-1)*(IFFT_bin_length+GI)+1:i*(IFFT_bin_length+GI)+GIP);%�����任
end
Rx_data_complex_matrix=Rx_data_matrix(:,GI+1:IFFT_bin_length+GI);%ȥ��ѭ��ǰ׺��ѭ����׺���õ������źž���

%============================================================
%================================================================

%==============================================================
%                      OFDM����   16QAM����
%=================FFT�任=================================
Y1=fft(Rx_data_complex_matrix,IFFT_bin_length,2);%OFDM���� ��FFT�任
Rx_carriers=Y1(:,carriers);%��ȥIFFT/FFT�任��ӵ�0��ѡ��ӳ������ز�
Rx_phase =angle(Rx_carriers);%�����źŵ���λ
Rx_mag = abs(Rx_carriers);%�����źŵķ���
figure(7);
polar(Rx_phase, Rx_mag,'bd');%�����������»��������źŵ�����ͼ
%======================================================================


[M, N]=pol2cart(Rx_phase, Rx_mag); 

Rx_complex_carrier_matrix = complex(M, N);
figure(8);
plot(Rx_complex_carrier_matrix,'*r');%XY��������źŵ�����ͼ
axis([-4, 4, -4, 4]);
grid on
%====================16qam���==================================================
Rx_serial_complex_symbols = reshape(Rx_complex_carrier_matrix',size(Rx_complex_carrier_matrix, 1)*size(Rx_complex_carrier_matrix,2),1)' ;

Rx_decoded_binary_symbols=demoduqam16(Rx_serial_complex_symbols);


%============================================================
baseband_in = Rx_decoded_binary_symbols;

figure(9);
subplot(2,1,1);
stem(baseband_out(1:100));
subplot(2,1,2);
stem(baseband_in(1:100));
%================�����ʼ���=============================================
bit_errors=find(baseband_in ~=baseband_out);
bit_error_count = size(bit_errors, 2); 
ber=bit_error_count/baseband_out_length;

