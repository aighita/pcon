function [T,raw] = statistici_izofona(c,referinta)
% Media aritmetica in dB a ajustarilor repetate (nu media energiei).
raw = struct2table(c.masuratori);
raw = raw(raw.referinta_program_dB==referinta,:);
f = (62.5*2.^(0:8))';
n=zeros(9,1);m=nan(9,1);sd=m;
for k=1:9
    v=raw.nivel_program_dB(raw.frecventa_Hz==f(k));
    n(k)=numel(v);
    if n(k)>0, m(k)=mean(v); end
    if n(k)>1, sd(k)=std(v,0); end
end
T=table(f,n,m,sd,m-referinta,m-70,'VariableNames',...
    {'frecventa_Hz','n','nivel_mediu_program_dB','deviatie_standard_dB',...
    'diferenta_fata_de_referinta_dB','nivel_digital_varf_dBFS'});
end
