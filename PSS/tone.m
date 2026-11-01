%Functie care genereaza un ton pur, cu frecventa, nivel in dB si durata
%date
%Apel tone(f0,fs,L,d,printFlag)
%Parametrii de intrare
%   f0 = frecventa tonului
%   fs = frecventa de esantionare
%   L = nivelul in dB (cuprins intre 0 si -Inf)
%          0 dB corespunde amplitudinii maxime 1
%          -Inf dB corespunde amplitudinii minime 0
%   d = durata sinusului [s]
%          Atentie! Acest parametru va fi modificat astfel incat
%          sa se obtina un numar intreg de perioade   
%   printFlag = indicator pentru activarea/inactivarea graficelor
%          = 0 - grafice inactivate
%          = 1 - grafice activate
%Parametrii de iesire
%   x = tonul cu amplitudinea si frecventa corespunzatoare;
%   semnalul scris pe disc in directorul de lucru sub denumirea:
%   'PT_yyHz_xxdB.wav';

function x=tone(f0,fs,L,d,printFlag)
ts=1/fs;%perioada de esantionare
t0=1/f0;%perioada sinusului
if mod(d,ts)~=0
    mod(d,ts)
    d=d-mod(d,ts);%vreau sa obtin numar intreg de perioade de esantionare
end
if mod(d,t0)~=0
    mod(d,t0)
    d=d-mod(d,t0);%vreau sa obtin numar intreg de perioade ale sinusului
end
t=0:1/fs:d;
Aref=1;
A=Aref*10^(L/20);
x=A*sin(2*pi*f0*t);
if printFlag==1
    figure(100)
    plot(t,x)
end
% nume=['PT_' num2str(f0) 'Hz_R+' num2str(L+10) 'dB.wav']; %   PT = pure tone
% wavwrite(x,fs,nume)
