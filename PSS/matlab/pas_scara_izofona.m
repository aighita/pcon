function state=pas_scara_izofona(state, testMaiTare)
% 1-up/1-down: 8 -> 4 -> 2 dB; se mediaza 6 intoarceri la pasul de 2 dB.
if testMaiTare, direction=-1;else,direction=1;end
if state.directie~=0 && direction~=state.directie
    if state.pas==2
        state.intoarceri(end+1)=state.nivel;
    else
        state.pas=state.pas/2;
    end
end
state.directie=direction;
state.nivel=state.nivel+direction*state.pas;
end
