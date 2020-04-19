function dout=interlacecode(din,m,n)
%实现信道的交织编码
%din为输入交织编码器的数据，m，n分别为交织器的行列值

%+++++++++++++++++++++++variables++++++++++++++++++++++++++++
% din        输入数据
% m          交织器的行值
% n          交织器的列值
% dout       输出数据
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 

for j=1:m
     temp(j,:)=din(j*n-(n-1):j*n);
end

dout_temp=reshape(temp,1,length(din));
dout=dout_temp(1:end);
