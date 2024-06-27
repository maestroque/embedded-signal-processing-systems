clear all;

fs = 44100; 
fco = 500;
wco = 2*pi*fco/fs;
N_max = 1000;
Q = zeros(N_max);
for N=5:N_max
    b = fir1(N, wco/pi, 'low');
    w = linspace(0,pi,2048);
    H = abs(b * exp(1i * w .* (0:N)'));

    % Calculate Q-factor
    id_h = find(w >= wco);
    id_l = find(w <= wco);
    id_co = find(w >= wco, 1, "first");
    H_h = H(id_h);
    H_l = H(id_l);
    id_min = find(H_h < 0.1, 1, 'first') + id_co - 1;
    id_max = find(H_l > 0.8, 1, 'last');
    Q(N) = w(id_max) / w(id_min);
end

figure;
id = 1:N_max;
plot(id, Q);
yline(0.5, '--', 'Label', 'Q = 0.5')
xline(88, 'm--', 'Label', 'N = 88')
xlabel('N');
ylabel('Q-factor');
title('Q-factor vs N');
saveas(gcf, 'Q_factor.png');

fprintf('N_min = %d\n', find(Q > 0.5, 1, 'first'));

