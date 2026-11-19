function ex05_adaptare
    [X,Y] = meshgrid(1:768,1:768);
    I = 0.5 + 0.4*exp(-((X-544).^2+(Y-230).^2)/(2*35^2)) ...
            - 0.4*exp(-((X-224).^2+(Y-230).^2)/(2*35^2));
    for y = [230 550]
        I((X-384).^2+(Y-y).^2<=4^2) = 0;
    end
    fig = figure('Name','Ex. 5 - adaptare', 'Color','w');
    imshow(I,[0 1]); title('Fixati punctul superior 20 s, apoi punctul inferior');
    salveaza_figura(fig,'ex05_adaptare');
end
