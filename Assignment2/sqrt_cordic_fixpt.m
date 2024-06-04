% Use the cordic to compute the sqrt operation
% fixed point version
% ThetaLUTFP contains the fixed point lookup table
% DAT_BW, DAT_FL, DAT_S, F are the fixed point parameters, see testCordic_sqrt.m
function r = sqrt_cordic(v, N, DAT_BW, DAT_FL, DAT_S, F)
% compute for N iterations
% First: tune the inputs
c = 0.25; % A constant
x = v + c; y = v - c; % add input and the constant to x an y 
K = 4; % to repeat k every 3K+1  
for k = 1 : N
    %------------------------------------------------
    % Compare this code segment with that in cordic.m
    if y < 0
        s = 1;
    else
        s = -1;
    end
    xnew = x + s*bitsra(y, k);
    ynew = y + s*bitsra(x, k);
    x = fi(xnew, DAT_S, DAT_BW, DAT_FL, F);
    y = fi(ynew, DAT_S, DAT_BW, DAT_FL, F);
    %------------------------------------------------
    % (repeat the loop once more for k=4, 13, 40, 121, ...)
    if k == K
        if y < 0
            s = 1;
        else
            s = -1;
        end
        xnew = x + s*bitsra(y, k);
        ynew = y + s*bitsra(x, k);
        x = fi(xnew, DAT_S, DAT_BW, DAT_FL, F);
        y = fi(ynew, DAT_S, DAT_BW, DAT_FL, F);
        K = 3*K + 1;  % compute the next time to repeat
    end
    %------------------------------------------------
end
inv_Gain = fi(1.207496866840026, DAT_S, DAT_BW, DAT_FL, F);
r = x * inv_Gain;
end