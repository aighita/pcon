function salveaza_grafice(d,out,name,cfg)
t=(0:numel(d.x)-1)'/d.fs;
fig=figure('Visible','off','Color','w','Position',[50 50 1200 800]);
cl=onCleanup(@() close(fig));tiledlayout(3,1,'TileSpacing','compact');
nexttile;plot(t,d.x);grid on;title([name ': semnalul in timp'],'Interpreter','none');ylabel('Amplitudine');hold on;
for s=d.selected
    xline(s.t_end,':',sprintf('m=%d',s.m),'LabelOrientation','aligned');
end
nexttile;plot(t,d.energy);grid on;ylabel('E(m) [unitati^2]');title(sprintf('Energie pe termen scurt, N=%d, %.3f ms',d.N,1000*d.N/d.fs));
nexttile;plot(t,10*log10(max(d.energy,realmin)/max(max(d.energy),realmin)));
grid on;xlabel('Timp [s]');ylabel('10 log10(E/Emax) [dB]');
exportgraphics(fig,fullfile(out,'semnal_energie.png'),'Resolution',150);
exportgraphics(fig,fullfile(out,'semnal_energie.pdf'),'ContentType','vector');clear cl;
rows=numel(d.selected);fig=figure('Visible','off','Color','w','Position',[50 50 1300 max(500,260*rows)]);
cl=onCleanup(@() close(fig));tiledlayout(rows,2,'TileSpacing','compact','Padding','compact');
for k=1:rows
    s=d.selected(k);idx=(s.start+1:s.m+1)';history=max(1,idx(1)-(d.N-2)):s.m+1;
    nexttile;plot(((history-1)-s.m)/d.fs*1000,d.x(history),'Color',[.65 .65 .65]);hold on;
    plot(((idx-1)-s.m)/d.fs*1000,d.x(idx),'Color',[.1 .35 .7]);grid on;
    xline(-(d.N-1)/d.fs*1000,':');xlabel('Timp relativ la m [ms]');ylabel('Amplitudine');
    title(sprintf('%d: %s, m=%d, t=%.6f s',k,s.tip,s.m,s.t_end));
    nexttile;lambda=(0:d.N-2)';
    plot(lambda,s.c2,'Color',[.1 .35 .7],'LineWidth',1);hold on;
    plot(lambda,s.c3,'Color',[.85 .3 .1],'LineWidth',1);grid on;
    if s.valid
        plot(s.lag2,s.c2(s.lag2+1),'o','Color',[.1 .35 .7],'MarkerFaceColor',[.1 .35 .7]);
        plot(s.lag3,s.c3(s.lag3+1),'s','Color',[.85 .3 .1]);
        title(sprintf('F0 v2=%.2f Hz; v3=%.2f Hz',s.f02,s.f03));
    else
        title('F0 nedeterminata / estimare respinsa');
    end
    xlabel('lambda [esantioane]');ylabel('Autocorelatie normalizata');xlim([0 d.N-2]);
    if k==1,legend('r2/r2(0)','r3/r3(0)','Location','best');end
end
sgtitle(sprintf('%s | N=%d | cautare F0: %g-%g Hz',name,d.N,cfg.f0_min_Hz,cfg.f0_max_Hz),'Interpreter','none');
exportgraphics(fig,fullfile(out,'ferestre.png'),'Resolution',150);
exportgraphics(fig,fullfile(out,'ferestre.pdf'),'ContentType','vector');
end
