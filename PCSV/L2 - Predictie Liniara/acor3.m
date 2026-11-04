function [r3]=acor3(x,m,N,lambdaMin,lambdaMax)
%Estimator 3 pentru functia de autocorelatie
%
%Apel   r3=acor3(x,m,N,lambdaMin,lambdaMax)
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
   r3(k)=0;
   for n=(m-N+1):m
      r3(k)=r3(k)+x(n)*x(n-abs(lambda));
   end
   r3(k)=r3(k)/N;
end
return
