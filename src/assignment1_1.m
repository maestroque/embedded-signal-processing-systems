clear;

% Load the variables ....
load("../data/data1.mat");

% part a
% ------
kernel = null(A)
%check if they are orthonormal
%check orthogonality:
check = round(kernel(:,1)'*kernel(:,2))
%check if the norms are 1
norm1 = round(norm(kernel(:,1)))
norm2 = round(norm(kernel(:,2)))

if(round(check)==0 && round(norm1) == 1 && round(norm2) == 1)
    fprintf('Dot product of the two vectors.\n')
    a1 = kernel(:,1)
    a2 = kernel(:,2)
else
    fprintf('The vectors in the kernel are not orthonormal.\n');
end

% part b
% ------

% Extract linearly independent columns from B
[q, req_cols] = rref(B);
V = B(:, req_cols);

% part c
% ------
C_t = pinv(C); %pseudo inverse of C
P = C_t * C
[eigen_vectors, eigen_val] = eig(P);
eigen_values = diag(eigen_val); % getting the eigen values

%Now as the eqn is of type C'X = λX (with λ=1), so we get eigen vectors with corresponding
%eigen values close to 1.
[~, idx] = min(abs(eigen_values - 1));
% Select the corresponding eigenvector
x = eigen_vectors(:, idx);
% Normalize the eigenvector to have a norm of 2
x = x * (2 / norm(x));
% part d
% ------
% not sure how to do this

% part e
% ------
% For a vector e4 != 0, if we want [e1 e2 e3 e4] to be linerly dependent,
% e4 should be a linear combination of e1, e2 and e3

e1 = E(:,1);
e2 = E(:,2);
e3 = E(:,3);
l=1;m=1;n=1;
e4 = l*e1 + m*e2 + n*e3;
E2 = [e1 e2 e3 e4];
if(rank(E2) < size(E2,2))
    fprintf("set {e1 e2 e3 e4} is linearly dependent\n")
    e = e4;
end

% clear eveything except the required answers
clearvars -EXCEPT a1 a2 V x U e;
