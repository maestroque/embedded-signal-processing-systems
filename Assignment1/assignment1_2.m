clear;

% Load the variables ....
load("data2.mat")

% part a
% ------
% To find a vector v such that it suits the conditions, we randomly
% generate a vector and then check it for a set number of iterations
[U, S, V] = svd(A);

v = 0.6 * V(:, 1);
assert(norm(v) <= 1, 'Norm of v is greater than 1');
assert(norm(A * v) / norm(v) > 5, '|Av|/|v| is less than 5');

% v_found = false;
% for attempts=1:1000
%     v_t = randn(3,1);
%     v_t = v_t / norm(v_t);
%     norm_v = norm(v_t);
%     norm_Av = norm(A*v_t);
% 
%     % Check if v meets the condition
%     if norm_v <= 1 && norm_Av > 5
%         v_found = true;
%         v = v_t;
%         break;
%     end
% end

% part b
% ------
% induced-2 norm of B :- ||Bx1||/||x1|| = 1
% ||Bx2||/||x2|| = 2
S_B = diag([2, 1, 0]);
U_B = eye(3)
V_B = eye(3)
B = U_B * S_B *V_B;
% checking if it meets the condition:
x1 = V_B(:,2);
x2 = V_B(:,1);
% gives an error if it doesn't meet the condition
assert(norm(B*x1)/norm(x1) == 1, 'induced norm of B is not correct(1)');
assert(norm(B*x2)/norm(x2) == 2, 'induced norm of B is not correct(2)');


% part c
% ------
% CN(C) = 4; ratio of biggest to lowest singular values
%induced eucliean norm is ||C|| = 3, choose one singular value as 3.
% Given rank =2 ; so two linearly independent columns

% Singular values
sigma1 = 3;
sigma2 = 0.75;  %3 / 4;
sigma3 = 0;

Sigma = diag([sigma1, sigma2, sigma3]);
U = orth(randn(3,3));
V = orth(randn(3,3));
C = U * Sigma * V;

% clear eveything except the required answers
clearvars -EXCEPT v B C;