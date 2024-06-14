clear all;

% testCordic_sqrt.m
%
% the following parameters define the fixed point representation of the
% data variables in the computation of the square root
DAT_BW = 12;   % the bit width of the data variables
DAT_FL = 9;    % the fraction length of the data variables
DAT_S = true;  % the signedness of the data variables

% the number of iterations of the CORDIC algorithm
NIter = 6;

% do not change any of the fixed point parameters below this point!
% default parameters for fixed point arithmetic
F = fimath('OverflowAction','Saturate',...
    'ProductMode','SpecifyPrecision',...
    'ProductWordLength', DAT_BW,...2
    'ProductFractionLength', DAT_FL,...
    'SumMode', 'SpecifyPrecision',...
    'SumWordLength', DAT_BW,...
    'SumFractionLength', DAT_FL,...
    'CastBeforeSum', true);


step  = 2^-6;


% input values in the range [.5, 2)
v = 0.02:step:10;
% fixed-point inputs in range [.5, 2)
% v_fixpt = fi(v, DAT_S, DAT_BW);
y_fx = zeros(size(v));
for i=1:numel(v)
   y_fx(i) = sqrt_cordic_widerange_fixpt(v(i), NIter, DAT_BW, DAT_FL, DAT_S, F);
end

abs_err = abs(sqrt(v) - double(y_fx));
figure;

subplot(2, 1, 1);
plot(v, double(y_fx), 'r');
hold on;
plot(v, sqrt(v), 'b');
hold off;
title('CORDIC square root');

subplot(2, 1, 2);
plot(v, abs_err);
yline(mean(abs_err.^2))
title('Absolute error');
set(gca, 'YScale', 'log');
grid on;
