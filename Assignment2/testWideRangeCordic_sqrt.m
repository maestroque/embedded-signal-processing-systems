clear all;

% testCordic_sqrt.m
%
% the following parameters define the fixed point representation of the
% data variables in the computation of the square root
DAT_BW = 12;   % the bit width of the data variables
DAT_FL = 9;    % the fraction length of the data variables
DAT_S = true;  % the signedness of the data variables

% the number of iterations of the CORDIC algorithm
NIter = 4;

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


step  = 2^-8;

% Generate a fixed point number with the specified parameters
x_fixpt = fi(0.5, DAT_S, DAT_BW, DAT_FL, F);

% Find the realmin and realmax
realmin_val = double(realmin(x_fixpt));
realmax_val = double(realmax(x_fixpt));

% Print the values
fprintf('realmin: %.4f\n', realmin_val);
fprintf('realmax: %.4f\n', realmax_val);

% input values in the range [.5, 2)
v = 0.002:step:5;

% compute the square root of the input values using the CORDIC algorithm
y_fx = zeros(size(v));
for i=1:numel(v)
    % The values are stored in the specified fixed point object inside the function
   y_fx(i) = sqrt_cordic_widerange_fixpt(v(i), NIter, DAT_BW, DAT_FL, DAT_S, F);
end

% compute the absolute squared error
abs_err = abs(sqrt(v) - double(y_fx));
figure;

subplot(2, 1, 1);
plot(v, double(y_fx), 'r');
hold on;
plot(v, sqrt(v), 'b');
xline(realmin_val, 'm--', 'LineWidth', 1.5);
xline(realmax_val, 'm--', 'LineWidth', 1.5);
hold off;
title('Extended range CORDIC square root');
legend('Fixed-Point', 'sqrt()', 'Location', 'southeast'); % Modified
xlabel('Input (v)');
ylabel('Output (sqrt(v))');
grid on;

subplot(2, 1, 2);
plot(v, abs_err .^ 2);
yline(mean(abs_err.^2), '--', 'LineWidth', 1.5);
xline(realmin_val, 'm--', 'LineWidth', 1.5);
xline(realmax_val, 'm--', 'LineWidth', 1.5);
text(v(1), mean(abs_err.^2), sprintf('Mean Squared Error: %.4f', mean(abs_err.^2)), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'left');
title('Absolute Squared Error');
legend('Absolute Squared Error', 'Mean Squared Error', 'Location', 'southeast'); % Modified
xlabel('Input (v)');
ylabel('Error');
set(gca, 'YScale', 'log');
grid on;

% save the figure
saveas(gcf, 'CORDIC_sqrt_widerange.png');
