function [I, x, contrast, freq] = campbell_robson
% Frecventa instantanee in cicluri/latimea imaginii.
Nx = 1600; Ny = 900;
x = linspace(0,1,Nx); y = linspace(0,1,Ny)';
fMin = 0.5; fMax = 500; r = fMax/fMin;
freq = fMin*r.^x;
% Integram frecventa: sin(2*pi*freq.*x) ar fi incorect.
phase = 2*pi*fMin/log(r)*(r.^x - 1);
contrast = exp(log(0.005)*(1-y)); % 0.5% SUS, 100% JOS
I = 0.5 + 0.5*contrast.*sin(phase);
end
