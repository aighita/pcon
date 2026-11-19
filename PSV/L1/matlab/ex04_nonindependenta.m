function ex04_nonindependenta
    f = 7;
    s1 = fSin2(0,f);
    s2 = fSin2(0,4*f)+fSin2(0,5*f)+fSin2(0,6*f);

    fig = figure('Name','Ex. 4 - periodicitate', 'Color','w'); tiledlayout(2,1);
    nexttile; imshow(0.5+s1/2,[0 1]); title('f = 7 cicluri/imagine');
    nexttile; imshow(0.5+s2/6,[0 1]); title('4f + 5f + 6f; amplitudine normalizata');
    salveaza_figura(fig,'ex04_periodicitate');
    theta = 67.5;

    % Unghiul BENZILOR fata de Ox, coordonate carteziene (y in sus).
    s3 = fSin2(-f*cosd(theta),-f*sind(theta));
    s4 = fSin2(-f*cosd(-theta),-f*sind(-theta));
    fig = figure('Name','Ex. 4 - orientare', 'Color','w'); tiledlayout(3,1);
    nexttile; imshow(0.5+s3/2,[0 1]); title('Benzi la +67.5 grade');
    nexttile; imshow(0.5+s4/2,[0 1]); title('Benzi la -67.5 grade');
    nexttile; imshow(0.5+(s3+s4)/4,[0 1]); title('Suma: grila si anvelope');
    salveaza_figura(fig,'ex04_orientare');
end
