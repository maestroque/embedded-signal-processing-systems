% Use the cordic to compute the sqrt operation
function r = sqrt_cordic(v, N)
% v a number in the range [0.5, 2)
% compute for N iterations

% set the initial values for x and y
x = v + 0.25; y = v - 0.25; 

K = 4; % to perform an extra iteration when k==K 
for k = 1 : N
    %------------------------------------------------
    if y < 0
        s = 1;
    else
        s = -1;
    end
    xnew = x + s*bitsra(y, k);
    ynew = y + s*bitsra(x, k);
    x = xnew;
    y = ynew;
    %------------------------------------------------
    % (repeat the loop once more for k=4, 13, 40, 121, ...)
    if k == K
        K = 3*K + 1;  % compute the next time to repeat
        % the following lines are identical to the part between horizontal lines above
        %--------------------------------------------
        if y < 0
            s = 1;
        else
            s = -1;
        end
        xnew = x + s*bitsra(y, k);
        ynew = y + s*bitsra(x, k);
        x = xnew;
        y = ynew;
        %--------------------------------------------
    end
end
inv_Gain = 1.207497067763072;  % inverse of the CORDIC gain for very large N
r = x * inv_Gain;
end