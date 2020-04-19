function dout=interlacedecode(din,m,n)
%实现信道的交织解码

%+++++++++++++++++++++++variables++++++++++++++++++++++++++++
% din        输入数据
% m          交织器的行值
% n          交织器的列值
% dout       输出数据
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 

temp=reshape(din,m,n);
for j=1:m
     dout_temp(j*n-(n-1):j*n)=temp(j,: );
end

dout=dout_temp(1:end);
