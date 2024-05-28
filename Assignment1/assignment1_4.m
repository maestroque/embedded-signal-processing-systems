clear;

% Load the variables ....
load("data4.mat")

ones = ones(length(x), 1);
A = [x' y' ones];
% Aw = z'
w = z' \ A;

a = w(1);
b = w(2);
c = w(3);

% clear eveything except the required answers
clearvars -EXCEPT a b c