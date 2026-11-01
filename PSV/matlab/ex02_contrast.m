function rezultat = ex02_contrast(interactiv, latimeCm, distantaCm)
% latimeCm este LATIMEA FIZICA A STIMULULUI afisat, nu neaparat a monitorului.
if nargin < 1, interactiv = false; end
if nargin < 2, latimeCm = 40; end
if nargin < 3, distantaCm = 60; end
validateattributes(latimeCm,{'numeric'},{'positive','scalar','finite'});
validateattributes(distantaCm,{'numeric'},{'positive','scalar','finite'});
p = cai_laborator;
fig = figure('Name','Ex. 2 - stimuli', 'Color','w');
tiledlayout(1,3);
for k = 1:3
    f = [2 8 24];
    nexttile; imshow(0.5+0.5*fSin2(0,f(k)),[0 1]);
    title(sprintf('%d cicluri/imagine',f(k)));
end
salveaza_figura(fig,'ex02_sinusoide');
[I,x,C,freq] = campbell_robson;
imwrite(I, fullfile(p.out,'ex02_campbell_robson.png'));
fig = figure('Name','Ex. 2 - Campbell-Robson', 'Color','w');
imshow(I,[0 1]); title('Frecventa creste spre dreapta; contrastul creste in jos');
unghi = 2*atan(latimeCm/(2*distantaCm))*180/pi;
if interactiv
    title({'Marcati anvelopa vizibila, de la stanga la dreapta.', ...
        'Minimum 6 puncte; Enter incheie. Masurati latimea fizica a stimulului!'});
    [px,py] = ginput;
    valid = px>=1 & px<=size(I,2) & py>=1 & py<=size(I,1);
    px = px(valid); py = py(valid);
    [px,ia] = unique(px); py = py(ia);
    assert(numel(px)>=6, 'Sunt necesare minimum 6 abscise distincte valide.');
    fobs = interp1(1:numel(x),freq,px)/unghi;
    prag = interp1(1:numel(C),C,py);
    S = 1./prag;
    sursa = 'Masurare interactiva necalibrata fotometric';
    hold on; plot(px,py,'r.-','LineWidth',1.5);
    salveaza_figura(fig,'ex02_anvelopa_observata');
else
    % Exemplu de lucru, NU rezultate atribuite unui observator real.
    fobs = [0.05 0.2 0.5 1 2 4 8 13.56]';
    S = [3 8 20 45 80 100 55 18]';
    prag = 1./S;
    sursa = 'Curba ilustrativa, fara masurare umana';
end
nyquistCpd = ((size(I,2)-1)/2)/unghi;
fNorm = fobs/nyquistCpd;
edges = [0 .10 .14 .24 .28 .40 .44 .58 .62 .78 .82 1];
gain = interp1(fNorm, S/max(S), edges, 'linear', 'extrap');
gain = min(1,max(0,gain));
% FIR equiripple Remez, 6 benzi cu tranzitii libere intre ele.
b = firpm(80, edges, gain, ones(1,6));
h2 = ftrans2(b);
g = im2double(rgb2gray(imread(fullfile(p.images,'buildings_original.bmp'))));
filtered = imfilter(g,h2,'symmetric','conv');
[H,w] = freqz(b,1,2048);
fig = figure('Name','Ex. 2 - CSF si Remez', 'Color','w');
tiledlayout(2,2);
nexttile; loglog(fobs,S,'o-'); grid on; xlabel('cpd'); ylabel('1/C prag'); title(sursa);
nexttile; plot(w/pi,abs(H)); hold on; plot(edges,gain,'o');
xlabel('f / f Nyquist'); ylabel('Modul'); title('Remez si tinta normalizata'); grid on;
nexttile; imshow(g,[0 1]); title('Original');
nexttile; imshow(filtered,[0 1]); title('Filtrata (aceeasi scala, cu limitare la afisare)');
salveaza_figura(fig,'ex02_csf_remez');
rezultat = struct('sursa',sursa,'frecventaCpd',fobs,'prag',prag,...
    'sensibilitate',S,'unghiGrade',unghi,'b',b,'h2',h2);
save(fullfile(p.out,'ex02_contrast.mat'),'rezultat','filtered');
writetable(table(fobs,prag,S,'VariableNames',{'cpd','contrast_prag','sensibilitate'}),...
    fullfile(p.out,'ex02_csf.csv'));
end
