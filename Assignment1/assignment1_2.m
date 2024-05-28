clear;

% Load the variables ....
load("data2.mat")

% part a
% ------
% To find a vector v such that it suits the conditions, we randomly
% generate a vector and then check it for a set number of iterations
v_found = false;
for attempts=1:1000
    v_t = randn(3,1);
    v_t = v_t / norm(v_t);
    norm_v = norm(v_t);
    norm_Av = norm(A*v_t);

    % Check if v meets the condition
    if norm_v <= 1 && norm_Av > 5
        v_found = true;
        v = v_t;
        break;
    end
end

% part b
% ------
% induced-2 norm of A :- ||Ax1||/||x1|| = 1
% ||Ax2||/||x2|| = 2

[U, S, V] = svd(A,"econ");
% Desired singular values for B
singular_values_B = [2, 1, 0]; % 

% Construct the new diagonal matrix Sigma for B
Sigma_B = diag(singular_values_B);

% % Construct the matrix B
B = U * Sigma_B * V'; 
% not sure how to do this...

% part c
% ------
% CN(C) = 4;
% Cmo



% clear eveything except the required answers
%clearvars -EXCEPT v B C;