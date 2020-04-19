%demoduqam64
function [demodu_bit_symble_64]=demoduqam64(Rx_serial_complex_symbols_64)
d=zeros(64,length(Rx_serial_complex_symbols_64));
%D=zeros(64,length(Rx_serial_complex_symbols_64));
m=zeros(1,length(Rx_serial_complex_symbols_64));
temp=[-7-7*1j  -7-5*1j  -7-1j  -7-3*1j  -7+7*1j  -7+5*1j  -7+1j  -7+3*1j...
    -5-7*1j  -5-5*11j  -5-1j  -5-3*1j  -5+7*1j  -5+5*1j  -5+1j  -5+3*1j...
    -1-7*1j  -1-5*1j  -1-1j  -1-3*1j  -1+7*1j  -1+5*1j  -1+1j  -1+3*1j...
    -3-7*1j  -3-5*1j  -3-1j  -3-3*1j  -3+7*1j  -3+5*1j  -3+1j  -3+3*1j...
    7-7*1j   7-5*1j   7-1j   7-3*1j   7+7*1j   7+5*1j   7+1j   7+3*1j...
    5-7*1j   5-5*1j   5-1j   5-3*1j   5+7*1j   5+5*1j   5+1j   5+3*1j...
    1-7*1j   1-5*1j   1-1j   1-3*1j   1+7*1j   1+5*1j   1+1j   1+3*1j...
    3-7*1j   3-5*1j   3-1j   3-3*1j   3+7*1j   3+5*1j   3+1j   3+3*1j ]./sqrt(42);
for i=1:length(Rx_serial_complex_symbols_64)
    for n=1:64
        d(n,i)=(abs(Rx_serial_complex_symbols_64(i)-temp(n))).^2;
    end
    [min_distance,constellation_point] = min(d(:,i)) ;    %D(:,i)=sort(d(:,i));
%排序 (sort the distance in ascending order.)
    m(i) = constellation_point;
end
A=de2bi((0:63),'left-msb');    %%将十进制数转换为二进制数
for i=1:length(Rx_serial_complex_symbols_64)
    DEMOD_OUT(i,:)=A(m(i),:);
end
demodu_bit_symble_64=reshape(DEMOD_OUT',1,length(Rx_serial_complex_symbols_64)*6); %%将解调出的序列按行输出
