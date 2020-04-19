function d = dist313(X1,X2,n)%ÇóººÃ÷¾à
sum=0;
for i=1:n
    if X1(i)~=X2(i)
        sum=sum+1;
    end
end
d=sum;
end