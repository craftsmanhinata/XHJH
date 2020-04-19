%当主程序里bits_per_symbol=2;%每符号含比特数,QPSK调制
function [complex_signal_matrix]=qpsk(baseband_out)
% 输入参数：baseband_out      
% 输出参数：complex_signal_matrix   
baseband_out2=1-2*baseband_out;
din_temp=reshape(baseband_out2,2,length(baseband_out)/2);
complex_signal_matrix=zeros(1,length(baseband_out)/2);
for i=1:length(baseband_out)/2
    complex_signal_matrix(i)=din_temp(1,i)+1i*din_temp(2,i);
end