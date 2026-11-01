function [r2,r3,c2,c3,lambda] = autocorelatii_23(x,N,m,lambdaMax)
% Ecuatiile (2.50) si (2.52) din platforma. m este indice de la ZERO.
% Fereastra: n=m-N+1:m. In MATLAB: x(m-N+2:m+1).
% Varianta 3 pastreaza istoricul dinaintea ferestrei; nu este xcorr(frame).
if nargin<4,lambdaMax=N-2;end
validateattributes(x,{'numeric'},{'vector','real','finite'});x=x(:);
validateattributes(N,{'numeric'},{'scalar','integer','>=',3});
validateattributes(m,{'numeric'},{'scalar','integer','>=',N-1,'<',numel(x)});
validateattributes(lambdaMax,{'numeric'},{'scalar','integer','nonnegative','<',N});
idx=(m-N+2:m+1)';frame=x(idx);
lambda=(0:lambdaMax)';r2=zeros(size(lambda));r3=r2;
for k=1:numel(lambda)
    lag=lambda(k);i=idx(lag+1:end);
    r2(k)=sum(x(i).*x(i-lag))/(N-lag);
    past=zeros(N,1);j=idx-lag;ok=j>=1;
    past(ok)=x(j(ok)); % x(n)=0 inainte de inceputul fisierului
    r3(k)=sum(frame.*past)/N;
end
if r2(1)>1e-20
    c2=r2/r2(1);c3=r3/r3(1);
else
    c2=nan(size(r2));c3=nan(size(r3));
end
end
