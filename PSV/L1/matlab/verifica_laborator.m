function verifica_laborator
% Verifica invarianti matematici, fara ferestre si fara toolbox-uri.
S = fSin2(0,7);
assert(isequal(size(S),[128 128]));
assert(max(abs(S(1,:)-sin(2*pi*7*(0:127)/128)))<1e-12);
assert(max(abs(S(1,:)-S(end,:)))<1e-12);
[I,~,C,freq] = campbell_robson;
assert(isequal(size(I),[900 1600]));
assert(abs(C(1)-.005)<1e-12 && abs(C(end)-1)<1e-12);
assert(all(diff(C)>0) && all(diff(freq)>0));
assert(min(I(:))>=0 && max(I(:))<=1);
for direction = [-1 1]
    for n = 0:719
        s = flash_lag_stimulus(n,60,6,direction);
        if s.flash, assert(s.x==s.flashX); end
        assert(s.flash==(mod(n,120)==60));
    end
end
[X,Y] = meshgrid(-50:50,-50:50);
g = exp(-(X.^2+Y.^2)/(2*10.1^2));
v = cos(2*pi*5*X/101); h = cos(2*pi*5*Y/101);
k = g.*v;
assert(abs(sum(k.*h,'all')/sum(k.*v,'all'))<1e-3);
assert(max(abs(k-fliplr(k)),[],'all')<1e-12);
fprintf('Toti invariantii matematici au trecut.\n');
end
