function y = ton_izofona(f,L,Fs,durata)
% Foloseste functiile furnizate amplgen/singen. L este scala PROGRAMULUI.
% A = 10^((L-70)/20), deci nivelul digital de varf este L-70 dBFS.
validateattributes(Fs,{'numeric'},{'scalar','integer','>=',8000,'finite'});
validateattributes(f,{'numeric'},{'scalar','positive','finite','<',Fs/2});
validateattributes(L,{'numeric'},{'scalar','real','finite','<=',70});
validateattributes(durata,{'numeric'},{'scalar','real','finite','>=',0.04});
A = amplgen(L);
y = singen(A,f,Fs,durata);
N = round(Fs*durata);
assert(numel(y)>=N,'Generatorul furnizat nu a produs suficiente esantioane.');
y = y(1:N).'; % singen produce cu un esantion suplimentar
r = min(round(.01*Fs),floor(N/2));
w = .5-.5*cos(pi*(0:r-1)'/(r-1));
y(1:r)=y(1:r).*w; y(end-r+1:end)=y(end-r+1:end).*flipud(w);
assert(max(abs(y))<=1+eps,'Semnalul ar fi limitat la redare.');
end
