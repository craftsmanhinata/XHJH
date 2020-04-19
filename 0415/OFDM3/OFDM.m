clear all;
clc;

%----------------------------- 初始化参数 ---------------------------------%

NgType=1; % NgType=1/2 for cyclic prefix/zero padding
if NgType==1
    nt='CP';  
elseif NgType==2
    nt='ZP';   
end
I_c=0;   % 0：不编码；1：编码
Ch=1;    % Ch=0/1 for AWGN/multipath channel
if Ch==0, chType='AWGN'; Target_neb=100; 
    else chType='CH'; Target_neb=500; 
end

Inter=0;% 0:不使用交织；1：使用交织

%信道参数
PowerdB=[0 -8 -17 -21 -25]; 
Delay=[0 3 5 6 8];          
Power=10.^(PowerdB/10);     
Ntap=length(PowerdB);       
Lch=Delay(end)+1;    

%信源参数
Nbps=2; M=2^Nbps;  % 调制阶数=2/4/6 for QPSK/16QAM/64QAM
Nfft=64;           % FFT 大小

Ng=Nfft/4;         % 保护间隔长度
Nsym=Nfft+Ng;      % 符号周期
Nvc=Nfft/4;        % 虚拟载波个数，Nvc=0: no virtual carrier
Nused=Nfft-Nvc;    % 用于传输数据的子载波个数
 
EbN0=[0:1:20];    % EbN0
N_iter=1e5;       % 每EbN0迭代次数
Nframe=3;         % 每帧的符号数
sigPow=0;         % 初始信号功率
ber=zeros(1,length(EbN0));

norms=[1 sqrt(2) 0 sqrt(10) 0 sqrt(42)];     % 归一化 BPSK 4-QAM 16-QAM

%------------------------------ 主程序 -----------------------------------%
for i=0:length(EbN0)
    
    rng();
   
   Neb=0; Ntb=0; % number of error/total bits
   
   for m=1:N_iter
      % Tx-----------------------------------------------------------------

      %产生信息比特
      if I_c==1  %编码-----------------------------------------------------
          X= randi([0,1],1,Nused*Nframe*Nbps/3);
          X_code=convolution313(X);
          
      elseif I_c==0 
          X= randi([0,1],1,Nused*Nframe*Nbps);
          X_code=X;
      end
      %交织----------------------------------------------------------------
      if Inter==1
          X_code=interlacecode(X_code,Nused,Nframe*Nbps);
      end
      
      %调制----------------------------------------------------------------
      if Nbps==2
          Xmod= qpsk(X_code)/norms(Nbps);     
      elseif Nbps==4
          Xmod= qam16(X_code)/norms(Nbps);
          Xmod= Xmod.';
      elseif Nbps==6
          Xmod= qam64(X_code)/norms(Nbps);
      end

      if NgType~=2, x_GI=zeros(1,Nframe*Nsym);
            elseif NgType==2, x_GI= zeros(1,Nframe*Nsym+Ng);
        % Extend an OFDM symbol by Ng zeros 
      end
      
      kk1=[1:Nused/2]; kk2=[Nused/2+1:Nused]; kk3=1:Nfft; kk4=1:Nsym;
      for k=1:Nframe
         if Nvc~=0, X_shift= [0 Xmod(kk2) zeros(1,Nvc-1) Xmod(kk1)];
          else      X_shift= [Xmod(kk2) Xmod(kk1)];
         end
         x= ifft(X_shift);
         x_GI(kk4)= guard_interval(Ng,Nfft,NgType,x);
         kk1=kk1+Nused; kk2= kk2+Nused; kk3=kk3+Nfft; kk4=kk4+Nsym;
      end
      
      %信道----------------------------------------------------------------
      if Ch==0, y= x_GI;  % No channel
       else  % Multipath fading channel
        channel=(randn(1,Ntap)+j*randn(1,Ntap)).*sqrt(Power/2);
        h=zeros(1,Lch); h(Delay+1)=channel; % cir: channel impulse response
        y = conv(x_GI,h); 
      end
      if i==0 % Only to measure the signal power for adding AWGN noise
        y1=y(1:Nframe*Nsym); sigPow = sigPow + y1*y1';
        continue;
      end
      
      % 加噪 --------------------------------------------------------------
      if I_c==1
          snr = EbN0(i)+10*log10(Nbps*(Nused/Nfft)/3); % SNR vs. Eb/N0
      elseif I_c==0
          snr = EbN0(i)+10*log10(Nbps*(Nused/Nfft)); % SNR vs. Eb/N0
      end
      
      noise_mag = sqrt((10.^(-snr/10))*sigPow/2);
      y_GI = y + noise_mag*(randn(size(y))+j*randn(size(y)));
      
      % Rx-----------------------------------------------------------------
      kk1=(NgType==2)*Ng+[1:Nsym]; kk2=1:Nfft;
      kk3=1:Nused; kk4=Nused/2+Nvc+1:Nfft; kk5=(Nvc~=0)+[1:Nused/2];
      if Ch==1
         H= fft([h zeros(1,Nfft-Lch)]); 
         H_shift(kk3)= [H(kk4) H(kk5)]; 
      end
      for k=1:Nframe
         Y(kk2)= fft(remove_GI(Ng,Nsym,NgType,y_GI(kk1)));
         Y_shift=[Y(kk4) Y(kk5)];
         if Ch==0,  Xmod_r(kk3) = Y_shift;
          else Xmod_r(kk3)= Y_shift./H_shift;  % 均衡 
         end
         kk1=kk1+Nsym; kk2=kk2+Nfft; kk3=kk3+Nused; kk4=kk4+Nfft; kk5=kk5+Nfft;
      end
      
       %解调---------------------------------------------------------------
       Xmod_r=Xmod_r*norms(Nbps);
      if Nbps==2
          X_r=demoduqpsk(Xmod_r);
      elseif Nbps==4
          X_r=demoduqam16(Xmod_r);
      elseif Nbps==6
          X_r=demoduqam64(Xmod_r);
      end
 
      %解交织--------------------------------------------------------------
      if Inter==1
          X_r=interlacedecode( X_r,Nused,Nframe*Nbps);
      end
      
      
      %译码----------------------------------------------------------------

      if I_c==1
          X_decode=vitebi313(X_r);
          Ntb=Ntb+Nused*Nframe*Nbps/3; 
      elseif I_c==0
          X_decode=X_r;
          Ntb=Ntb+Nused*Nframe*Nbps; 
      end
      
      Neb=Neb+sum(sum(X_decode~=X));
       
      if Neb>Target_neb, break; end
   end
   if i==0
     sigPow= sigPow/Nsym/Nframe/N_iter;
     fprintf('Signal power= %11.3e\n', sigPow);
    
    else
     Ber = Neb/Ntb; 
     ber(i)=Ber;
     fprintf('EbN0=%3d[dB], BER=%4d/%7d =%11.3e\n', EbN0(i), Neb,Ntb,Ber)
    
     if Ber<1e-6,  break;  end
   end
end
%------------------------------- 画图 ------------------------------------%

figure(1);
%画出AWGN与Reyleigh信道的ber曲线对比
ber_AWGN = ber_QAM(EbN0,M,'AWGN');
ber_Rayleigh = ber_QAM(EbN0,M,'Rayleigh');
semilogy(EbN0,ber_AWGN,'m--');
hold on;
semilogy(EbN0,ber_Rayleigh,'r--');

a=[EbN0.',ber.'];
semilogy(a(:,1),a(:,2),'k--s');
grid on

legend('AWGN analytic','Rayleigh fading analytic', 'Simulation');

xlabel('EbN0[dB]');
ylabel('BER');
axis([a(1,1) a(end,1) 1e-5 1]);

%------------------------------- 结束 ------------------------------------%
