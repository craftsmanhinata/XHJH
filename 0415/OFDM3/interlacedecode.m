function dout=interlacedecode(din,m,n)
%ʵ���ŵ��Ľ�֯����

%+++++++++++++++++++++++variables++++++++++++++++++++++++++++
% din        ��������
% m          ��֯������ֵ
% n          ��֯������ֵ
% dout       �������
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 

temp=reshape(din,m,n);
for j=1:m
     dout_temp(j*n-(n-1):j*n)=temp(j,: );
end

dout=dout_temp(1:end);
