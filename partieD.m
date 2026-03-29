clc;
clear;
close all;

function errors = compterErreurs(b1, b2)
    % Compte les différences bit à bit sans vectorisation complexe
    errors = 0;
    for j = 1:length(b1)
        if b1(j) ~= b2(j)
            errors = errors + 1;
        end
    end
end

% Paramètres globaux de la simulation
N_bits_D = 100000;         
num_segments = 100;        
bits_per_segment = N_bits_D / num_segments; 

% Génération de la trame binaire source
source_bits_D = randi([0 1], 1, N_bits_D);
received_bits_D = source_bits_D; 

% Création du profil de probabilité d'erreur (légères variations autour de 5%)
taux_base = 0.05;
taux_50 = taux_base + (rand(1, 50) - 0.5) * 0.01;
profil_erreurs = reshape([taux_50; taux_50], 1, 100); 

% Initialisation du vecteur de BER
BER_instantane = zeros(1, num_segments);

% Boucle principale sur l'ensemble des segments
for i = 1:num_segments
    idx_debut = (i - 1) * bits_per_segment + 1;
    idx_fin = i * bits_per_segment;
    Pe_segment = profil_erreurs(i);
    
    % Application statistique des erreurs sur le canal
    for k = idx_debut:idx_fin
        if rand() < Pe_segment
            received_bits_D(k) = 1 - source_bits_D(k);
        end
    end
    
    % Comptage des erreurs et calcul du BER instantané
    nb_err = compterErreurs(source_bits_D(idx_debut:idx_fin), received_bits_D(idx_debut:idx_fin));
    BER_instantane(i) = nb_err / bits_per_segment;
end

% Traitement statistique : moyenne et écart-type glissants
window_size = 10;
BER_moyenne = movmean(BER_instantane, window_size);
BER_sigma = movstd(BER_instantane, window_size);

% Calcul de l'enveloppe de confiance à +/- 2 sigma
enveloppe_haute = BER_moyenne + (2 * BER_sigma);
enveloppe_basse = BER_moyenne - (2 * BER_sigma);

% Création de la figure globale
figure(1);

% Sous-graphique 1 : Tracé de la trame (zoom sur les premiers bits)
subplot(2, 1, 1);
plot(source_bits_D, 'b-o', 'LineWidth', 1.5); hold on;
plot(received_bits_D, 'r-x', 'LineWidth', 1.2);
xlim([0 20]);
hold off;
title('Source Binaire vs Reçue (Zoom)');
xlabel('Index du Bit'); ylabel('Valeur');
legend('Source', 'Reçue');
grid on;
ylim([-0.2 1.2]);

% Sous-graphique 2 : Tracé du BER et des statistiques globales
subplot(2, 1, 2);

% Tracé du BER instantané en créneaux
stairs(1:num_segments, BER_instantane, 'Color', 'r', 'LineWidth', 1); hold on;

% Tracé des enveloppes de dispersion
plot(1:num_segments, enveloppe_haute, 'k--', 'LineWidth', 1);
plot(1:num_segments, enveloppe_basse, 'k--', 'LineWidth', 1);

% Tracé de la moyenne glissante
plot(1:num_segments, BER_moyenne, 'b', 'LineWidth', 2.5);
hold off;

title('Variation Instantanée du BER et Moyenne Glissante');
xlabel('Index du Segment'); ylabel('Taux d''Erreur Binaire (BER)');
legend('BER Instantané', 'Enveloppe \pm 2\sigma', '', 'Moyenne Glissante');
grid on;
xlim([0 100]);
ylim([0 0.12]);
