function run_scara
% Supliment optional, dupa ajustare, la ACEEASI referinta si acelasi volum.
root=fileparts(mfilename('fullpath'));addpath(root,fullfile(root,'matlab'));
h=getappdata(groot,'PSS_audiometru');
assert(~isempty(h)&&isgraphics(h),'Rulati mai intai run_experiment si pastrati audiometrul deschis.');
s=guidata(h);c=s.pss;refs=get(s.phoniPop,'String');
ref=str2double(refs{get(s.phoniPop,'Value')});
assert(~isempty(c.masuratori),'Sunt necesare ajustarile initiale pentru alegerea punctelor de pornire.');
[T,raw]=statistici_izofona(c,ref);
assert(~isempty(raw),'Nu exista ajustari pentru referinta selectata. Reveniti la referinta folosita la ajustare.');
out=fullfile(c.director,sprintf('scara_referinta_%g',ref));
if ~isfolder(out),mkdir(out);end
Fs=48000;reference=ton_izofona(1000,ref,Fs,.5);
trace=struct('frecventa_Hz',{},'incercare',{},'nivel_program_dB',{},'pas_dB',{},'test_mai_tare',{});
levels=cell(9,1);est=nan(9,1);sd=est;count=zeros(9,1);abandon=false;
fprintf('Scara: TEST 0.5s, pauza 0.2s, REFERINTA 0.5s. Volumul ramane fix.\n');
fprintf('Raspuns: t=test mai tare; r=referinta mai tare; p=reasculta; s=omite frecventa; q=incheie.\n');
for k=1:9
    baseline=T.nivel_mediu_program_dB(k);
    if isnan(baseline),baseline=ref;end
    state=struct('nivel',min(60,baseline+8),'pas',8,'directie',0,'intoarceri',[]);
    attempt=0;
    while numel(state.intoarceri)<6 && attempt<80
        test=ton_izofona(T.frecventa_Hz(k),state.nivel,Fs,.5);
        player=audioplayer([test;zeros(round(.2*Fs),1);reference],Fs,16);playblocking(player);
        answer=lower(strtrim(input(sprintf('%g Hz, comparatia %d [t/r/p/s/q]: ',T.frecventa_Hz(k),attempt+1),'s')));
        if strcmp(answer,'q'),abandon=true;break;end
        if strcmp(answer,'s'),break;end
        if ~ismember(answer,{'t','r'}),continue;end
        attempt=attempt+1;
        trace(end+1)=struct('frecventa_Hz',T.frecventa_Hz(k),'incercare',attempt,...
            'nivel_program_dB',state.nivel,'pas_dB',state.pas,'test_mai_tare',strcmp(answer,'t')); %#ok<AGROW>
        previous=state.nivel;state=pas_scara_izofona(state,strcmp(answer,'t'));
        % Limita de confort are prioritate fata de convergenta algoritmului.
        if state.nivel>60 || state.nivel< -30
            fprintf('Limita de nivel atinsa: frecventa ramane fara estimare completa.\n');break;
        end
        assert(state.nivel~=previous,'Scara nu a avansat.');
        if ~isempty(trace),writetable(struct2table(trace),fullfile(out,'incercari_scara.csv'));end
    end
    levels{k}=state.intoarceri;count(k)=numel(levels{k});
    if count(k)>=6,est(k)=mean(levels{k});sd(k)=std(levels{k});end
    save(fullfile(out,'scara_sesiune.mat'),'trace','levels','est','sd','count','ref','c');
    if abandon,break;end
end
R=table(T.frecventa_Hz,count,est,sd,'VariableNames',...
    {'frecventa_Hz','numar_intoarceri_fine','nivel_program_dB','SD_intoarceri_dB'});
writetable(R,fullfile(out,'curba_scara.csv'));
if ~isempty(trace),writetable(struct2table(trace),fullfile(out,'incercari_scara.csv'));end
fig=figure('Color','w','Position',[100 100 1000 600]);ax=axes(fig);
semilogx(ax,T.frecventa_Hz,T.nivel_mediu_program_dB,'o-',T.frecventa_Hz,est,'s-','LineWidth',1.5);
grid(ax,'on');set(ax,'XTick',T.frecventa_Hz);xlim(ax,[62.5 16000]);
xlabel(ax,'Frecventa [Hz]');ylabel(ax,'Nivel pe scala programului [dB; necalibrat SPL]');
legend(ax,'Ajustare: media repetarilor','Scara: media a 6 intoarceri fine','Location','best');
title(ax,sprintf('Aceeasi referinta: 1 kHz, %g dB pe scala programului',ref));
exportgraphics(fig,fullfile(out,'comparatie_metode.png'),'Resolution',200);
exportgraphics(fig,fullfile(out,'comparatie_metode.pdf'),'ContentType','vector');
notes=input('Ce dificultati ai intampinat in metoda scarii? ','s');
fid=fopen(fullfile(out,'raport_scara.md'),'w','n','UTF-8');assert(fid>=0);
cl=onCleanup(@() fclose(fid));
fprintf(fid,'# Metoda scarii: supliment experimental\n\nReferinta: 1 kHz, %g pe scala programului.\n\n',ref);
fprintf(fid,'Perechi T-R, durate 500 ms, pauza 200 ms, volum neschimbat fata de ajustare. Pasul scade 8-4-2 dB la primele intoarceri, apoi ramane 2 dB. Nivelul se estimeaza numai dupa sase intoarceri la pasul fin; SD descrie punctele de intoarcere corelate, nu repetari independente.\n\n');
fprintf(fid,'Frecvente cu estimare completa: %d/9. Datele lipsa nu sunt interpolate. Limite: -30 pana la 60 pe scala programului.\n\n',sum(count>=6));
fprintf(fid,'Diferentele intre metode se citesc in comparatie_metode.png. Ajustarea este controlata direct de ascultator; scara stabileste algoritmic nivelul urmator pe baza raspunsului. Nu este garantata egalitatea rezultatelor, din cauza variabilitatii subiective, pasului finit, adaptarii si ordinii experimentelor.\n\n');
fprintf(fid,'Observatii efective ale participantului: %s\n\nRezultatul este necalibrat SPL, fara atribuirea unui nivel absolut in foni.\n',notes);
fprintf('Supliment salvat in %s\n',out);
end
