function logFrames = ex07_flash_lag(varargin)
% Demonstratie Flash-lag: obiect mobil si flash aliniate la debutul flash-ului.
% ex07_flash_lag('FPS',60,'Cycles',6,'Speed',6,'Direction',1)
% SPACE pauza; C control static aliniat; ESC inchide.
% Coordonatele sunt unitati grafice, NU grade de unghi vizual.
% drawnow/pause nu asigura sincronizare hardware cu refresh-ul ecranului.
q = inputParser;
addParameter(q,'FPS',60,@(x) isnumeric(x)&&isscalar(x)&&isfinite(x)&&x>=30&&x==fix(x));
addParameter(q,'Cycles',6,@(x) isnumeric(x)&&isscalar(x)&&isfinite(x)&&x>=1&&x==fix(x));
addParameter(q,'Speed',6,@(x) isnumeric(x)&&isscalar(x)&&isfinite(x)&&x>0);
addParameter(q,'Direction',1,@(x) isnumeric(x)&&isscalar(x)&&ismember(x,[-1 1]));
parse(q,varargin{:}); o = q.Results;
p = cai_laborator;
fig = figure('Name','Ex. 7 - Flash-lag', 'Color',[.08 .08 .08],...
    'NumberTitle','off','MenuBar','none','ToolBar','none',...
    'KeyPressFcn',@keyPress, 'Position',[100 100 1100 500]);
ax = axes(fig,'Position',[.04 .10 .92 .80]); hold(ax,'on');
axis(ax,[-1.1*o.Speed 1.1*o.Speed -1.8 1.8]); axis(ax,'off');
set(ax,'Color',[.08 .08 .08]);
plot(ax,0,1.25,'+','Color',[.9 .9 .9],'MarkerSize',12,'LineWidth',1.5);
text(ax,0,1.65,'Fixati crucea; comparati pozitia orizontala a celor doua discuri.',...
    'Color','w','HorizontalAlignment','center');
text(ax,0,-1.5,'SPACE: pauza   |   C: control static   |   ESC: iesire',...
    'Color',[.85 .85 .85],'HorizontalAlignment','center');
% Marime in puncte egala pentru ambele discuri, fara distorsiuni ale axelor.
mobile = plot(ax,0,.45,'o','MarkerSize',18,'MarkerFaceColor',[0.3 1 0.3],...
    'MarkerEdgeColor','none');
flash = plot(ax,0,-.45,'o','MarkerSize',18,'MarkerFaceColor',[1 .5 .2],...
    'MarkerEdgeColor','none','Visible','off');
status = text(ax,0,-1.1,'','Color','w','HorizontalAlignment','center');
setappdata(fig,'paused',false); setappdata(fig,'control',false);
count = 2*o.FPS*o.Cycles;
requested = (0:count-1)'/o.FPS;
actual = nan(count,1); returned = actual; positions = actual;
flashes = false(count,1); cycles = zeros(count,1);
t0 = tic; shift = 0; completed = 0;
for n = 0:count-1
    if ~isgraphics(fig), break; end
    if getappdata(fig,'paused') || getappdata(fig,'control')
        waitStart = tic;
        while isgraphics(fig) && (getappdata(fig,'paused') || getappdata(fig,'control'))
            if getappdata(fig,'control')
                set(mobile,'XData',0); set(flash,'Visible','on');
                set(status,'String','Control: discuri stationare, aliniate fizic');
            else
                set(flash,'Visible','off'); set(status,'String','Pauza');
            end
            drawnow; pause(.01);
        end
        shift = shift + toc(waitStart);
        if ~isgraphics(fig), break; end
    end
    % Nu sarim cadre: astfel nu omitem niciodata cadrul flash-ului.
    target = requested(n+1)+shift;
    while toc(t0)<target && isgraphics(fig)
        pause(min(.002,max(0,target-toc(t0))));
    end
    if ~isgraphics(fig), break; end
    s = flash_lag_stimulus(n,o.FPS,o.Speed,o.Direction);
    set(mobile,'XData',s.x);
    if s.flash, set(flash,'Visible','on'); else, set(flash,'Visible','off'); end
    set(status,'String',sprintf('Ciclu %d/%d | %g cadre/s solicitate',s.cycle,o.Cycles,o.FPS));
    actual(n+1) = toc(t0);
    drawnow; % aceeasi actualizare grafica pentru ambele obiecte
    returned(n+1) = toc(t0);
    positions(n+1) = s.x; flashes(n+1) = s.flash; cycles(n+1) = s.cycle;
    completed = n+1;
end
if isgraphics(fig), close(fig); end
idx = 1:completed;
frame = (0:completed-1)';
logFrames = table(frame,cycles(idx),requested(idx),actual(idx),returned(idx),...
    positions(idx),flashes(idx), 'VariableNames',...
    {'frame','cycle','nominal_s','submit_s','drawnow_return_s','moving_x','flash_on'});
writetable(logFrames,fullfile(p.out,'ex07_cadre.csv'));
save(fullfile(p.out,'ex07_flash_lag.mat'),'logFrames','o');
fprintf('Flash-lag: %d cadre trimise. Jurnalul masoara software-ul, nu debutul fotonic.\n',completed);
if completed>1
    fprintf('Interval median drawnow: %.2f ms (tinta %.2f ms).\n',...
        1000*median(diff(returned(idx))),1000/o.FPS);
end
    function keyPress(~,event)
        switch event.Key
            case 'space', setappdata(fig,'paused',~getappdata(fig,'paused'));
            case 'c', setappdata(fig,'control',~getappdata(fig,'control'));
            case 'escape', close(fig);
        end
    end
end
