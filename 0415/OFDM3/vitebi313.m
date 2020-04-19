function Y= vitebi313(X)
len=length(X);
Path=zeros(4,len/3,'int8');    %4���Ҵ�·��
Path_t=zeros(4,len/3,'int8');
Da=0;Db=0;Dc=0;Dd=0;           %�ִ�a,b,c,d�ܺ������� a��״̬00��b��״̬01��c��״̬10��d��״̬11
Pa=1;Pb=2;Pc=3;Pd=4;           %a,b,c,d·��ָ��
for i=1:9                      %��t=3ʱ��ʱ����������9���ַ�����ÿ��״̬��������·��
    T(i)=X(i);
end

%��t=3ʱ��ʱ������a״̬����С��֧��������������С��
tp1=dist313(T,[0 0 0 0 0 0 0 0 0],9);
tp2=dist313(T,[1 1 1 0 1 1 1 1 1],9);
if(tp1<tp2)
    Da=tp1;
    Path(1,1)=0;Path(1,2)=0;Path(1,3)=0;
else
    Da=tp2;
    Path(1,1)=1;Path(1,2)=0;Path(1,3)=0;
end

%��t=3ʱ��ʱ������b״̬����С��֧��������������С��
tp1=dist313(T,[0 0 0 1 1 1 0 1 1],9);
tp2=dist313(T,[1 1 1 1 0 0 1 0 0],9);
if(tp1<tp2)
    Db=tp1;
    Path(2,1)=0;Path(2,2)=1;Path(2,3)=0;
else
    Db=tp2;
    Path(2,1)=1;Path(2,2)=1;Path(2,3)=0;
end

%��t=3ʱ��ʱ������c״̬����С��֧��������������С��
tp1=dist313(T,[0 0 0 0 0 0 1 1 1],9);
tp2=dist313(T,[1 1 1 0 1 1 0 0 0],9);
if(tp1<tp2)
    Dc=tp1;
    Path(3,1)=0;Path(3,2)=0;Path(3,3)=1;
else
    Dc=tp2;
    Path(3,1)=1;Path(3,2)=0;Path(3,3)=1;
end

%��t=3ʱ��ʱ������d״̬����С��֧��������������С��
tp1=dist313(T,[0 0 0 1 1 1 1 0 0],9);
tp2=dist313(T,[1 1 1 1 0 0 0 1 1],9);
if(tp1<tp2)
    Dd=tp1;
    Path(4,1)=0;Path(4,2)=1;Path(4,3)=1;
else
    Dd=tp2;
    Path(4,1)=1;Path(4,2)=1;Path(4,3)=1;
end

%����
Dat=0;Dbt=0;Dct=0;Ddt=0;%��������
fga=0;fgb=0;fgc=0;fgd=0;%·����־
rmSz=int32((len-9)/3);
for i=1:rmSz
    T(1)=X(9+(i-1)*3+1);
    T(2)=X(9+(i-1)*3+2);
    T(3)=X(9+(i-1)*3+3);
    %��t=3+iʱ��ʱ������a״̬����С��֧��������������С��
    tp1=dist313(T,[0 0 0],3)+Da;
    tp2=dist313(T,[1 1 1],3)+Db;
    if(tp1<tp2)
        Dat=tp1;
        fga=0;
    else
        Dat=tp2;
        fga=1;
    end
    %��t=3+iʱ��ʱ������b״̬����С��֧��������������С��
    tp1=dist313(T,[0 1 1],3)+Dc;
    tp2=dist313(T,[1 0 0],3)+Dd;
    if(tp1<tp2)
        Dbt=tp1;
        fgb=0;
    else
        Dbt=tp2;
        fgb=1;
    end
    %��t=3+iʱ��ʱ������c״̬����С��֧��������������С��
    tp1=dist313(T,[1 1 1],3)+Da;
    tp2=dist313(T,[0 0 0],3)+Db;
    if(tp1<tp2)
        Dct=tp1;
        fgc=0;
    else
        Dct=tp2;
        fgc=1;
    end
    %��t=3+iʱ��ʱ������d״̬����С��֧��������������С��
    tp1=dist313(T,[1 0 0],3)+Dc;
    tp2=dist313(T,[0 1 1],3)+Dd;
    if(tp1<tp2)
        Ddt=tp1;
        fgd=0;
    else
        Ddt=tp2;
        fgd=1;
    end
    
    %�����Ҵ�·��
    %a
    if(fga==0)
        Path_t(Pa,:)=Path(Pa,:);
        Path_t(Pa,3+i)=0;
        Da=Dat;
    else
        Path_t(Pa,:)=Path(Pb,:);
        Path_t(Pa,3+i)=0;
        Da=Dat;
    end
    %b
    if(fgb==0)
        Path_t(Pb,:)=Path(Pc,:);
        Path_t(Pb,3+i)=0;
        Db=Dbt;
    else
        Path_t(Pb,:)=Path(Pd,:);
        Path_t(Pb,3+i)=0;
        Db=Dbt;
    end
    %c
    if(fgc==0)
        Path_t(Pc,:)=Path(Pa,:);
        Path_t(Pc,3+i)=1;
        Dc=Dct;
    else
        Path_t(Pc,:)=Path(Pb,:);
        Path_t(Pc,3+i)=1;
        Dc=Dct;
    end
    %d
    if(fgd==0)
        Path_t(Pd,:)=Path(Pc,:);
        Path_t(Pd,3+i)=1;
        Dd=Ddt;
    else
        Path_t(Pd,:)=Path(Pd,:);
        Path_t(Pd,3+i)=1;
        Dd=Ddt;
    end
    %
    Path(Pa,:)=Path_t(Pa,:);
    Path(Pb,:)=Path_t(Pb,:);
    Path(Pc,:)=Path_t(Pc,:);
    Path(Pd,:)=Path_t(Pd,:);
end
k=min([Da Db Dc Dd]);
if(k==Da)
    Y=Path(Pa,:);
end
if(k==Db)
    Y=Path(Pb,:);
end
if(k==Dc)
    Y=Path(Pc,:);
end
if(k==Dd)
    Y=Path(Pd,:);
end
end


