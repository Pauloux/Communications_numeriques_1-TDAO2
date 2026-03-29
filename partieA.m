clc;
clear;
close all;

%% Génération et analyse du bruit gaussien

N = 10000;  % nombre d'échantillons
mu = 1.5;   % moyenne du bruit
sigma = 1;  % écart-type du bruit

% Génération du signal bruité
noise_signal = randn(N, 1) * sigma + mu;

% Histogramme
figure(1);
h = histogram(noise_signal);
bin_width = h.BinWidth;
hold on;

% Distribution théorique
theoritical_distrib_x = linspace(-2, 5, 100);
theoritical_distrib_y = 1 / (sigma * sqrt(2 * pi)) * exp(-((theoritical_distrib_x - mu).^2)/(2 * sigma.^2));

% Tracé de la distribution théorique (mise à l'échelle)
plot(theoritical_distrib_x, N * bin_width * theoritical_distrib_y, 'r', 'LineWidth', 2);

% Tracé de la moyenne
xline(mu, 'k--', 'LineWidth', 2);

title('Distribution statistique du bruit gaussien');xlabel('Amplitude du signal');
ylabel('Nombre d''occurrences');
legend('Histogramme expérimental', 'Densité de probabilité théorique', 'Moyenne \mu', 'Location', 'northeast');grid on;
hold off;

% Tracé du signal temporel
figure(2);
plot(noise_signal);
title('Représentation temporelle du signal bruité');
xlabel('Indice de l''échantillon');
ylabel('Amplitude');
xlim([0 N]);
grid on;