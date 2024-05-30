clear;

% Load the variables ....
load("data5.mat")

% part a
W1 = pinv(A1)';

N = size(X1, 2);
E1 = 0;
for i = 1:N
    E1 = E1 + norm(W1' * X1(:, i) - S1(:, i))^2;
end

C1 = W1'*A1 - eye(3);
I1 = sum(sum(C1 .^ 2));

% part b
W2 = (X2*X2')^(-1) * X2 * S2';
N = size(X2, 2);
E2 = 0;
for i = 1:N
    E2 = E2 + norm(W2' * X2(:, i) - S2(:, i))^2;
end

% Calculate estiamte of A2
Cov_X = 1 / N * X2 * X2';
A2 = W2 / Cov_X;

C2 = W2'*A2 - eye(3);
I2 = sum(sum(C2 .^ 2));

% clear eveything except the required answers
clearvars -EXCEPT W1 E1 I1 W2 E2 A2 I2;