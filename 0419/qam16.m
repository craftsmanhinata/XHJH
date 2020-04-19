%当主程序里bits_per_symbol=4;%每符号含比特数,16QAM调制
%%%%将二进制数码流转换为16QAM信号
function [complex_qam16_data]=qam16(bitdata_16)
%输入参数：bitdata为二进制数码流
%输出参数：complex_qam_data为16QAM复信号
X1=reshape(bitdata_16,4,length(bitdata_16)/4)';%将二进制数码流以4bite分段
d=1;%信号之间的最小距离
%%%%转换4bit二进制码为十进制码1-16，生成mapping映射表中的索引
for i=1:length(bitdata_16)/4
    for j=1:4
        X1(i,j)=X1(i,j)*(2^(4-j));
    end
        source(i,1)=1+sum(X1(i,:));%convert to the number 1 to 16
end
%%%%16QAM映射表，该表中存放的16对，每对包含两个实数，表示星座的位置
mapping=[-3*d 3*d;-d 3*d;d 3*d;3*d 3*d;-3*d d;-d d;d d;3*d d;-3*d -d;-d -d;d -d;3*d -d;-3*d -3*d;-d -3*d;d -3*d;3*d -3*d];

 for i=1:length(bitdata_16)/4
     qam_data(i,:)=mapping(source(i),:);%数据映射
 end
 complex_qam16_data=complex(qam_data(:,1),qam_data(:,2));
 %组合为复数形式，形成16QAM信号

