function y = sqrt_cordic_widerange_fixpt(v, N, DAT_BW, DAT_FL, DAT_S, F)
    v_fixpt = fi(v, DAT_S, DAT_BW, DAT_FL, F);

    num_leading_zeros = 0;
    v_shift = v_fixpt;
    while getmsb(v_shift) == 0
        v_shift = bitsll(v_shift, 1);
        num_leading_zeros = num_leading_zeros + 1;
        fprintf('v_shift = %s\n', v_shift.bin);
    end

    if mod(num_leading_zeros, 2) == 1
        num_leading_zeros = num_leading_zeros + 1;
    end

    if v > 2
        v_fixpt = bitsrl(v_fixpt, num_leading_zeros);
    elseif v < 0.5
        v_fixpt = bitsll(v_fixpt, num_leading_zeros);
    end

    y = sqrt_cordic_fixpt(v_fixpt, N, DAT_BW, DAT_FL, DAT_S, F);
    
    if v > 2
        y = bitsll(y, num_leading_zeros / 2);
    elseif v < 0.5
        y = bitsrl(y, num_leading_zeros / 2);
    end
end