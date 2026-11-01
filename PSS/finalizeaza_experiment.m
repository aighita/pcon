function finalizeaza_experiment
% Completeaza observatiile efective si genereaza fisierele de atasat.
addpath(fullfile(fileparts(mfilename('fullpath')),'matlab'));
h = getappdata(groot,'PSS_audiometru');
assert(~isempty(h) && isgraphics(h),'Porniti mai intai run_experiment.');
s = guidata(h);
assert(~isempty(s.pss.masuratori),'Nu exista masuratori memorate.');
a = inputdlg({'Cum ai facut acomodarea inainte de memorarea datelor?',...
    'Ce dificultati ai intampinat efectiv si cum le-ai gestionat? Mentioneaza frecventele omise.'},...
    'Observatiile tale',[3 90;5 90],{s.pss.acomodare,s.pss.observatii});
if isempty(a), return; end
s.pss.acomodare=a{1};s.pss.observatii=a{2};guidata(h,s);
exporta_izofona(h,true);
end
