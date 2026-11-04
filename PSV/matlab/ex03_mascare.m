function ex03_mascare
    p = cai_laborator;
    a = imread(fullfile(p.images, 'tadao.bmp'));
    [l, latime, canale] = size(a);
    inaltime_zgomot = max(1, floor(l/4));
    noise = 255*uint8(rand(inaltime_zgomot, latime, canale));
    amplitudine_zgomot = 0.09;
    inceput_evidentiere = floor(0.30*l) + 1;
    sus = inceput_evidentiere:(inceput_evidentiere+inaltime_zgomot-1);
    jos = (l-inaltime_zgomot+1):l;

    b = a; c = a;
    b(sus,:,:) = a(sus,:,:)+ amplitudine_zgomot.*noise;
    c(jos,:,:) = a(jos,:,:)+ amplitudine_zgomot.*noise;
    figure('Name','Ex. 3 - Mascare','NumberTitle','off');
    ax_b = subplot(1,2,1); imshow(b),title('Evidentiere')
    ax_c = subplot(1,2,2); imshow(c),title('Mascare')

    salveaza_figura(ax_b, 'Evidentiere');
    salveaza_figura(ax_c, 'Mascare');
end
