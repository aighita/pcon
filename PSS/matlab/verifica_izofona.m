function verifica_izofona
% Teste numerice fara redare audio si fara export de masuratori fictive.
freq=62.5*2.^(0:8);Fs=48000;
for f=freq
    y=ton_izofona(f,30,Fs,.5);
    assert(numel(y)==24000 && iscolumn(y));
    assert(abs(y(1))<1e-12 && abs(y(end))<1e-12);
    assert(max(abs(y))<=10^(-40/20)+1e-12);
end
c.masuratori=struct('frecventa_Hz',{},'nivel_program_dB',{},'referinta_program_dB',{},'moment',{});
for level=29:31
    c.masuratori(end+1)=struct('frecventa_Hz',1000,'nivel_program_dB',level,...
        'referinta_program_dB',30,'moment','test');
end
[T,~]=statistici_izofona(c,30);
assert(T.n(5)==3 && T.nivel_mediu_program_dB(5)==30 && T.deviatie_standard_dB(5)==1);
assert(all(isnan(T.nivel_mediu_program_dB(T.n==0))));
state=struct('nivel',38,'pas',8,'directie',0,'intoarceri',[]);
state=pas_scara_izofona(state,true);assert(state.nivel==30 && state.pas==8);
state=pas_scara_izofona(state,false);assert(state.nivel==34 && state.pas==4);
state=pas_scara_izofona(state,true);assert(state.nivel==32 && state.pas==2);
state=pas_scara_izofona(state,false);assert(state.intoarceri==32 && state.nivel==34);
fprintf('Verificari numerice trecute. Nu au fost redate sunete sau salvate rezultate experimentale.\n');
end
