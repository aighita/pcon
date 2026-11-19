function rezultat = ex06_gabor
    p = cai_laborator;
    N = 101; f = 5; sigma = N/(2*f);
    [X,Y] = meshgrid(-50:50,-50:50);
    gauss = exp(-(X.^2+Y.^2)/(2*sigma^2));
    vertical = cos(2*pi*f*X/N); horizontal = cos(2*pi*f*Y/N);
    even = gauss.*vertical; odd = gauss.*sin(2*pi*f*X/N);
    rotated = gauss.*horizontal;
    mtfV = fftshift(abs(fft2(even)));
    mtfH = fftshift(abs(fft2(rotated)));
    fx = (-50:50)/N;
    fig = figure('Name','Ex. 6 - Gabor', 'Color','w'); tiledlayout(2,3);
    nexttile; imshow(even,[]); title('Gabor par, benzi verticale');
    nexttile; imshow(odd,[]); title('Gabor impar, cuadratura');
    nexttile; imshow(rotated,[]); title('Gabor rotit 90 grade');
    nexttile; imagesc(fx,fx,mtfV); axis image xy; title('MTF: varfuri pe fx'); xlabel('cicluri/pixel');
    nexttile; imagesc(fx,fx,mtfH); axis image xy; title('MTF: varfuri pe fy'); xlabel('cicluri/pixel');
    nexttile; plot(fx,mtfV(51,:)/max(mtfV(:)),fx,mtfH(51,:)/max(mtfH(:)));
    grid on; legend('Gabor vertical','Gabor orizontal'); title('Sectiune fy=0');
    colormap(fig,gray); salveaza_figura(fig,'ex06_gabor');

    rv = sum(even.*vertical,'all'); rh = sum(even.*horizontal,'all');
    ratio = abs(rh/rv);
    theta = 0:5:180; tuning = zeros(size(theta));
    for k = 1:numel(theta)
        stim = cos(2*pi*f*(cosd(theta(k))*X+sind(theta(k))*Y)/N);
        tuning(k) = abs(sum(even.*stim,'all'))/abs(rv);
    end
    fig = figure('Name','Ex. 6 - selectivitate', 'Color','w');
    plot(theta,tuning,'o-'); xlabel('Unghiul normalei benzilor (grade)');
    ylabel('Raspuns relativ'); grid on; salveaza_figura(fig,'ex06_selectivitate');
    rezultat = struct('raspunsVertical',rv,'raspunsOrizontal',rh,'raport',ratio,...
        'frecventaCicluriPixel',f/N,'sigma',sigma);
    save(fullfile(p.out,'ex06_gabor.mat'),'rezultat','even','odd','rotated','mtfV','mtfH','theta','tuning');
    writetable(struct2table(rezultat),fullfile(p.out,'ex06_raspunsuri.csv'));
    fprintf('Ex.6: Rvertical=%.8g, Rorizontal=%.8g, raport=%.8g\n',rv,rh,ratio);
end
