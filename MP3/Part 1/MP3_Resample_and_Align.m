%__________________________________________________________________________
%
% Description: 
%
%    Soft Robotic Sensor (SRS) to Motion Capture (MoCap) Resampling and 
%    Alignment Demonstration code.
%
%    This code requires the Signal Processing Toolbox and Statistics
%    Toolbox. For 2018a, these are included in the student version.
%
%    Students: Some code is missing. Replace XXXX and discuss in your 
%    report.
%
% Inputs: This code reads in the excel file 
%         'MoCap_StretchSense_Sample_PlantarFlexion.csv'
%
%         This file contains 
%
%         Time_SRS - Timestamps of SRS in seconds(s)
%
%         Frame_MoCap - Frame # of MoCap data (Recorded at 100 Hz)
%
%         PF_SRS - Capacitance values of SRS measuring
%                  PlantarFlexion(PF) movement in picoFarads (pF)
%
%         AnklePlantarflexion_MoCap - Joint angle values (degrees) recorded 
%                                   by MoCap
%                                   Note: PlantarFlexion recorded as
%                                   negative values
%
% Outputs: Time-aligned SRS and MoCap dataset, graphs, linear model
%
% Change History:
%
% 7 Oct 2020 - Original
%
% Authors:
% David Saucier
% John Ball
%__________________________________________________________________________
%

clc
clear variables
close all

%% Import the dataset

filename = 'MoCap_StretchSense_Sample_PlantarFlexion.csv';
fprintf('Loading the dataset from file %s.\n', filename);
mocap_SRS = readtable('Foot_Movement_Data.csv');
fprintf('\nDone.\n');

%% Assign individual columns to their own arrays for computations
srs_time = mocap_SRS.Time_SRS;
mocap_frames = mocap_SRS.Frame_MoCap;
srs_values = mocap_SRS.PF_SRS;
mocap_values = mocap_SRS.AnklePlantarflexion_MoCap;

%% Plot both data sets for initial visual inspection
% Plot SRS
subplot(2,1,1);
scatter(srs_time, srs_values, 'filled')
xlabel('Time (s)')
ylabel('Capacitance (pF)')
title('SRS Capacitance Output')

% Plot MoCap
subplot(2,1,2);
scatter(mocap_frames, mocap_values, 'filled', 'MarkerFaceColor','blue') % #d95319
xlabel('Frame Number')
ylabel('Joint Angle (°)')
title('MoCap Joint Angle Output')

%% First, we need to invert the MoCap data, since it normally reports
% Plantar flexion as a negative joint angle value
mocap_values_flipped = -(mocap_values);

figure()
subplot(2,1,1);
scatter(mocap_frames, mocap_values, 'filled', 'MarkerFaceColor','blue') %  #d95319
xlabel('Frame Number')
ylabel('Joint Angle (°)')
title('MoCap Joint Angle Output - Original')
subplot(2,1,2);
scatter(mocap_frames, mocap_values_flipped, 'filled', 'MarkerFaceColor','blue'); %'#D95319'
xlabel('Frame Number')
ylabel('Joint Angle (°)')
title('MoCap Joint Angle Output - Flipped')

%% Next we need to resample and interpolate the SRS data to match MoCap
% First, remove NaN values from SRS arrays
srs_time = rmmissing(srs_time);
srs_values = rmmissing(srs_values);

% SRS was sampled at roughly ~25Hz, while MoCap was sampled at 100Hz
% Create new timestamps
srs_time_100hz = (srs_time(1):(1/100):srs_time(end))';
% Interpolate SRS based on new timestamps
srs_values_interpolated = interp1(srs_time, srs_values, srs_time_100hz);

figure();
subplot(2,1,1);
scatter(srs_time, srs_values, 'filled');
xlabel('Time (s)')
ylabel('Capacitance (pF)')
title('SRS Capacitance Output - Original ')
subplot(2,1,2);
scatter(srs_time_100hz, srs_values_interpolated, 'filled');
xlabel('Time (s)')
ylabel('Capacitance (pF)')
title('SRS Capacitance Output - Resampled')

%% Before aligning datasets, we need to convert MoCap Frame numbers to seconds
mocap_time = mocap_frames ./ 100;

figure();
subplot(2,1,1);
scatter(mocap_frames, mocap_values_flipped, 'filled', 'MarkerFaceColor','blue');  %'#D95319'
xlabel('Frame #')
ylabel('Joint Angle (°)')
title('MoCap Joint Angle in Frames')
subplot(2,1,2);
scatter(mocap_time, mocap_values_flipped, 'filled', 'MarkerFaceColor','blue');  %'#D95319'
xlabel('Time (s)')
ylabel('Joint Angle (°)')
title('MoCap Joint Angle in Seconds')

%% Now that we know both are datasets are oriently correctly and sampled evenly,
% we can perform cross correlation
[c, lags] = xcorr(srs_values_interpolated, mocap_values_flipped);

% Determine the max correlation value (c) - 
% indicates point where two datasets best align
[max_corr, max_corr_ndx] = max(c);
optimal_lag = lags(max_corr_ndx);

figure();
stem(lags,c);
hold on;
stem(optimal_lag, max_corr, 'r', 'filled', 'MarkerSize', 10);
xlabel('Lags')
ylabel('Correlation')
title('Cross-Correlation of MoCap and SRS')

%% After determining optimal lag, shift SRS to the left by that much
srs_interpolated_shifted = srs_values_interpolated(optimal_lag:end);
srs_time_100hz_shifted = srs_time_100hz(optimal_lag:end);

% Also need to update timestamps to start at 0
srs_time_100hz_shifted = srs_time_100hz_shifted - (optimal_lag / 100);

figure()
subplot(2,1,1);
scatter(srs_time_100hz, srs_values_interpolated, 'filled', ...
    'MarkerFaceColor','blue'); %'#D95319'
xlabel('Time (s)')
ylabel('Capacitance (pF)')
title('SRS Capacitance (pF) - Original')
xlim([0,6.5])
subplot(2,1,2);
scatter(srs_time_100hz_shifted, srs_interpolated_shifted, 'filled', ...
    'MarkerFaceColor','blue'); %'#D95319'
xlabel('Time (s)')
ylabel('Capacitance (pF)')
title('SRS Capacitance (pF) - Time Shifted')
xlim([0,6.5])

%% There will also be some values in the MoCap that we need to remove,
% since there are no SRS values to match with them
srs_mocap_time_diff = size(mocap_time,1) - size(srs_interpolated_shifted, 1);

mocap_time = mocap_time(1:(end-srs_mocap_time_diff));
mocap_values_flipped = mocap_values_flipped(1:(end-srs_mocap_time_diff));

%% Now let's verify that we've properly aligned our data
figure()
yyaxis left
title('Resampled and Time-Aligned MoCap and SRS')
xlabel('Time (s)')
scatter(srs_time_100hz_shifted, srs_interpolated_shifted, 'filled');

yyaxis right
scatter(mocap_time, mocap_values_flipped, 'filled');
xlim([0 - 0.1, (srs_time_100hz_shifted(end) + 0.1 )])

yyaxis left
ylabel('Capacitance (pF)')
yyaxis right
ylabel('Joint Angle (°)')

%% Perform linear regression to see how well SRS can predict MoCap and how 
% much of the joint angle variance can be explained by the SRS data
model = fitlm(srs_interpolated_shifted, mocap_values_flipped);

% Print info on the linear model
fprintf('\nLinear model results...\n');
model

figure
plot(model)
xlabel('Capacitance (pF)')
ylabel('Joint Angle (°)')
title(['MoCap vs. SRS; R-Squared: ', num2str(model.Rsquared.Ordinary), ...
    '; RMSE: ', num2str(model.RMSE), '°']) 

