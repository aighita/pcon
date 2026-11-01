function s = analizeaza_cadru(x,Fs,N,m,cfg,Emax)
x=x(:);
[r2,r3,c2,c3]=autocorelatii_23(x,N,m);
[l2,p2]=varf_fundamental(c2,Fs,cfg);[l3,p3]=varf_fundamental(c3,Fs,cfg);
idx=(m-N+2:m+1)';coherence=0;
if isfinite(l3)
    j=idx-l3;past=zeros(N,1);ok=j>=1;past(ok)=x(j(ok));
    den=sqrt(sum(x(idx).^2)*sum(past.^2));
    if den>1e-20,coherence=sum(x(idx).*past)/den;end
end
active=r2(1)*N>=Emax*cfg.prag_energie_relativ;
valid=active && isfinite(l2) && isfinite(l3) && coherence>=cfg.prag_periodicitate;
agree=valid && abs(l2-l3)<=max(2,.08*min(l2,l3));
f2=nan;f3=nan;
if valid,f2=Fs/l2;f3=Fs/l3;else,l2=nan;l3=nan;end
s=struct('m',m,'N',N,'start',m-N+1,'t_start',(m-N+1)/Fs,'t_end',m/Fs,...
    'energy',r2(1)*N,'lag2',l2,'lag3',l3,'f02',f2,'f03',f3,...
    'peak2',p2,'peak3',p3,'coherence',coherence,'valid',valid,'agree',agree,...
    'r2',r2,'r3',r3,'c2',c2,'c3',c3,'tip','');
end
