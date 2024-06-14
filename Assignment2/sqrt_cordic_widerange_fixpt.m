function r = sqrt_cordic_widerange_fixpt(v, N, DAT_BW, DAT_FL, DAT_S, F)
    % sqrt_cordic_widerange_fixpt: Calculate the square root of a number using the CORDIC algorithm
    %     and a wider range of input values.
    %
    % Arguments:
    %     v: The number to calculate the square root of.
    %     N: The number of iterations to run the CORDIC algorithm for.
    %     DAT_BW: The total number of bits in the fixed-point data type.
    %     DAT_FL: The number of fractional bits in the fixed-point data type.
    %     DAT_S: The number of signed bits in the fixed-point data type.
    %     F: The fimath object to use for all fixed-point operations.
    %

    % Initialize the fixed-point object for the input value
    v_fixpt = fi(v, DAT_S, DAT_BW, DAT_FL, F);
    num_leading_zeros = 0;
    v_shift = v_fixpt;

    % Shift left until v_shift is in the range [0.5, 2)
    while v_shift < fi(0.5, DAT_S, DAT_BW, DAT_FL, F)
        v_shift = bitsll(v_shift, 1);
        num_leading_zeros = num_leading_zeros + 1;
    end

    % Shift right until v_shift is in the range [0.5, 2)
    while v_shift >= fi(2, DAT_S, DAT_BW, DAT_FL, F)
        v_shift = bitsra(v_shift, 1);
        num_leading_zeros = num_leading_zeros - 1;
    end

    % Make sure num_leading_zeros is even
    if mod(num_leading_zeros, 2) == 1
        num_leading_zeros = num_leading_zeros + 1;
        v_shift = bitsll(v_shift, 1);
    end

    % Calculate the square root using the CORDIC algorithm, now that v_shift is in the range [0.5, 2)
    sqrt_v = sqrt_cordic_fixpt(v_shift, N, DAT_BW, DAT_FL, DAT_S, F);
    
    % Renormalize the result
    if num_leading_zeros < 0
        r = bitsll(sqrt_v, -num_leading_zeros / 2);
    else
        r = bitsra(sqrt_v, num_leading_zeros / 2);
    end

end