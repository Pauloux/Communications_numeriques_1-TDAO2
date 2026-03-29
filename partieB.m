clc; clear; close all;

function basebandSignal = genererBasebandBPSK(binarySequence, samplesPerSymbol)
    % Transforme les bits 0/1 en amplitudes -1/1 et répète pour chaque échantillon
    numBits = length(binarySequence);
    basebandSignal = zeros(1, numBits * samplesPerSymbol);
    for i = 1:numBits
        idxStart = (i-1) * samplesPerSymbol + 1;
        idxEnd = i * samplesPerSymbol;
        if binarySequence(i) == 1
            basebandSignal(idxStart:idxEnd) = 1;
        else
            basebandSignal(idxStart:idxEnd) = -1;
        end
    end
end

function recoveredSequence = demodulerBPSK(receivedSignal, carrierSignal, filterB, filterA, numSymbols, samplesPerSymbol)
    % Démodulation cohérente : multiplication, filtrage et décision
    demodulated = receivedSignal .* carrierSignal;
    filtered = filtfilt(filterB, filterA, demodulated);
    recoveredSequence = zeros(1, numSymbols);
    for k = 1:numSymbols
        % On échantillonne au milieu de la durée du bit
        samplePoint = round((k - 0.5) * samplesPerSymbol);
        if filtered(samplePoint) > 0
            recoveredSequence(k) = 1;
        else
            recoveredSequence(k) = 0;
        end
    end
end

function errorCount = compterErreursBinaires(originalBits, receivedBits)
    % Compte le nombre de différences entre deux séquences binaires
    errorCount = 0;
    for i = 1:length(originalBits)
        if originalBits(i) == receivedBits(i)
            % Les bits sont identiques, on ne fait rien
        else
            % Les bits sont différents, on compte une erreur
            errorCount = errorCount + 1;
        end
    end
end

%% Paramètres globaux du filtre (Butterworth Ordre 5)
[filterB, filterA] = butter(5, 0.1, 'low');

%% Question 1 : Scintillation sur une porteuse
samplingFrequency = 1000;      
signalDuration = 2;            
carrierFrequency = 50;         
carrierAmplitude = 0.5;        
varianceScintillation = 0.3;   

timeVector1 = 0:1/samplingFrequency:signalDuration-1/samplingFrequency;
numberOfSamples1 = length(timeVector1);

% Génération des signaux
carrierSignal1 = carrierAmplitude * sin(2 * pi * carrierFrequency * timeVector1);
flickerNoise = 1 + sqrt(varianceScintillation) * randn(1, numberOfSamples1);
noisySignal1 = carrierSignal1 .* flickerNoise;

% Tracé des signaux temporels
figure(1);
plot(timeVector1, carrierSignal1, 'r'); hold on;
plot(timeVector1, flickerNoise, 'b');
title('Porteuse et Bruit de scintillation (Temporel)');
xlabel('Temps (s)'); ylabel('Amplitude');
legend('Porteuse', 'Bruit de scintillation');
xlim([0 0.4]); grid on;

figure(2);
plot(timeVector1, noisySignal1, 'k');
title('Signal altéré par la scintillation (Temporel)');
xlabel('Temps (s)'); ylabel('Amplitude');
legend('Signal scintillé');
xlim([0 0.4]); grid on;

% Analyse fréquentielle (FFT normalisée)
fftCarrier = fft(carrierSignal1) / numberOfSamples1;
fftFlicker = fft(flickerNoise) / numberOfSamples1;
fftNoisySignal = fft(noisySignal1) / numberOfSamples1;
frequencyAxis = linspace(0, samplingFrequency, numberOfSamples1);

figure(3);
semilogy(frequencyAxis, abs(fftCarrier), 'r'); hold on;
semilogy(frequencyAxis, abs(fftFlicker), 'b');
title('Spectre de la Porteuse et du Bruit');
xlabel('Fréquence (Hz)'); ylabel('Magnitude (Log)');
legend('Porteuse', 'Bruit de scintillation');
xlim([0, 100]); grid on;

figure(4);
semilogy(frequencyAxis, abs(fftNoisySignal), 'k');
title('Spectre du signal scintillé');
xlabel('Fréquence (Hz)'); ylabel('Magnitude (Log)');
legend('Signal scintillé');
xlim([0, 100]); grid on;


%% Question 2 : Modulation BPSK et canal AWGN
symbolDuration = 0.01;         
numberOfSymbols = 30;          
totalDuration2 = numberOfSymbols * symbolDuration; 
carrierAmplitude2 = 1;

timeVector2 = 0:1/samplingFrequency:totalDuration2-1/samplingFrequency;
samplesPerSymbol = samplingFrequency * symbolDuration;
carrierSignal2 = carrierAmplitude2 * sin(2 * pi * carrierFrequency * timeVector2);

% Émission
binarySequence = randi([0 1], 1, numberOfSymbols);
basebandSignal = genererBasebandBPSK(binarySequence, samplesPerSymbol);
transmittedSignal = basebandSignal .* carrierSignal2;

% Canal avec un SNR de 3dB
SNR_dB = 3;
receivedSignal = awgn(transmittedSignal, SNR_dB, 'measured');

% Réception et Démodulation
recoveredSequence = demodulerBPSK(receivedSignal, carrierSignal2, filterB, filterA, numberOfSymbols, samplesPerSymbol);

% Préparation des signaux pour l'affichage visuel
binarySquare = genererBasebandBPSK(binarySequence, samplesPerSymbol);
recoveredSquare = genererBasebandBPSK(recoveredSequence, samplesPerSymbol);
% Remplace les -1 par des 0 pour l'affichage
for i = 1:length(binarySquare)
    if binarySquare(i) == -1, binarySquare(i) = 0; end
    if recoveredSquare(i) == -1, recoveredSquare(i) = 0; end
end

figure(5);
plot(timeVector2, transmittedSignal + 3, 'b'); hold on;
plot(timeVector2, receivedSignal, 'r');
title('Modulation BPSK : Émis vs Reçu (SNR = 3dB)');
xlabel('Temps (s)'); ylabel('Amplitude');
legend('Signal émis (décalé +3)', 'Signal reçu bruité');
grid on;

figure(6);
plot(timeVector2, binarySquare + 1.5, 'b', 'LineWidth', 2); hold on;
plot(timeVector2, recoveredSquare, 'r', 'LineWidth', 2);
title('Comparaison des séquences binaires');
xlabel('Temps (s)'); ylabel('Valeur du bit');
legend('Séquence originale (+1.5)', 'Séquence récupérée');
ylim([-0.5 3]); grid on;


%% Question 3 : Calcul du BER (Canal AWGN)
SNR_Range = -15:-1;         
numberOfTransmissions = 5;      
numBitsBER = 10000;         
symbolDurationBER = 0.1; % Durée plus longue pour la stabilité du BER

samplesPerSymbolBER = samplingFrequency * symbolDurationBER;
timeVectorBER = 0:1/samplingFrequency:(numBitsBER * symbolDurationBER) - 1/samplingFrequency;
carrierSignalBER = carrierAmplitude2 * sin(2 * pi * carrierFrequency * timeVectorBER);

BER_AWGN = zeros(numberOfTransmissions, length(SNR_Range));

for trans = 1:numberOfTransmissions
    bitsTransmitted = randi([0 1], 1, numBitsBER);
    signalBaseband = genererBasebandBPSK(bitsTransmitted, samplesPerSymbolBER);
    signalModulated = signalBaseband .* carrierSignalBER;
    
    for s = 1:length(SNR_Range)
        currentSNR = SNR_Range(s);
        signalReceived = awgn(signalModulated, currentSNR, 'measured');
        
        bitsRecovered = demodulerBPSK(signalReceived, carrierSignalBER, filterB, filterA, numBitsBER, samplesPerSymbolBER);
        
        % Utilisation de la fonction de comptage personnalisée
        errors = compterErreursBinaires(bitsTransmitted, bitsRecovered);
        BER_AWGN(trans, s) = (errors / numBitsBER) + 1e-6;
    end
end

figure(7);
semilogy(SNR_Range, BER_AWGN', 'o-', 'LineWidth', 1.2); 
grid on;
title('Analyse du BER en canal AWGN - Modulation BPSK');
xlabel('SNR (dB)'); ylabel('Bit Error Rate (BER)');
legend('Trame 1', 'Trame 2', 'Trame 3', 'Trame 4', 'Trame 5');


%% Question 4 : Influence de la variance de scintillation

% 4.1. Visualisation temporelle de l'effet de la scintillation

% Paramètres spécifiques pour la visualisation (on prend peu de symboles pour la clarté)
fixedVarianceVisu = 0.5;
numberOfSymbolsVisu = 15; 
samplesPerSymbolVisu = samplesPerSymbol; % Réutilisation des paramètres globaux de Q2

timeVectorVisu = 0:1/samplingFrequency:(numberOfSymbolsVisu * symbolDuration) - 1/samplingFrequency;
carrierSignalVisu = carrierAmplitude2 * sin(2 * pi * carrierFrequency * timeVectorVisu);

% 1. Génération de la trame et du signal émis propre
bitsVisualisation = randi([0 1], 1, numberOfSymbolsVisu);
signalBasebandVisu = genererBasebandBPSK(bitsVisualisation, samplesPerSymbolVisu);
signalEmittedVisu = signalBasebandVisu .* carrierSignalVisu;

% 2. Génération et application du bruit de scintillation (multiplicatif)
bruitScintillationVisu = 1 + sqrt(fixedVarianceVisu) * randn(1, length(timeVectorVisu));
signalReceivedVisu = signalEmittedVisu .* bruitScintillationVisu;

% 3. Tracé de la Figure 8
figure(8);
% On décale le signal émis propre vers le haut (+3) pour faciliter la comparaison
plot(timeVectorVisu, signalEmittedVisu + 3, 'b', 'LineWidth', 1.2); 
hold on;
plot(timeVectorVisu, signalReceivedVisu, 'r');
hold off;

title(['Signal BPSK altéré par scintillation (Variance = ' num2str(fixedVarianceVisu) ')']);
xlabel('Temps (s)'); ylabel('Amplitude');
legend('Signal émis propre (décalé +3)', 'Signal reçu scintillé');
grid on;

% 4.2. Calcul du BER en fonction de la variance
varianceRange = logspace(-0.5, 0.3, 20); 
BER_Scintillation = zeros(numberOfTransmissions, length(varianceRange));

for trans = 1:numberOfTransmissions
    bitsTransmitted = randi([0 1], 1, numBitsBER);
    signalBaseband = genererBasebandBPSK(bitsTransmitted, samplesPerSymbolBER);
    signalModulated = signalBaseband .* carrierSignalBER;
    
    for v = 1:length(varianceRange)
        currentVariance = varianceRange(v);
        
        % Bruit multiplicatif
        flickerEffect = 1 + sqrt(currentVariance) * randn(1, length(timeVectorBER));
        signalReceived = signalModulated .* flickerEffect;
        
        bitsRecovered = demodulerBPSK(signalReceived, carrierSignalBER, filterB, filterA, numBitsBER, samplesPerSymbolBER);
        
        errors = compterErreursBinaires(bitsTransmitted, bitsRecovered);
        BER_Scintillation(trans, v) = (errors / numBitsBER) + 1e-9;
    end
end

figure(9);
loglog(varianceRange, BER_Scintillation', 'x-', 'LineWidth', 1.2);
grid on;
title('BER en fonction de la variance du bruit de scintillation');
xlabel('Variance du bruit'); ylabel('Bit Error Rate (BER)');
legend('Trame 1', 'Trame 2', 'Trame 3', 'Trame 4', 'Trame 5');