function y = singen(A, f, Fs, t)

% y = singen(A, f, Fs, t)
% A - amplitudinea sinusului
% f - frecventa sinusului
% Fs - frecventa de esantionare
% t - timpul in s

% se presupune ca s-a luat masura de precautie ca Fs > 2*f
% si ca Fs/f este natural

N = ceil(t*f)*Fs/f;
n=0:1:N;
y = A*sin(2*pi*f/Fs*n );