clc; clear; close all;

[x, Fs] = audioread("vocale.wav");

figure(1)
plot(x)

m = 2500;
N = 220;
cadru = x(m - N + 1 : m);

figure(2)
plot(cadru)

lambdaMax = 30;
r1 = acor1(x, m, N, 0, lambdaMax);

lambda = 0 : lambdaMax;

figure(3)
plot(lambda, r1)

M = 8;
Rm = toeplitz(r1 (1 : M));
rMf = r1(2 : M + 1).';
Wmf = Rm \ rMf;
a = [1 ; -Wmf];
rMg = r1(M + 1 : -1 : 2).';
Wmg = Rm \ rMg;
b = [-Wmg ; 1];
[a, b]

figure(4)
subplot(121)
zplane(a.', 1)
subplot(122)
zplane(b.', 1)

fm = filter(a, 1, cadru);
gm = filter(b, 1, cadru);
figure(5)
subplot(311)
plot(cadru)
subplot(312)
plot(fm)
subplot(313)
plot(gm)

fm_tot = filter(a, 1, x);
r3x = acor3(x, m, N, 0, N - 1);
r3fm = acor3(fm_tot, m, N, 0, N - 1);

figure(6)
subplot(211)
plot(r3x)
subplot(212)
plot(r3fm)

fm = pcm(fm, 8, 1);

x_rec = filter(1, a, fm);
figure(7)
plot(cadru)
hold on;
plot(x_rec);
legend("original", "reconstruit");

nfft = 2^12;
X = fft(cadru, nfft);
FM = fft(fm, nfft);
HfM = fft(a, nfft);

f = 0 : Fs / nfft : Fs / 2 - Fs / nfft;

figure(8)
plot(f, 20 * log10(abs(X(1 : end / 2))));
hold on;
plot(f, 20 * log10(abs(FM(1 : end / 2))));
plot(f, 20 * log10(abs(1 ./ HfM(1 : end / 2))));
legend("original", "eroare", "invers")

P = zeros(20, 1);
for M = 6 : 20
    Rm = toeplitz(r1(1 : M));
    rMf = r1(2 : M + 1).';
    WMf = Rm \ rMf;
    P(M) = r1(1) - rMf.' * WMf;
end

figure(9)
plot(6 : 20, P(6 : 20))
