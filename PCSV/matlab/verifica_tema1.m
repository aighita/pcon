function verifica_tema1
% Teste pentru formule si indecsi; nu necesita toolbox-uri sau redare audio.
x=(1:12)';[r2,r3]=autocorelatii_23(x,4,8,2);
assert(abs(r2(1)-57.5)<1e-12);
assert(abs(r2(3)-55.5)<1e-12);
assert(abs(r3(3)-42.5)<1e-12); % include perechi din AFARA ferestrei
[E,P]=energie_termen_scurt(x,4);
assert(E(9)==230 && P(9)==57.5);
[~,~,c2,c3]=autocorelatii_23(zeros(500,1),220,450);
assert(all(isnan(c2)) && all(isnan(c3)));
Fs=8000;N=220;n=(0:1599)';x=sin(2*pi*100*n/Fs);
[r2,r3,c2,c3]=autocorelatii_23(x,N,1000);
assert(abs(r2(1)-r3(1))<1e-12 && abs(c3(81)-1)<1e-12);
root=fileparts(fileparts(mfilename('fullpath')));
cfg=jsondecode(fileread(fullfile(root,'configuratie.json')));
[l2,~]=varf_fundamental(c2,Fs,cfg);[l3,~]=varf_fundamental(c3,Fs,cfg);
assert(l2==80 && abs(l3-80)<=1); % efect de capat la N=220, 2.75 perioade
[~,~,c2,c3]=autocorelatii_23(x,800,1000);
[l2,~]=varf_fundamental(c2,Fs,cfg);[l3,~]=varf_fundamental(c3,Fs,cfg);
assert(l2==80 && l3==80); % zece perioade: efectul de capat devine suficient de mic
assert(round(220*16000/8000)==440);
fprintf('Formule, normalizare, istoric, energie, semnal nul si sinus de 100 Hz: OK.\n');
end
