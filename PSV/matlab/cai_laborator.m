function p = cai_laborator
% Cai independente de directorul curent.
p.root = fileparts(fileparts(mfilename('fullpath')));
p.images = fullfile(p.root, 'test_images');
p.out = fullfile(p.root, 'rezultate');
if ~isfolder(p.out), mkdir(p.out); end
end
