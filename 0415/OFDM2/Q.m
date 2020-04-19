function Q=Q(x)
% Q function, the function is frequently used 
% for the area under the tail of the Gaussian PDF.
% Q(x)=erfc(x/sqrt(2))/2;
% Ref. <Digital Communications> P38-P40.
Q=erfc(x/sqrt(2))/2.0;