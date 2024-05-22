clear;

% part a
V = zeros(2, 2);

v1 = [0.9602 -0.2794];
v2 = [-v1(2) v1(1)];
V = [v1; v2];

assert(round(norm(V*V' - eye(2))) < 1e-10, 'V is not unitary');

% part b
R = [1 2 3; 4 5 6; 7 8 9];
[U, ~, ~] = svd(R);
assert(round(norm(U*U' - eye(3))) < 1e-10, 'U is not unitary');

% part c
sigma1 = 3;
sigma2 = 2;

A = U * [sigma1 0; 0 sigma2; 0 0] * conj(V');

[e1, e2, e3] = svd(A);
assert(round(e2(1, 1)) == sigma1, 'Sigma1 is not correct');
assert(round(e2(2, 2)) == sigma2, 'Sigma2 is not correct');
assert(round(norm(e1 - U)) < 1e-10, 'U is not correct');
assert(round(norm(e3 - V)) < 1e-10, 'V is not correct');

% part d


% part e


% clear eveything except the required answers
clearvars -EXCEPT U V A x b;
