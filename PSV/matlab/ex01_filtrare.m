function ex01_filtrare

p = cai_laborator;
names = {'gaudi','zaha'};

for k = 1:numel(names)
    rgb = imread(fullfile(p.images, [names{k} '.bmp']));

    g = im2double(rgb2gray(rgb));
    h = fspecial('gaussian', [13 13], 0.8);
    low = imfilter(g, h, 'symmetric', 'conv');
    high = imfilter(g, fspecial('laplacian', 0.2), 'symmetric', 'conv');
    sharp = imsharpen(g, 'Radius', 1, 'Amount', 1);

    fig = figure('Name',['Ex. 1 - ' names{k}], 'Color','w');
    tiledlayout(2,2);
    nexttile; imshow(g,[0 1]); title('Original: luminanta');
    nexttile; imshow(low,[0 1]); title('Gaussian: 13x13, sigma=0.8');
    nexttile; imshow(high,[]); title('Laplacian semnat (scala proprie)');
    nexttile; imshow(sharp,[0 1]); title('imsharpen');
    salveaza_figura(fig, ['ex01_' names{k}]);
    imwrite(low, fullfile(p.out,[names{k} '_gaussian.png']));
    imwrite(sharp, fullfile(p.out,[names{k} '_sharp.png']));
    save(fullfile(p.out,[names{k} '_filtre.mat']), 'g','low','high','sharp','h');
end
end
