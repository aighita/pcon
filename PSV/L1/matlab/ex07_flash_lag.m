function logFrames = ex07_flash_lag(varargin)
% Continuous Flash-Lag demonstration.
%
% ex07_flash_lag('FPS',60,'Speed',6)
%
% Movement:
%   Left -> Right -> Left -> Right ... indefinitely
%
% Controls:
%   SPACE  Pause / Resume
%   C      Static alignment control
%   ESC    Exit and save logs
%
% Both discs are physically aligned when the flash appears.
% Timing is software-based, not hardware-synchronized.

q = inputParser;
addParameter(q,'FPS',60,@(x) isnumeric(x)&&isscalar(x)&&isfinite(x)&&x>=30);
addParameter(q,'Speed',6,@(x) isnumeric(x)&&isscalar(x)&&isfinite(x)&&x>0);
addParameter(q,'Direction',1,@(x) ismember(x,[-1 1]));
parse(q,varargin{:});
o = q.Results;

p = cai_laborator;

% Figure
fig = figure( ...
    'Name','Ex. 7 - Flash-lag', ...
    'Color',[.08 .08 .08], ...
    'NumberTitle','off', ...
    'MenuBar','none', ...
    'ToolBar','none', ...
    'KeyPressFcn',@keyPress, ...
    'Position',[100 100 1100 500]);

ax = axes(fig,'Position',[.04 .10 .92 .80]);
hold(ax,'on');

axis(ax,[-1.1*o.Speed 1.1*o.Speed -1.8 1.8]);
axis(ax,'off');

set(ax,'Color',[.08 .08 .08]);

% Fixation cross
plot(ax,0,1.25,'+', ...
    'Color',[.9 .9 .9], ...
    'MarkerSize',12, ...
    'LineWidth',1.5);

text(ax,0,1.65, ...
    'Fixati crucea; comparati pozitia orizontala a discurilor.', ...
    'Color','w', ...
    'HorizontalAlignment','center');

text(ax,0,-1.5, ...
    'SPACE: pauza | C: control static | ESC: iesire', ...
    'Color',[.85 .85 .85], ...
    'HorizontalAlignment','center');

% Moving disc
mobile = plot(ax,0,.45,'o', ...
    'MarkerSize',18, ...
    'MarkerFaceColor',[.3 1 .3], ...
    'MarkerEdgeColor','none');

% Flash disc
flash = plot(ax,0,-.45,'o', ...
    'MarkerSize',18, ...
    'MarkerFaceColor',[1 .5 .2], ...
    'MarkerEdgeColor','none', ...
    'Visible','off');

status = text(ax,0,-1.1,'', ...
    'Color','w', ...
    'HorizontalAlignment','center');

setappdata(fig,'paused',false);
setappdata(fig,'control',false);

% Timing
FPS = o.FPS;
dt = 1/FPS;

% One traversal takes 2 seconds.
framesPerTraversal = 2*FPS;

% Accumulate logs dynamically
frameLog = [];
cycleLog = [];
nominalLog = [];
submitLog = [];
returnLog = [];
positionLog = [];
flashLog = [];
directionLog = [];

t0 = tic;
shift = 0;
n = 0;

while isgraphics(fig)

    % Pause / static control
    if getappdata(fig,'paused') || getappdata(fig,'control')

        waitStart = tic;

        while isgraphics(fig) && ...
              (getappdata(fig,'paused') || getappdata(fig,'control'))

            if getappdata(fig,'control')
                set(mobile,'XData',0);
                set(flash,'Visible','on');
                set(status,'String','Control: discuri stationare, aliniate');
            else
                set(flash,'Visible','off');
                set(status,'String','Pauza');
            end

            drawnow;
            pause(.01);
        end

        shift = shift + toc(waitStart);

        if ~isgraphics(fig)
            break;
        end
    end

    % Target frame time
    target = n*dt + shift;

    while isgraphics(fig) && toc(t0)<target
        pause(min(.002,max(0,target-toc(t0))));
    end

    if ~isgraphics(fig)
        break;
    end

    % Traversal index (0,1,2,3...)
    traversal = floor(n/framesPerTraversal);

    % Frame within traversal
    localFrame = mod(n,framesPerTraversal);

    % Alternate direction
    direction = o.Direction * (-1)^traversal;

    % Progress: 0 -> 1
    progress = localFrame/framesPerTraversal;

    % Position:
    % Direction +1: -Speed -> +Speed
    % Direction -1: +Speed -> -Speed
    x = direction * (-o.Speed + 2*o.Speed*progress);

    % Flash exactly at center crossing
    flashOn = (localFrame == FPS);

    set(mobile,'XData',x);

    if flashOn
        set(flash,'Visible','on');
    else
        set(flash,'Visible','off');
    end

    if direction == 1
        directionText = 'Stanga -> Dreapta';
    else
        directionText = 'Dreapta -> Stanga';
    end

    set(status,'String',sprintf( ...
        'Traversare %d | %s | %g FPS', ...
        traversal+1,directionText,FPS));

    submitTime = toc(t0);
    drawnow;
    returnTime = toc(t0);

    % Log
    frameLog(end+1,1) = n;
    cycleLog(end+1,1) = traversal+1;
    nominalLog(end+1,1) = n*dt;
    submitLog(end+1,1) = submitTime;
    returnLog(end+1,1) = returnTime;
    positionLog(end+1,1) = x;
    flashLog(end+1,1) = flashOn;
    directionLog(end+1,1) = direction;

    n = n+1;
end

% Construct output table
logFrames = table( ...
    frameLog, ...
    cycleLog, ...
    nominalLog, ...
    submitLog, ...
    returnLog, ...
    positionLog, ...
    flashLog, ...
    directionLog, ...
    'VariableNames',{ ...
        'frame', ...
        'cycle', ...
        'nominal_s', ...
        'submit_s', ...
        'drawnow_return_s', ...
        'moving_x', ...
        'flash_on', ...
        'direction'});

% Save when exiting
writetable(logFrames,fullfile(p.out,'ex07_cadre.csv'));
save(fullfile(p.out,'ex07_flash_lag.mat'),'logFrames','o');

fprintf('Flash-lag: %d cadre inregistrate.\n',n);

if n>1
    fprintf('Interval median drawnow: %.2f ms (tinta %.2f ms).\n', ...
        1000*median(diff(returnLog)),1000/FPS);
end

    function keyPress(~,event)
        switch event.Key
            case 'space'
                setappdata(fig,'paused', ...
                    ~getappdata(fig,'paused'));

            case 'c'
                setappdata(fig,'control', ...
                    ~getappdata(fig,'control'));

            case 'escape'
                close(fig);
        end
    end
end