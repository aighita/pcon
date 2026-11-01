function exporta_izofona(h,final)
% Exporta punctele observate; nu interpoleaza valori lipsa.
if nargin<2, final=false; end
s=guidata(h);c=s.pss;
assert(~isempty(c.masuratori),'Nu exista date experimentale de exportat.');
refs=get(s.phoniPop,'String');ref=str2double(refs{get(s.phoniPop,'Value')});
[T,raw]=statistici_izofona(c,ref);
assert(~isempty(raw),'Nu exista date pentru referinta selectata.');
out=fullfile(c.director,sprintf('referinta_%g',ref));
if ~isfolder(out),mkdir(out);end
writetable(raw,fullfile(out,'masuratori_brute.csv'));
writetable(T,fullfile(out,'curba_izofona.csv'));
sesiune=c; save(fullfile(c.director,'sesiune.mat'),'sesiune');
fig=figure('Visible','off','Color','w','Position',[100 100 1050 650]);
cleanup=onCleanup(@() close(fig));
ax=axes(fig);
traseaza(ax,T,ref);
exportgraphics(fig,fullfile(out,'curba_izofona.png'),'Resolution',200);
exportgraphics(fig,fullfile(out,'curba_izofona.pdf'),'ContentType','vector');
if isfield(s,'axes1') && isgraphics(s.axes1),traseaza(s.axes1,T,ref);end
scrie_raport_izofona(c,T,ref,out,final);
fprintf('Rezultate: %s\n',out);
if final
    if any(T.n<3)
        fprintf('Date incomplete: %d/9 frecvente cu minimum 3 repetari. Vezi raportul.\n',sum(T.n>=3));
    end
    fprintf('Atasamente: curba_izofona.png si raport_experiment.pdf\n');
end
end
function traseaza(ax,T,ref)
cla(ax);hold(ax,'on');
% NaN pastreaza intreruperile curbei la frecventele neobservate.
plot(ax,T.frecventa_Hz,T.nivel_mediu_program_dB,'o-','LineWidth',1.5,'Color',[.1 .35 .65]);
k=T.n>1;
errorbar(ax,T.frecventa_Hz(k),T.nivel_mediu_program_dB(k),...
    T.deviatie_standard_dB(k),'.','Color',[.1 .35 .65],'LineStyle','none');
yline(ax,ref,'--','Referinta la 1 kHz');
set(ax,'XScale','log','XTick',T.frecventa_Hz);
xlim(ax,[62.5 16000]);grid(ax,'on');
xlabel(ax,'Frecventa [Hz]');ylabel(ax,'Nivel pe scala programului [dB; necalibrat SPL]');
title(ax,{'Curba orientativa de egala tarie',sprintf('Referinta: 1 kHz, %g dB pe scala programului; bare: +/-1 SD',ref)});
hold(ax,'off');
end
