function y = remove_GI( Ng,Lsym,NgType,ofdmSym )
%UNTITLED3 此处显示有关此函数的摘要
%   此处显示详细说明
if Ng~=0
    y=ofdmSym(Ng+1:Lsym);
end


end

