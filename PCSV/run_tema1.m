function run_tema1
% Rezolva punctele 2-7 din tema cu WAV-urile configurate. Nu reda audio automat.
% Punctul 1: implicit se reutilizeaza cele trei inregistrari furnizate.
root=fileparts(mfilename('fullpath'));addpath(fullfile(root,'matlab'));
cfg=jsondecode(fileread(fullfile(root,'configuratie.json')));
assert(cfg.f0_min_Hz>0 && cfg.f0_max_Hz>cfg.f0_min_Hz,'Domeniu F0 invalid.');
base=fullfile(root,'rezultate','matlab');if ~isfolder(base),mkdir(base);end
summary=table;
fid=fopen(fullfile(base,'rezumat.md'),'w','n','UTF-8');assert(fid>=0);cl=onCleanup(@() fclose(fid));
fprintf(fid,'# Tema 1 PCSV — rezultate MATLAB\n\nSurse configurate in configuratie.json. m este indice de la zero, al ULTIMULUI esantion din fereastra. F0=Fs/lambda0. NaN inseamna estimare respinsa sau inexistenta.\n\n');
for k=1:numel(cfg.fisiere)
    entry=cfg.fisiere(k);path=fullfile(root,entry.cale);
    assert(isfile(path),'Nu exista fisierul %s',path);
    [x,Fs]=audioread(path);channels=size(x,2);x=mean(x,2);
    N=round(cfg.N_referinta*Fs/cfg.Fs_referinta);
    assert(N>=3 && numel(x)>=2*N-1,'Fisier prea scurt pentru fereastra si istoricul variantei 3.');
    [E,P]=energie_termen_scurt(x,N);
    selected=selecteaza_ferestre(x,Fs,N,E,cfg,entry.m_manual);
    d=struct('x',x,'fs',Fs,'channels',channels,'N',N,'energy',E,'power',P,'selected',selected);
    [~,name]=fileparts(path);out=fullfile(base,sprintf('%02d_%s',k,name));
    if ~isfolder(out),mkdir(out);end
    T=tabel_rezultate(d,[name '.wav']);
    if width(summary)==0,summary=T;else,summary=[summary;T];end %#ok<AGROW>
    writetable(T,fullfile(out,'ferestre_f0.csv'));
    writetable(table((0:numel(x)-1)'/Fs,E,P,'VariableNames',{'t_s','energie','putere'}),fullfile(out,'energie.csv'));
    for j=1:numel(selected)
        s=selected(j);lambda=(0:N-2)';
        writetable(table(lambda,s.r2,s.r3,s.c2,s.c3,'VariableNames',...
            {'lambda','r2','r3','r2_normalizata','r3_normalizata'}),fullfile(out,sprintf('autocorelatie_%02d.csv',j)));
    end
    salveaza_grafice(d,out,name,cfg);
    save(fullfile(out,'analiza.mat'),'d','T','cfg');
    fprintf(fid,'## %s\n\nFs=%g Hz, N=%d, durata ferestrei=%.3f ms, %d canal(e) initial(e).\n\n',name,Fs,N,1000*N/Fs,channels);
    fprintf(fid,'| m (zero-based) | tip | lambda2 | F0 v2 [Hz] | lambda3 | F0 v3 [Hz] |\n|---|---|---|---|---|---|\n');
    for j=1:height(T)
        fprintf(fid,'| %d | %s | %g | %.2f | %g | %.2f |\n',T.m_0(j),T.tip{j},T.lambda2(j),T.F0_v2_Hz(j),T.lambda3(j),T.F0_v3_Hz(j));
    end
    fprintf(fid,'\nFerestrele automate sunt candidate, nu transcrieri fonetice. Verificati periodicitatea si maximele marcate in ferestre.png.\n\n');
end
writetable(summary,fullfile(base,'rezumat_f0.csv'));
fprintf('Tema rezolvata pentru %d fisiere. Rezultate: %s\n',numel(cfg.fisiere),base);
end
