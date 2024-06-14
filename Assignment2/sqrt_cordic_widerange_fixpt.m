function r = sqrt_cordic_widerange_fixpt(v, N, DAT_BW, DAT_FL, DAT_S, F)
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

    if mod(num_leading_zeros, 2) == 1
        num_leading_zeros = num_leading_zeros + 1;
        v_shift = bitsll(v_shift, 1);
    end

    sqrt_v = sqrt_cordic_fixpt(v_shift, N, DAT_BW, DAT_FL, DAT_S, F);
    
    if num_leading_zeros < 0
        r = bitsll(sqrt_v, -num_leading_zeros / 2);
    else
        r = bitsra(sqrt_v, num_leading_zeros / 2);
    end

end