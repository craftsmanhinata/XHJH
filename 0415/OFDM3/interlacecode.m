function dout=interlacecode(din,m,n)
%ʵ���ŵ��Ľ�֯����
%dinΪ���뽻֯�����������ݣ�m��n�ֱ�Ϊ��֯��������ֵ

%+++++++++++++++++++++++variables++++++++++++++++++++++++++++
% din        ��������
% m          ��֯������ֵ
% n          ��֯������ֵ
% dout       �������
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 

for j=1:m
     temp(j,:)=din(j*n-(n-1):j*n);
end

dout_temp=reshape(temp,1,length(din));
dout=dout_temp(1:end);
