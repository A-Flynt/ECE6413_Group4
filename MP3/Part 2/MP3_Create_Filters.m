%__________________________________________________________________________
%
% Description: 
%
%   DSP Mini-project 3 Filter Generator.
%
%   Students: Modify this code to generate the four filters needed for the
%             demo.
%
%             It is important that you look at the filter responses and
%             make sure they are relatively smooth - very jagged filter
%             responses are not valid.
%
%             Students: Modify code marked as XXXX.
%
% Inputs:  None
%
% Outputs: Plots, saves data files.
%
% References: None
%
% Change History:
%
% 09 October 2020 - Original
%
% Authors:
% John Ball (modified from decimation help example in Matlab)
%__________________________________________________________________________
%
clc
clear variables
close all

%
% Specify the freqency ranges for each region
%
regions = {'Bass', ...
           'Lower Midrange', ...
           'Upper Midrange', ...
           'High End'};

%
% Sampling rate in Hz (do not change this!)
%
fs = 44100;

%
% Passband frequencies in Hz for each region
%
f_passband_Hz = {[20, 300], ...           % Bass
                 [300, 1200], ...        % Lower midrange
                 [1200, 5000], ...        % Upper midrange
                 [5000, 19800]};           % High end

%
% Stopband frequencies in Hz for each region
%
f_stopband_Hz = {[1, 350], ...            % Bass
                 [250, 1250], ...        % Lower midrange
                 [1100, 5200], ...        % Upper midrange
                 [4800, 19900]};           % High end

% 
% Max filter order (may be required to get a reasonable filter
% Set value to inf to not constrain.
%
% Hint: Values from 3 to 8 are reasonable
%
max_N = {3, ...                         % Bass
         5, ...                         % Lower midrange
         7, ...                         % Upper midrange
         8};                            % High end
      
%
% Filter type. Only have one uncommented.
%
option = input('Select a filter type.\n1) Butterworth\n2) Chebyshev-I\n3) Elliptic\n4) Parks-McClellan\n>>>');
switch option
    case 1
        filter_type = 'Butterworth'; 
    case 2
        filter_type = 'Chebyshev-I';
    case 3
        filter_type = 'Elliptic';
    case 4
        filter_type = 'PM';
    otherwise
        return
end

%
% Create filters
%
for k = 1 : length(regions)
 
   % Get filter regions passband low and high frequencies
   freq_range = f_passband_Hz{k};
   f_pass_lo = freq_range(1);
   f_pass_hi = freq_range(2);
 
   % Get filter regions stopband low and high frequencies
   freq_range = f_stopband_Hz{k};
   f_stop_lo = freq_range(1);
   f_stop_hi = freq_range(2);
   
   % Get max filter order
   N_filter_max = max_N{k};
   
   %
   % Design filter
   %
   switch filter_type
      
      case 'Butterworth'
         Wpass = [f_pass_lo, f_pass_hi] / (fs/2);
         Wstop = [f_stop_lo, f_stop_hi] / (fs/2);
         Rp = 0.05;
         As = 60;
         [N, Wn] = buttord(Wpass, Wstop, Rp, As);
         N = min(N, N_filter_max);
         [bb, aa] = butter(N, Wn);
         title_str = 'butterworth_filter_coeff.mat';
   
      case 'Chebyshev-I'
         Wpass = [f_pass_lo, f_pass_hi] / (fs/2);
         Wstop = [f_stop_lo, f_stop_hi] / (fs/2);
         Rp = 0.05;
         As = 60;
         [N, Wp] = cheb1ord(Wpass, Wstop, Rp, As);
         N = min(N, N_filter_max);
         [bb, aa] = cheby1(N, Rp, Wp);
         title_str = 'chebyshev1_filter_coeff.mat';
         
      case 'Elliptic'
         Wpass = [f_pass_lo, f_pass_hi] / (fs/2);
         Wstop = [f_stop_lo, f_stop_hi] / (fs/2);
         Rp = 0.05;
         As = 60;
         [N, Wp] = ellipord(Wpass, Wstop, Rp, As);
         N = min(N, N_filter_max);
         [bb, aa] = ellip(N, Rp, As, Wp);
         title_str = 'elliptic.mat';
      case 'PM'
         Wpass = [f_pass_lo, f_pass_hi] / (fs/2);
         Wstop = [f_stop_lo, f_stop_hi] / (fs/2);
         Rp = 0.05;
         As = 60;
         dev = [(10^(Rp/20)-1)/(10^(Rp/20)+1) 10^(-As/20) ]; 
         [N, Rp, As, Wp] = firpmord([f_pass_hi f_stop_hi],[1 0],dev,fs);
         [bb, aa] = firpm(N, Rp, As, Wp);
         title_str = 'pm.mat';
         

         
   end
   
   if(k == 1 && ~strcmp(filter_type,'PM')) 
       disp(bb)
       disp(aa)
   end
   
   if(k == 1 && strcmp(filter_type,'Elliptic')) 
       b_elliptic = bb;
       a_elliptic = aa;
   end
   
   figure
   file_nm = (sprintf('%s Z Plane. Order %d %s.', ...
      regions{k}, N, filter_type));
   zplane(bb,aa);
   saveas(gcf,strcat(file_nm,'.png'));
   figure
   file_nm = (sprintf('%s Impulse Response. Order %d %s.', ...
      regions{k}, N, filter_type));
   impz(bb,aa,50)
   saveas(gcf,strcat(file_nm,'.png'));
   %
   % Normalize filter response to specified frequency
   %
   f_mid = (f_pass_lo + f_pass_hi) / 2.0;
   [H, ~] = freqz(bb, aa, f_mid * ones(1, 1024), fs);
   Htarget_dB = 0.0;                        % dB
   Htarget = 10 ^ (Htarget_dB / 10.0);
   bb = bb / abs(H(1)) * Htarget;
  
   %
   % Store coefficients
   %
   a{k} = aa;
   b{k} = bb;
   
   % Print info on filter.
   fprintf('Designing %s %-15s filter with N = %-2d and passband = [%-8.1f, %-8.1f] Hz.\n', ...
      filter_type, regions{k}, N, f_pass_lo, f_pass_hi);
   
   %
   % Plot freqeuncy response
   %
   [H, f] = freqz(bb, aa, 1024, fs);
   H_dB = 20*log10(abs(H) + 1e-6);
   
   figure;
   h = plot(f/1e3, H_dB); set(h, 'LineWidth', 1.5);
   hold on;
   h = plot([f_pass_lo f_pass_lo f_pass_hi f_pass_hi] / 1e3, [-100 0 0 -100], 'r--'); set(h, 'LineWidth', 1.5);
   file_nm = (sprintf('%s Frequency Response. Order %d %s.', ...
      regions{k}, N, filter_type));
  title(file_nm);
   xlabel('f (kHz)');
   ylabel('|H(f)| dB');
   ax = axis;
   axis([0, fs/2/1e3, -60, 3]); drawnow;
   saveas(h,strcat(file_nm,'.png'));
   
   if strcmp(filter_type,'Elliptic')
         Wpass = [f_pass_lo, f_pass_hi] / (fs/2);
         Wstop = [f_stop_lo, f_stop_hi] / (fs/2);
         Rp = 0.05;
         As = 60;
         dev = [(10^(Rp/20)-1)/(10^(Rp/20)+1) 10^(-As/20) ]; 
         [N, Rp, As, Wp] = firpmord([f_pass_hi f_stop_hi],[1 0],dev,fs);
         [PMbb, PMaa] = firpm(N, Rp, As, Wp);
         subplot(2,1,1);
         impz(PMbb,PMaa,50);
         title('Impulse Response: PM Bass Filter');
         subplot(2,1,2);
         impz(b_elliptic,a_elliptic,50);
         title('Impulse Response: PM Bass Filter');
   end
   
   if strcmp(filter_type,'PM')
         break
   end
end

%
% Set your filename here. Remember to change it for each filter set you create.
%
filter_filename = title_str;

fprintf('\nSaving filter data to file %s.\n', filter_filename);
save(filter_filename, 'fs', 'regions', 'f_passband_Hz', 'b', 'a');
