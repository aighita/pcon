function run_laborator(interactiv)
% Genereaza rezultatele ex. 1-6; optional porneste experimentele.
% Din Command Window: cd PSV; run_laborator(false)
if nargin < 1, interactiv = false; end
addpath(fullfile(fileparts(mfilename('fullpath')), 'matlab'));
assert(license('test','image_toolbox'), 'Este necesar Image Processing Toolbox.');
assert(license('test','signal_toolbox'), 'Este necesar Signal Processing Toolbox.');
ex01_filtrare;
ex02_contrast(interactiv);
ex03_mascare;
ex04_nonindependenta;
ex05_adaptare(interactiv);
ex06_gabor;
if interactiv, ex07_flash_lag; end
fprintf('Rezultatele sunt in PSV/rezultate. Flash-lag: ex07_flash_lag\n');
end
