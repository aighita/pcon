function ex03_mascare
p = cai_laborator;
state = rng; restore = onCleanup(@() rng(state));
rng(2026,'twister');
g = im2double(rgb2gray(imread(fullfile(p.images,'lighthouse2.bmp'))));
assert(isequal(size(g),[512 768]),'Se asteapta imaginea 512x768 din laborator.');
noise = 0.06*randn(128,768); % alb gaussian, medie zero, aceeasi realizare
top = g; bottom = g;
top(1:128,:) = min(1,max(0,g(1:128,:)+noise));
bottom(385:512,:) = min(1,max(0,g(385:512,:)+noise));
fig = figure('Name','Ex. 3 - far', 'Color','w'); tiledlayout(1,3);
nexttile; imshow(g,[0 1]); title('Original');
nexttile; imshow(top,[0 1]); title('Zgomot pe cer: vizibilitate mare');
nexttile; imshow(bottom,[0 1]); title('Zgomot pe textura: mascare');
salveaza_figura(fig,'ex03_lighthouse');
% Imagine proprie sintetica: aceeasi medie, zona uniforma si zona texturata.
[X,Y] = meshgrid(0:767,0:511);
own = 0.5*ones(512,768);
texture = 0.18*sin(2*pi*X/9).*cos(2*pi*Y/11) + 0.09*randn(512,768);
own(257:end,:) = min(0.85,max(0.15,0.5+texture(257:end,:)));
imwrite(own,fullfile(p.out,'ex03_imagine_proprie.png'));
a = own; b = own; cols = 193:576; rows1 = 65:192; rows2 = 321:448;
block = noise(:,1:numel(cols));
a(rows1,cols) = min(1,max(0,own(rows1,cols)+block));
b(rows2,cols) = min(1,max(0,own(rows2,cols)+block));
fig = figure('Name','Ex. 3 - imagine proprie sintetica', 'Color','w'); tiledlayout(1,3);
nexttile; imshow(own,[0 1]); title('Imagine proprie sintetica');
nexttile; imshow(a,[0 1]); title('Bloc pe zona uniforma');
nexttile; imshow(b,[0 1]); title('Acelasi bloc pe textura');
salveaza_figura(fig,'ex03_proprie');
save(fullfile(p.out,'ex03_mascare.mat'),'noise','g','top','bottom','own','a','b');
end
