%%%%将得到的串行16QAM数据解调成二进制比特流
function [demodu_bit_symble_16]=demoduqam16(Rx_serial_complex_symbols_16)
%输入参数：Rx_serial_complex_symbols为接收端接收到的复16QAM信号
%输出参数：demodu_bit_symble为二进制数码流
complex_symbols=reshape(Rx_serial_complex_symbols_16,length(Rx_serial_complex_symbols_16),1);
d=1;
mapping=[-3*d 3*d;-d 3*d;d 3*d;3*d 3*d;-3*d d;-d d;d d;3*d d;-3*d -d;-d -d;d -d;3*d -d;-3*d -3*d;-d -3*d;d -3*d;3*d -3*d];
complex_mapping=complex(mapping(:,1),mapping(:,2));
%%%将数据映射表中转换为16QAM信号
 metrics=zeros(1,16);
 for i=1:length(Rx_serial_complex_symbols_16)
     for j=1:16
          metrics(j)=abs(complex_symbols(i,1)-complex_mapping(j,1));
     end
          [min_metric  decode_symble(i)]= min(metrics) ;  %将离某星座点最近的值赋给decode_symble(i)
 end
  decode_bit_symble=de2bi((decode_symble-1)','left-msb');
  %将16QAM信号转为二进制信号
  demodu_bit_symble_16=reshape(decode_bit_symble',1,length(Rx_serial_complex_symbols_16)*4);%转换成一行
