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

% Get the CORDIC outputs for comparison
% and plot the error between the MATLAB reference and CORDIC sqrt values
for i=1:length(v)
    x_sqr(i) = sqrt_cordic(v(i), NIter);
    x_sqr_fixpt(i) = sqrt_cordic_fixpt(v_fixpt(i), NIter, DAT_BW, DAT_FL, DAT_S, F);
end

% compute the reference floating-point results with Matlab sqrt function
x_ref = sqrt(v);   
mse = mean(abs(x_ref - x_sqr_fixpt).^2);

% Make a plot of the results
figure;
subplot(3,1,1); hold on;
plot(v, double(x_sqr), 'r-');       % plot the floating point CORDIC
plot(v, double(x_sqr_fixpt), 'g-'); % plot the fixed point CORDIC
plot(v, x_ref, 'b-');               % plot the reference
legend('CORDIC float', 'CORDIC fixpt', 'Reference', 'Location', 'SouthEast');
title('CORDIC Square Root, CORDIC Fixed Point (In-Range) and MATLAB Reference Results');

subplot(3,1,2); hold on;
absErr_fltpt = abs(x_ref - double(x_sqr));       % compute the error in the floating point CORDIC
absErr_fixpt = abs(x_ref - double(x_sqr_fixpt)); % compute the error in the floating point CORDIC
plot(v, absErr_fltpt, 'r-');
plot(v, absErr_fixpt, 'g-');
yline(mse, 'b--');
title('Absolute Error (vs. MATLAB SQRT Reference Results)');

subplot(3,1,3); hold on;
absErr_fltpt = abs(x_ref - double(x_sqr));       % compute the error in the floating point CORDIC
absErr_fixpt = abs(x_ref - double(x_sqr_fixpt)); % compute the error in the floating point CORDIC
plot(v, abs(x_ref - x_sqr_fixpt).^2, 'r-');
yline(mse, 'b-');
yline(3e-5, 'r--');
title('Mean Squared Error (vs. MATLAB SQRT Reference Results)');
legend('Squared Error', 'MSE', 'MSE Required Threshold')

fprintf("Mean Squared Error between fixed point CORDIC square root and sqrt():\n --> %g\n", mse)

assert(mse < 3e-5, 'MSE is over the desired threshold')