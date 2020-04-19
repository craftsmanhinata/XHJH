%demoduqpsk.m
%qpsk���
function [complex_signal_matrix_qpsk]=demoduqpsk(Rx_qpsk_complex_symbols)
%ʵ��QPSK���
% ���������Rx_qpsk_complex_symbols      
% ���������complex_signal_matrix_qpsk   
dout_temp(1,:)=real(Rx_qpsk_complex_symbols);
dout_temp(2,:)=imag(Rx_qpsk_complex_symbols);

complex_signal_matrix_qpsk=reshape(dout_temp,1,length(Rx_qpsk_complex_symbols)*2);
for i=1:length(complex_signal_matrix_qpsk)
complex_signal_matrix_qpsk(i)=(complex_signal_matrix_qpsk(i)<0);
end
