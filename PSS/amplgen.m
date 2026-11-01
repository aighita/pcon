function A = amplgen(L)

% A = amplgen(L)
% L - nivelul in decibeli
% A - amplitudinea in unitati de masura ( Pa )

A = 10^((L-70)/20);