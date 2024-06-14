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


step  = 2^-6;


% input values in the range [.5, 2)
v = 0.5:step:(2-step);
% fixed-point inputs in range [.5, 2)
v_fixpt = fi(v, DAT_S, DAT_BW);


x_sqr = zeros(1,length(v)); % An array to hold the floating point cordic values
x_sqr_fixpt = zeros(1,length(v)); % An array to hold the fixed point cordic values

Nmax = 30;
mse_n_fxpt = zeros(Nmax);
mse_n_float = zeros(Nmax);

% compute the reference floating-point results with Matlab sqrt function
x_ref = sqrt(v);  

% Compute the MSE for multiple numbers of iterations of the CORDIC algorithm 
for n_i = 1:Nmax
    % Get the CORDIC outputs for comparison
    % and plot the error between the MATLAB reference and CORDIC sqrt values
    for i=1:length(v)
        x_sqr(i) = sqrt_cordic(v(i), n_i);
        x_sqr_fixpt(i) = sqrt_cordic_fixpt(v_fixpt(i), n_i, DAT_BW, DAT_FL, DAT_S, F);
    end
    mse_n_float(n_i) = mean(abs(x_ref - x_sqr).^2);
    mse_n_fxpt(n_i) = mean(abs(x_ref - x_sqr_fixpt).^2);
end

points = find(mse_n_fxpt < 3e-5);

% Make a plot of the results
figure;
hold on;
p1 = plot(1:Nmax, mse_n_fxpt, 'b-');
p2 = plot(1:Nmax, mse_n_float, 'c-');
p3 = yline(3e-5, 'm--');
p4 = scatter(points, mse_n_fxpt(points), 'r', 'filled');
set(gca, 'YScale', 'log');
ylim([1e-8, 5e-2]);
legend([p1(1), p2(1), p3(1)], {'Fixed Point', 'Floating Point', 'MSE Threshold'});
xlabel('Number of Iterations');
ylabel('Mean Squared Error');
title('Mean Squared Error of CORDIC Square Root vs. Number of Iterations');
grid on;
saveas(gcf, 'mse_vs_iter.png');

