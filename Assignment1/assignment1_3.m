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
%using e1, e2 and e3 from above
% to choose the vector x with induced norm ||Ax||/||x|| = root(13/2) 
% = 2.549509; Will be a linear combination of the vectors corresponding to singular values 3 and 2
x = e3(:,1)+e3(:,2);
%checking if it meets the condition
if(norm(A*x)/norm(x) - round(sqrt(13/2), 4) < 0.0001)
   fprintf('the vector x meets the condition \n')
else
   fprintf('the vector x does not meet the condition \n')
end

% part e
b = zeros(size(A, 1), 1);
y = pinv(A) * b;

r = rand(size(A, 1), 1);
r = r - A * (pinv(A) * r);
r = r / norm(r);

b = A * y + r;

assert(round(norm(A * (pinv(A) * b) - b)) - 1 < 1e-10, 'b is not correct');

% clear eveything except the required answers
clearvars -EXCEPT U V A x b;
