%__________________________________________________________________________
%
% Description: 
%
%    Digital Signal Processing - Mini Project 2 STFT analysis.
%
%    Instructions - some code missing. Search for "XXX" and edit code.
%
% Inputs: Reads the file "MP2_STFT_Data.mat" which must be in the same
%         directory as this code.
%
% Outputs: Graphs, outputs to screen.
%
% Change History:
%
% 29 September 2020 - Original
%
% Authors:
% John Ball
%__________________________________________________________________________
%

clc
clear varaibles
close all

%
% Load data.
% x - vector of signal data.
% t - vector of times in seconds for sampling points of data.
%
fname = 'MP2_STFT_Data.mat';
load(fname);


% Create LFM pulse
N = 512;
B = 50.0;
tau = 1.5;
tprime = t - 1.0;
pulse = (tprime >= (-tau/2)) .* (tprime <= (tau/2));
x = exp(-1i*2*pi*(B/tau)*(tprime.^2)) .* pulse;
noise_variance = 0.01;
noise = randn(size(x))*sqrt(noise_variance/2) + 1i*randn(size(x))*sqrt(noise_variance/2);
x = x + noise;

%
% Determine the sampling rate fs in Hz and sampling interval Ts in seconds
%
Ts = 0.002;
fs = 1/Ts;

fprintf('The sampling rate is %.2f Hz and sampling interval is %.2f milliseconds.\n', ...
         fs, Ts * 1000);
         
%
% FFT size for STFT
%
N = 256;

%
% Sigma values - spoecifies the STFT
%
sigma_arr = [0.01 0.05 0.075 0.1 0.2 0.5];

for i = 1:5
    
    if(i > 1)
        input("Press enter to continue...\n");
        close all
    end
    %
    % Gaussian windows
    %
    tprime = t - mean(t);
    g = exp(-0.5*(tprime .^ 2)/(sigma_arr(i) ^2));
    epsilon = 1e-3;
    total_len = (sigma_arr(i)*sqrt(-2*log(epsilon)))*2;
    total_len_samples = ceil(total_len/Ts);
    fprintf("The window length when sigma = %.3f and epsilon = %.3f is %d\n", sigma_arr(i), epsilon, total_len_samples);

    %
    % Determine extent of signal
    %
    indx1 = find(g > 1e-3); 
    g1 = g(indx1);

    %
    % Plot window in time.
    %
    figure
    plot(tprime, g);
    xlabel('t (sec)');
    ylabel('G{_\sigma}(t)');
    title('Gaussian time domain window.');
    drawnow;

    fprintf('\nGaussian window sigma = %.4f.\n', sigma_arr(i));
    fprintf('Gaussian window length = %d samples.\n', length(g1));

    %
    % Plot data
    %
    figure
    plot(t,x);
    xlabel('t (sec)');
    ylabel('x(t)');
    title('Data signal (time domain)');

    %
    % Calculate STFT and plot it
    %
    [s1,t_2,f] = DSP_stft(x, g1, fs, N);
    plot_STFT(t_2, f/1e3, 20*log10(abs(s1)),'t (sec)', 'f (kHz)', ...
       sprintf('STFT Magnitude (dB) sigma = %.2f', sigma_arr), 1);

end