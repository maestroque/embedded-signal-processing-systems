clear;

% Load the variables ....
load("data4.mat")

a1 = cos(x') .* pi / 180;
a2 = sin(x') .* pi / 180;
a3 = ones(length(x), 1);

A = [a1 a2 a3];
% Aw = z'
% w is the vector containing the a, b, c parameters

w = pinv(A) * z';

a = w(1);
b = w(2);
c = w(3);

% clear eveything except the required answers
clearvars -EXCEPT a b c