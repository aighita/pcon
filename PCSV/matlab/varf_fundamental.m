function [lag,value] = varf_fundamental(c,Fs,cfg)
% Primul maxim local suficient de mare in domeniul Fs/fmax ... Fs/fmin.
% Pragul si domeniul sunt euristici de analiza a vocii, nu o certitudine fonetica.
lo=max(1,ceil(Fs/cfg.f0_max_Hz));hi=min(numel(c)-2,floor(Fs/cfg.f0_min_Hz));
peaks=[];
for k=lo:hi
    if c(k+1)>c(k) && c(k+1)>=c(k+2),peaks(end+1)=k;end %#ok<AGROW>
end
lag=nan;value=nan;
if isempty(peaks),return;end
highest=max(c(peaks+1));value=highest;
if highest<cfg.prag_periodicitate,return;end
peaks=peaks(c(peaks+1)>=.85*highest & c(peaks+1)>=cfg.prag_periodicitate);
lag=peaks(1);value=c(lag+1);
end
