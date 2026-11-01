function selected = selecteaza_ferestre(x,Fs,N,E,cfg,mManual)
% Selectie reproductibila de cadre candidate sonore si doua controale.
% Selectia nu identifica automat fonemul; verificati formele de unda.
Emax=max(E);hop=max(1,round(cfg.hop_secunde*Fs));first=2*N-3;
template=analizeaza_cadru(x,Fs,N,first,cfg,Emax);selected=template([]);
if ~isempty(mManual)
    for m=mManual(:)'
        s=analizeaza_cadru(x,Fs,N,m,cfg,Emax);s.tip='manuala';selected(end+1)=s; %#ok<AGROW>
    end
    return;
end
candidates=template([]);scores=[];
for m=first:hop:numel(x)-1
    if E(m+1)<.04*Emax,continue;end
    s=analizeaza_cadru(x,Fs,N,m,cfg,Emax);
    i=(m-N+3:m+1)';zcr=sum(x(i).*x(i-1)<0)/N;
    if s.agree && zcr<=cfg.prag_zcr_selectie
        candidates(end+1)=s;scores(end+1)=min(s.coherence,1)*sqrt(s.energy/Emax); %#ok<AGROW>
    end
end
if ~isempty(candidates)
    [~,order]=sortrows([-scores(:),[candidates.m]'],[1 2]);
    spacing=round(cfg.separare_ferestre_secunde*Fs);
    for k=order(:)'
        s=candidates(k);
        if isempty(selected) || all(abs(s.m-[selected.m])>=spacing)
            s.tip='candidata sonora';selected(end+1)=s; %#ok<AGROW>
        end
        if numel(selected)>=cfg.numar_ferestre_sonore,break;end
    end
else
    spacing=round(cfg.separare_ferestre_secunde*Fs);
end
bestEnergy=-inf;control=[];
for m=first:hop:numel(x)-1
    if E(m+1)>.02*Emax && E(m+1)<.25*Emax && ...
            (isempty(selected) || all(abs(m-[selected.m])>=spacing))
        s=analizeaza_cadru(x,Fs,N,m,cfg,Emax);
        if ~s.valid && s.energy>bestEnergy,control=s;bestEnergy=s.energy;end
    end
end
if ~isempty(control),control.tip='control neperiodic';selected(end+1)=control;end
indices=first:hop:numel(x)-1;[~,k]=min(E(indices+1));
s=analizeaza_cadru(x,Fs,N,indices(k),cfg,Emax);s.tip='control nivel mic';selected(end+1)=s;
[~,order]=sort([selected.m]);selected=selected(order);
end
