%%%%���õ��Ĵ���16QAM���ݽ���ɶ����Ʊ�����
function [demodu_bit_symble_16]=demoduqam16(Rx_serial_complex_symbols_16)
%���������Rx_serial_complex_symbolsΪ���ն˽��յ��ĸ�16QAM�ź�
%���������demodu_bit_symbleΪ������������
complex_symbols=reshape(Rx_serial_complex_symbols_16,length(Rx_serial_complex_symbols_16),1);
d=1;
mapping=[-3*d 3*d;-d 3*d;d 3*d;3*d 3*d;-3*d d;-d d;d d;3*d d;-3*d -d;-d -d;d -d;3*d -d;-3*d -3*d;-d -3*d;d -3*d;3*d -3*d];
complex_mapping=complex(mapping(:,1),mapping(:,2));
%%%������ӳ�����ת��Ϊ16QAM�ź�
 metrics=zeros(1,16);
 for i=1:length(Rx_serial_complex_symbols_16)
     for j=1:16
          metrics(j)=abs(complex_symbols(i,1)-complex_mapping(j,1));
     end
          [min_metric  decode_symble(i)]= min(metrics) ;  %����ĳ�����������ֵ����decode_symble(i)
 end
  decode_bit_symble=de2bi((decode_symble-1)','left-msb');
  %��16QAM�ź�תΪ�������ź�
  demodu_bit_symble_16=reshape(decode_bit_symble',1,length(Rx_serial_complex_symbols_16)*4);%ת����һ��
