function [E,P] = energie_termen_scurt(x,N)
% E(m)=sum_{n=m-N+1}^m |x(n)|^2; P(m)=E(m)/N, ec. (2.75)-(2.76).
% Fereastra dreptunghiulara, pas de un esantion, completare initiala cu zerouri.
validateattributes(N,{'numeric'},{'scalar','integer','positive'});
x=x(:);E=filter(ones(N,1),1,abs(x).^2);P=E/N;
end
