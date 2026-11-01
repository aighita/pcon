function c = configuratie_izofona
% Metadate si stocare separata pentru fiecare sesiune.
root = fileparts(fileparts(mfilename('fullpath')));
[~,id] = fileparts(tempname);
c.director = fullfile(root,'rezultate',['sesiune_' char(datetime('now','Format','yyyyMMdd_HHmmss')) '_' id]);
c.participant = 'Nespecificat';
c.echipament = 'Nespecificat';
c.mediu = 'Nespecificat';
c.volum = 'Nespecificat';
c.acomodare = 'Neconfirmata';
c.observatii = '';
c.masuratori = struct('frecventa_Hz',{},'nivel_program_dB',{},'referinta_program_dB',{},'moment',{});
end
