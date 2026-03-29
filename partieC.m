%% 1. Densité Spectrale de Puissance (PSD)

% Paramètres imposés
fs = 1000;
T = 20;
N = fs * T;

% Génération des bruits individuels
blue_noise       = bluenoise(N, 1);
pink_noise       = pinknoise(N, 1);
red_noise_raw    = rednoise(N, 1);
violet_noise     = violetnoise(N, 1);
white_noise      = randn(N, 1);

% Application des offsets
red_noise = red_noise_raw * 5;

% Bruit total
total_noise = blue_noise + pink_noise + red_noise + violet_noise + white_noise;

% Noms et couleurs (donnés dans l'énoncé)
nm = {'Blue noise', 'Pink noise (flicker)', 'Red noise (Brownian noise)', ...
      'Violet noise', 'White noise', 'total'};
clr = [0 0 1; 1 0.5 0.5; 1 0 0; 0.4940 0.1840 0.5560; 0.4 0.4 0.4; 0 0 0];

figure(1);
[psd_blue, f]   = pwelch(blue_noise,   [], [], N, fs);
[psd_pink, ~]   = pwelch(pink_noise,   [], [], N, fs);
[psd_red, ~]    = pwelch(red_noise,    [], [], N, fs);
[psd_violet, ~] = pwelch(violet_noise, [], [], N, fs);
[psd_white, ~]  = pwelch(white_noise,  [], [], N, fs);
[psd_total, ~]  = pwelch(total_noise,  [], [], N, fs);

semilogx(f, 10*log10(psd_blue),   'Color', clr(1,:)); hold on;
semilogx(f, 10*log10(psd_pink),   'Color', clr(2,:));
semilogx(f, 10*log10(psd_red),    'Color', clr(3,:)); 
semilogx(f, 10*log10(psd_violet), 'Color', clr(4,:));
semilogx(f, 10*log10(psd_white),  'Color', clr(5,:));
semilogx(f, 10*log10(psd_total),  'Color', clr(6,:), 'LineWidth', 1.5);
hold off;

title('Densité Spectrale de Puissance (PSD)');
xlabel('Fréquence (Hz)'); ylabel('Puissance (dB/Hz)');
grid on; xlim([1 fs/2]);
legend(nm, 'Location', 'northeast');

%% 2. Autocorrélation
figure(2);
donnees = {blue_noise, pink_noise, red_noise, violet_noise, white_noise, total_noise};

for i = 1:6
    subplot(2, 3, i);
    % Utilisation de 'unbiased' pour conserver la puissance réelle (pic à lag 0)
    [c, lags] = xcorr(donnees{i}, 'unbiased');
    lag_time = lags / fs;
    
    plot(lag_time, c, 'Color', clr(i,:));
    title(nm{i});
    xlabel('lag (s)');
    ylabel('Amplitude');
    grid on;
end
sgtitle('Autocorrélation des différents bruits');