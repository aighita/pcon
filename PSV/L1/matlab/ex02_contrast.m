function rezultat = ex02_contrast(latimeCm, distantaCm, interactiv)
% Exemplu automat: ex02_contrast; masurare: ex02_contrast(40,60,true).
% latimeCm este latimea fizica a imaginii afisate, in centimetri.
    if nargin < 1, latimeCm = 40; end
    if nargin < 2, distantaCm = 60; end
    if nargin < 3, interactiv = false; end
    validateattributes(latimeCm,{'numeric'},{'real','positive','scalar','finite'});
    validateattributes(distantaCm,{'numeric'},{'real','positive','scalar','finite'});
    validateattributes(interactiv,{'logical'},{'scalar'});
    p = cai_laborator;
    unghi = 2*atand(latimeCm/(2*distantaCm));

    % Aceeasi medie, doua contraste si trei frecvente: comparatii controlate.
    fig = figure('Name','Ex. 2 - frecventa si contrast','Color','w',...
        'Theme','light','Position',[100 100 1100 650]);
    tiledlayout(2,3);
    for contrast = [0.15 0.8]
        for frecventa = [3 9 27]
            nexttile; imshow(0.5+0.5*contrast*fSin2(0,frecventa),[0 1],'Border','loose');
            title(sprintf('%d cicluri/imagine, C = %.2f',frecventa,contrast));
        end
    end
    salveaza_figura(fig,'ex02_sinusoide');

    [I,~,C,freq] = campbell_robson;
    imwrite(I,fullfile(p.out,'ex02_campbell_robson.png'));
    fig = figure('Name','Ex. 2 - Campbell-Robson','Color','w',...
        'Theme','light','Position',[100 100 1100 650]);
    tiledlayout(1,1); nexttile;
    imshow(I,[0 1],'Border','loose'); hold on;
    if interactiv
        title('Marcati minimum 6 puncte ale limitei vizibile; Enter termina');
        [px,py] = ginput;
        valid = px>=1 & px<=size(I,2) & py>=1 & py<=size(I,1);
        px = px(valid); py = py(valid);
        [px,ordine] = unique(px); py = py(ordine);
        assert(numel(px)>=6,'Sunt necesare minimum 6 abscise distincte in imagine.');
        fobs = interp1(1:size(I,2),freq,px)/unghi;
        prag = interp1(1:size(I,1),C,py);
        S = 1./prag;
        sursa = 'Anvelopa marcata de observator';
    else
        % Date didactice, fara a le prezenta ca masuratori personale.
        fobs = [2 8 20 40 80 160 300 480]'/unghi;
        S = [4 10 25 55 90 100 60 20]';
        prag = 1./S;
        px = 1+(size(I,2)-1)*log(fobs*unghi/freq(1))/log(freq(end)/freq(1));
        py = 1+(size(I,1)-1)*(1-log(prag)/log(C(1)));
        sursa = 'Exemplu ilustrativ, fara masurare umana';
    end
    plot(px,py,'r.-','LineWidth',1.5,'MarkerSize',14);
    title({'Frecventa creste spre dreapta; contrastul creste in jos',sursa});
    salveaza_figura(fig,'ex02_anvelopa');

    g = im2double(im2gray(imread(fullfile(p.images,'tadao.bmp'))));
    % Imaginea de test este privita la aceeasi latime fizica si distanta.
    nyquistCpd = size(g,2)/(2*unghi);
    fTinta = linspace(0,1,257);
    % Prelungire didactica spre zero in afara datelor, nu praguri masurate.
    fExt = max(2*fobs(end),nyquistCpd);
    tinta = interp1([0;fobs;fExt],[0;S/max(S);0],fTinta*nyquistCpd,'pchip');
    [b,eroareRemez] = firpm(80,[0 1],{@raspuns_csf,fTinta,tinta});
    h2 = ftrans2(b);
    % Filtram variatiile de luminanta si pastram separat nivelul mediu.
    medie = mean(g(:));
    filtered = medie+imfilter(g-medie,h2,'symmetric','conv');
    [H,w] = freqz(b,1,2048);
    eroareMaxima = max(abs(abs(H)-interp1(fTinta,tinta,w/pi,'pchip')));

    fig = figure('Name','Ex. 2 - CSF si Remez','Color','w',...
        'Theme','light','Position',[100 100 1100 650]);
    tiledlayout(1,2);
    nexttile; loglog(fobs,S,'o-'); grid on;
    xlabel('Frecventa spatiala (cpd)'); ylabel('Sensibilitate = 1/C prag');
    title(sursa);
    nexttile; plot(fTinta*nyquistCpd,tinta,'--',w/pi*nyquistCpd,abs(H));
    xlabel('Frecventa spatiala (cpd)'); ylabel('Castig normalizat'); grid on;
    legend('CSF tinta','FIR Remez','Location','best');
    title(sprintf('Ordin 80; eroare maxima %.3f',eroareMaxima));
    salveaza_figura(fig,'ex02_csf_remez');

    fig = figure('Name','Ex. 2 - filtrarea imaginii tadao','Color','w',...
        'Theme','light','Position',[100 100 1100 650]);
    tiledlayout(1,2);
    nexttile; imshow(g,[0 1]); title('Original');
    nexttile; imshow(filtered,[0 1]); title('Filtrata dupa CSF');
    salveaza_figura(fig,'ex02_comparatie');
    imwrite(min(1,max(0,filtered)),fullfile(p.out,'ex02_tadao_filtrata.png'));
    rezultat = struct('sursa',sursa,'frecventaCpd',fobs,'prag',prag,...
        'sensibilitate',S,'unghiGrade',unghi,'nyquistCpd',nyquistCpd,...
        'puncteAnvelopa',[px py],'fTinta',fTinta,'tinta',tinta,...
        'eroareRemez',eroareRemez,'eroareMaxima',eroareMaxima,'b',b,'h2',h2);
    save(fullfile(p.out,'ex02_contrast.mat'),'rezultat','filtered');
    writetable(table(fobs,prag,S,'VariableNames',{'cpd','contrast_prag','sensibilitate'}),...
        fullfile(p.out,'ex02_csf.csv'));
end

function [dorinta,pondere] = raspuns_csf(ordin,~,grila,~,fTinta,tinta)
% Raspuns arbitrar pentru algoritmul Remez, pe intreaga banda [0,1].
    if nargin==2 && strcmp(ordin,'defaults')
        dorinta = 'even';
        return
    end
    dorinta = interp1(fTinta,tinta,grila,'pchip');
    pondere = ones(size(grila));
end
