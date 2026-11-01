function s = flash_lag_stimulus(frame, fps, speed, direction)
% Geometrie determinista: flash-ul si obiectul mobil au x=0 la debut.
% Un ciclu dureaza 2 secunde, flash-ul exact un cadru.
validateattributes(frame,{'numeric'},{'integer','scalar','nonnegative'});
validateattributes(fps,{'numeric'},{'integer','scalar','>=',30});
validateattributes(speed,{'numeric'},{'positive','finite','scalar'});
assert(isscalar(direction) && ismember(direction,[-1 1]),'Directia trebuie sa fie -1 sau 1.');
period = 2*fps;
k = mod(frame,period);
s = struct('x',direction*speed*(k-fps)/fps,'y',0.45,...
    'flashX',0,'flashY',-0.45,'flash',k==fps,'cycle',floor(frame/period)+1);
end
