clc; clear; close all;

% Punctul 1: inregistrarea WAV proprie
folder = fileparts(mfilename('fullpath'));
addpath(folder, '-begin');
[y, Fs] = audioread(fullfile(folder, 'cadru_female.wav'));
y = mean(y, 2); % Stereo -> mono.
t = (0:length(y)-1)' / Fs;

% Punctul 2: semnalul in functie de timp.
figure(1);
plot(t, y); grid on;
xlabel('Timp [s]'); ylabel('Amplitudine');
title('Semnalul inregistrat');

% Punctele 3 si 6: mai multe ferestre, cu m indice MATLAB al finalului.
N = round(220 * Fs / 8000);
lambdaMax = N - 2;
lambda = (0:lambdaMax)';
timpiFinali = [0.6, 4.0, 6.2, 6.4]; % Se adapteaza pentru alta inregistrare.
m = round(timpiFinali(:) * Fs) + 1;
assert(all(m >= N + lambdaMax & m <= length(y)), ...
    'Ferestrele trebuie sa aiba istoric suficient pentru acor3.');
F0_v2 = nan(numel(m), 1);
F0_v3 = nan(numel(m), 1);

figure(2);
tiledlayout(numel(m), 2, 'TileSpacing', 'compact');
for k = 1:numel(m)
    indici = m(k)-N+1:m(k);
    nexttile;
    plot(t(indici), y(indici)); grid on;
    xlabel('Timp [s]'); ylabel('Amplitudine');
    title(sprintf('m = %d, N = %d', m(k), N));

    % Punctul 4: variantele 2 si 3, folosind functiile din lab1.
    r2 = acor2(y, m(k), N, lambdaMax);
    r3 = acor3(y, m(k), N, lambdaMax);
    c2 = nan(size(r2)); c3 = nan(size(r3));
    if r2(1) > 0
        c2 = r2 / r2(1);
        c3 = r3 / r3(1);
    end
    nexttile;
    plot(lambda, c2, lambda, c3); hold on; grid on;
    xlabel('\lambda [esantioane]'); ylabel('Autocorelatie normalizata');
    legend('r_2/r_2(0)', 'r_3/r_3(0)', 'Location', 'best');

    % Punctul 5: F0 = Fs/lambda0; originea nu este perioada fundamentala.
    lag2 = perioada(c2, Fs);
    lag3 = perioada(c3, Fs);
    if isfinite(lag2)
        F0_v2(k) = Fs / lag2;
        plot(lag2, c2(lag2+1), 'bo', 'HandleVisibility', 'off');
    end
    if isfinite(lag3)
        F0_v3(k) = Fs / lag3;
        plot(lag3, c3(lag3+1), 'rs', 'HandleVisibility', 'off');
    end
    title(sprintf('F0 v2 = %.2f Hz; F0 v3 = %.2f Hz', F0_v2(k), F0_v3(k)));
end

% Punctul 6: frecventele determinate pentru fiecare fereastra.
rezultate = table(m, (m-1)/Fs, F0_v2, F0_v3, ...
    'VariableNames', {'m_MATLAB', 't_final_s', 'F0_v2_Hz', 'F0_v3_Hz'});
disp(rezultate);

% Punctul 7: E(m) = sum(|y(n)|^2), n = m-N+1:m (ecuatia 2.76).
% Fereastra dreptunghiulara de N esantioane; zero inaintea semnalului.
E = filter(ones(N, 1), 1, abs(y).^2);
figure(3);
plot(t, E); grid on;
xlabel('Timp [s]'); ylabel('Energie [unitati de amplitudine^2]');
title(sprintf('Energia pe termen scurt: N = %d (%.1f ms)', N, 1000*N/Fs));

function lag = perioada(c, Fs)
    lag = NaN;
    limite = max(1, ceil(Fs/500)):min(numel(c)-2, floor(Fs/60));
    varfuri = limite(c(limite+1) > c(limite) & c(limite+1) >= c(limite+2));
    if isempty(varfuri), return; end
    prag = max(0.6, 0.85 * max(c(varfuri+1)));
    varfuri = varfuri(c(varfuri+1) >= prag);
    if ~isempty(varfuri), lag = varfuri(1); end
end
