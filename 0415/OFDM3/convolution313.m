%信道编码：卷积编码（3,1,3）生成多项式为（5 7 7）（八进制表示）
function Y = convolution313(X)
len = length(X);    %输入数据的长度
Y = zeros(1,len*3); %创建输出数组（全零数组）
T = zeros(1,len+2); %给寄存器输出编号
for i = 3:(len+2)
    T(i) = X(i-2);
end                 %由于寄存器，添0重构输入数组
for i = 1:len
    Y(1+(i-1)*3) = xor(T(i),T(i+2));             %每个比特编码y1输出
    Y(2+(i-1)*3) = xor(xor(T(i),T(i+1)),T(i+2)); %每个比特编码y2输出
    Y(3+(i-1)*3) = xor(xor(T(i),T(i+1)),T(i+2)); %每个比特编码y3输出
end