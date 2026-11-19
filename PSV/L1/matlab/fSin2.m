function S = fSin2(fm, fn)
% Sinusoida 128x128: fm cicluri pe verticala, fn pe orizontala.
% Esantioane la pasul 1 pixel; frecvente in cicluri/imagine, NU cpd.
validateattributes(fm, {'numeric'}, {'real','finite','scalar','>',-64,'<',64});
validateattributes(fn, {'numeric'}, {'real','finite','scalar','>',-64,'<',64});
[X,Y] = meshgrid(0:127, 0:127);
S = sin(2*pi*(fm*Y + fn*X)/128);
end
