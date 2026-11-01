function scrie_raport_izofona(c,T,ref,out,final)
% Raport construit EXCLUSIV din datele memorate si observatiile participantului.
if ~final, return; end
if all(T.n>=3)
    status='Toate cele 9 frecvente au minimum 3 ajustari memorate.';
else
    status=sprintf('DATE PARTIALE: %d/9 frecvente au minimum 3 ajustari. Punctele lipsa nu sunt estimate.',sum(T.n>=3));
end
missing=T.frecventa_Hz(T.n==0);
if isempty(missing),missingText='Nicio frecventa omisa.';
else,missingText=['Frecvente fara date: ' strtrim(sprintf('%g Hz; ',missing))];end
if isempty(strtrim(c.observatii))
    observations='Participantul nu a consemnat dificultatile intampinate. Aceasta sectiune necesita completare.';
else
    observations=c.observatii;
end
p={
    'DETERMINAREA EXPERIMENTALA A UNEI CURBE DE EGALA TARIE'
    ['Participant: ' c.participant]
    ['Data exportului: ' char(datetime('now','Format','yyyy-MM-dd HH:mm:ss'))]
    status
    '1. Scop si echipament'
    'Scopul a fost gasirea nivelurilor la care tonurile pure de frecvente diferite sunt percepute la fel de tare ca un ton de referinta fix de 1000 Hz. Experimentul foloseste metoda ajustarii din punctul 1, Desfasurarea lucrarii, pp. 3 si 5 ale materialului de laborator.'
    ['Echipament declarat: ' c.echipament]
    ['Mediu declarat: ' c.mediu]
    ['Volum si procesari audio declarate: ' c.volum]
    ['Acomodare descrisa de participant: ' c.acomodare]
    '2. Procedura'
    sprintf('Referinta selectata: 1000 Hz, nivel %g pe scala programului. In aceasta curba sunt incluse numai ajustarile facute pentru aceasta referinta.',ref)
    'A fost utilizat audiometru.m furnizat, adaptat pentru pastrarea tuturor ajustarilor, redare secventiala si export. Perechea este TEST (500 ms), pauza (200 ms), REFERINTA (500 ms), Fs=48000 Hz. Fiecare ton are rampe cosinus de 10 ms pentru reducerea clicurilor de comutare. Functiile amplgen.m si singen.m furnizate genereaza sinusurile.'
    'Criteriul de memorare este egalitatea subiectiva a tariei, nu aceeasi inaltime a sunetului si nici simpla detectare a tonului. Dupa o modificare a nivelului se cere o noua auditie inainte de memorare. Dupa fiecare memorare nivelul de pornire al repetarii urmatoare este deplasat alternativ cu +/-4 dB, in limitele interfetei.'
    '3. Obtinerea graficului'
    'Sunt vizate frecventele 62.5, 125, 250, 500, 1000, 2000, 4000, 8000 si 16000 Hz. Pentru fiecare frecventa este calculata media aritmetica a nivelurilor in dB ale ajustarilor memorate. Barele reprezinta +/- o deviatie standard esantionala, nu intervale de incredere. La o singura ajustare nu este estimata deviatia standard.'
    'Abscisa este logaritmica, iar ordonata reprezinta nivelul pe scala programului. Punctele lipsa raman NaN si intrerup linia. Nu sunt inlocuite cu valori teoretice. Graficul separat este curba_izofona.png, cu versiune vectoriala curba_izofona.pdf.'
    '4. Niveluri si calibrare'
    sprintf('Generatorul foloseste A=10^((L-70)/20). Referinta L=%g corespunde unui nivel digital de varf de %g dBFS. Acesta nu este un nivel masurat al presiunii sonore.',ref,ref-70)
    'In lipsa unei calibrari acustice la fiecare frecventa, valorile de pe interfata etichetate foni nu sunt foni verificati. Rezultatul este orientativ si caracterizeaza impreuna ascultatorul si lantul de redare. Nu i se atribuie un nivel absolut de X foni si nici unitatea dB SPL. O simpla calibrare la 1 kHz nu elimina raspunsul in frecventa al castilor.'
    '5. Rezultate numerice'
    'f [Hz] | n | medie [dB program] | SD [dB] | diferenta fata de referinta [dB]'
    };
for k=1:height(T)
    p{end+1}=sprintf('%7g | %2d | %8.2f | %6.2f | %+8.2f',T.frecventa_Hz(k),T.n(k),...
        T.nivel_mediu_program_dB(k),T.deviatie_standard_dB(k),T.diferenta_fata_de_referinta_dB(k)); %#ok<AGROW>
end
p=[p;{missingText;'6. Dificultati observate si discutie';observations}];
k=find(T.frecventa_Hz==1000 & T.n>0,1);
if ~isempty(k)
    p{end+1}=sprintf('Control la 1 kHz: media este %.2f, fata de referinta %.2f; diferenta %.2f dB. O abatere nenula poate indica variabilitatea judecatii de egalitate.',T.nivel_mediu_program_dB(k),ref,T.diferenta_fata_de_referinta_dB(k));
end
p=[p;{'Forma curbei nu reprezinta un diagnostic auditiv si nu este impusa sa urmeze o curba standard. Volumul sistemului, zgomotul ambiental, raspunsul castilor, memoria auditiva, ordinea prezentarii si oboseala pot influenta rezultatul. Eventualele dificultati personale sunt cele consemnate mai sus, nu sunt presupuse de program.';...
    '7. Concluzie si resurse';...
    'Graficul rezuma punctele de egalitate subiectiva obtinute prin ajustare. Dispersia repetarilor descrie repetabilitatea in aceasta sesiune; nu elimina eroarea sistematica a sistemului necalibrat. Nu s-a dedus automat o concluzie despre sensibilitatea absoluta a auzului.';...
    'Sursa: Experimente psihoacustice privind trasarea curbelor izofone.pdf, teoria metodei ajustarii si punctul 1 din Desfasurarea lucrarii. Date brute: masuratori_brute.csv; statistici: curba_izofona.csv. Metoda scarii este suplimentara si nu este declarata efectuata in acest raport.'}];
md=fullfile(out,'raport_experiment.md');fid=fopen(md,'w','n','UTF-8');assert(fid>=0,'Nu pot scrie raportul.');
cl=onCleanup(@() fclose(fid));
for k=1:numel(p),fprintf(fid,'%s\n\n',p{k});end
clear cl;
fid=fopen(fullfile(out,'raport_experiment.html'),'w','n','UTF-8');
assert(fid>=0,'Nu pot scrie raportul HTML.');cl=onCleanup(@() fclose(fid));
fprintf(fid,'<!doctype html><html lang="ro"><meta charset="utf-8"><title>Raport experiment izofona</title><style>body{font:16px/1.5 Arial;max-width:950px;margin:40px auto}img{width:100%%}p{white-space:pre-wrap}</style><body>');
for k=1:numel(p),fprintf(fid,'<p>%s</p>',escape(p{k}));end
fprintf(fid,'<img src="curba_izofona.png" alt="Curba experimentala"><p>Grafic obtinut din datele memorate.</p></body></html>');
clear cl;
lines={};
for k=1:numel(p)
    rest=p{k};
    while ~isempty(rest)
        if numel(rest)<=95,lines{end+1}=rest;break;end %#ok<AGROW>
        cut=find(isspace(rest(1:95)),1,'last');if isempty(cut),cut=95;end
        lines{end+1}=strtrim(rest(1:cut));rest=strtrim(rest(cut+1:end)); %#ok<AGROW>
    end
    lines{end+1}=''; %#ok<AGROW>
end
pdf=fullfile(out,'raport_experiment.pdf');
if isfile(pdf),delete(pdf);end
for first=1:62:numel(lines)
    fig=figure('Visible','off','Color','w','Position',[0 0 850 1100]);
    cl=onCleanup(@() close(fig));
    ax=axes(fig,'Position',[.04 .04 .92 .92],'Visible','off');
    text(ax,0,1,strjoin(lines(first:min(first+61,numel(lines))),newline),...
        'Units','normalized','VerticalAlignment','top','Interpreter','none',...
        'FontName','Arial','FontSize',10.5);
    exportgraphics(fig,pdf,'ContentType','vector','Append',first>1,'BackgroundColor','white');
    clear cl;
end
end
function s=escape(s)
s=strrep(s,'&','&amp;');s=strrep(s,'<','&lt;');s=strrep(s,'>','&gt;');
end
