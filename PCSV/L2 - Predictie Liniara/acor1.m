function [r1]=acor1(x,m,N,lambdaMin,lambdaMax)
%Estimator 1 pentru functia de autocorelatie
%
%Apel   r1=acor1(x,m,N,lambdaMin,lambdaMax)
% 
%x = semnalul (matrice linie sau coloana) pentru care se calculeaza autocorelatia
%m = esantionul de final pentru cadrul de analiza
%N = lungimea cadrului de analiza
%lambdaMin = deplasamentul minim pentru functia de autocorelatie
%lambdaMax = deplasamentul maxim pentru functia de autocorelatie
%r1 = esantioanele functiei de autocorelatie (matrice linie)
%
%Expresia estimatorului
%r(lambda)=1/N*SUM(x(n)*x(n-abs(lambda))
%
%r1(l)=r(lambdaMin)
%r1(2)=r(lambdaMin+1)
%...
%
%
k=0;
for lambda=lambdaMin:lambdaMax
   k=k+1; 
   r1(k)=0;
   for n=(m-N+1+abs(lambda)):m
      r1(k)=r1(k)+x(n)*x(n-abs(lambda));
   end
   r1(k)=r1(k)/N;
end
return
