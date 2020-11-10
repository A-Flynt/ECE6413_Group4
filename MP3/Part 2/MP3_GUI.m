function varargout = MP3_GUI(varargin)
%__________________________________________________________________________
%
% Description: 
%
%    This script is a GUI that allows a song to be filtered in four bands
%    and sliders control the band gain.
%
%    New filters can be created using MP3_Create_Filters.m.
%
%    1. Select a test tone or song by clicking the label in Load Music.
%    2. Press Load Music Button.
%    3. Press Load Coeff to load filter coefficients. Then select the
%       coefficient file.
%    4. Press Process Music to analyze with your filter banks.
%    5. Press Play Music.
%
% Inputs: None
%
% Outputs: A video file is saved each time the music is played.
%
% Change History:
%
% 11 October 2020 - Original
%
% Authors:
% John Ball
%__________________________________________________________________________
%

% Last Modified by GUIDE v2.5 11-Oct-2020 20:35:15

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MP3_GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @MP3_GUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before MP3_GUI is made visible.
function MP3_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MP3_GUI (see VARARGIN)

% Choose default command line output for MP3_GUI
handles.output = hObject;
init_data(hObject, eventdata, handles);
ax = handles.axes_display_meter;
xticklabels = {'B','LMR','UMR','HE'};
axvals = [0 5 -140 40];
axis(ax, axvals);
title(ax, sprintf('Music Meter'));
xlabel(ax, 'Band');
ylabel(ax, 'Power (dB)');
set(ax, 'XTick', 1:4);
set(ax, 'XTickLabel', xticklabels);
drawnow;

% --- Outputs from this function are returned to the command line.
function varargout = MP3_GUI_OutputFcn(~, ~, handles) 
varargout{1} = handles.output;


% --- Executes on slider movement.
function slider_bass_Callback(hObject, eventdata, handles)
   if handles.data.audio_playing == false
      slider_value_dB = get(hObject,'Value');           % Value in dB
      slider_value = 10.0 ^ (slider_value_dB / 10.0);   % Value in natural units
      fprintf('Set bass slider to %.2f dB.\n', slider_value_dB);
      handles.data.slider_gain_dB(1) = slider_value_dB;
      handles.data.slider_gain_natural(1) = slider_value;
      handles.data.music_processed = 0;
      handles.data.y_processed = [];
   else
      set(hObject,'Value',handles.data.slider_gain_dB(1)); 
   end
   guidata(hObject, handles);
   handles = update_status(hObject, handles);      
   guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function slider_bass_CreateFcn(hObject, eventdata, handles)
   if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
       set(hObject,'BackgroundColor',[.9 .9 .9]);
   end


% --- Executes on slider movement.
function slider_low_midrange_Callback(hObject, eventdata, handles)
% hObject    handle to slider_low_midrange (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
   if handles.data.audio_playing == false
      slider_value_dB = get(hObject,'Value');           % Value in dB
      slider_value = 10.0 ^ (slider_value_dB / 10.0);   % Value in natural units
      fprintf('Set low-midrange slider to %.2f dB.\n', slider_value_dB);
      handles.data.slider_gain_dB(2) = slider_value_dB;
      handles.data.slider_gain_natural(2) = slider_value;
      handles.data.music_processed = 0;
      handles.data.y_processed = [];
   else
      set(hObject,'Value',handles.data.slider_gain_dB(2)); 
   end
   guidata(hObject, handles);
   handles = update_status(hObject, handles);      
   guidata(hObject, handles);
   
% --- Executes during object creation, after setting all properties.
function slider_low_midrange_CreateFcn(hObject, eventdata, handles)
   if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
       set(hObject,'BackgroundColor',[.9 .9 .9]);
   end


% --- Executes on slider movement.
function slider_upper_midrange_Callback(hObject, eventdata, handles)
   if handles.data.audio_playing == false
      slider_value_dB = get(hObject,'Value');           % Value in dB
      slider_value = 10.0 ^ (slider_value_dB / 10.0);   % Value in natural units
      fprintf('Set upper-midrange slider to %.2f dB.\n', slider_value_dB);
      handles.data.slider_gain_dB(3) = slider_value_dB;
      handles.data.slider_gain_natural(3) = slider_value;
      handles.data.music_processed = 0;
      handles.data.y_processed = [];
   else
      set(hObject,'Value',handles.data.slider_gain_dB(3)); 
   end
   guidata(hObject, handles);
   handles = update_status(hObject, handles);      
   guidata(hObject, handles);
   

% --- Executes during object creation, after setting all properties.
function slider_upper_midrange_CreateFcn(hObject, eventdata, handles)
   if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
       set(hObject,'BackgroundColor',[.9 .9 .9]);
   end


% --- Executes on slider movement.
function slider_high_end_Callback(hObject, eventdata, handles)
   if handles.data.audio_playing == false
      slider_value_dB = get(hObject,'Value');           % Value in dB
      slider_value = 10.0 ^ (slider_value_dB / 10.0);   % Value in natural units
      fprintf('Set high end slider to %.2f dB.\n', slider_value_dB);
      handles.data.slider_gain_dB(4) = slider_value_dB;
      handles.data.slider_gain_natural(4) = slider_value;
      handles.data.music_processed = 0;
      handles.data.y_processed = [];
   else
      set(hObject,'Value',handles.data.slider_gain_dB(4)); 
   end
   guidata(hObject, handles);
   handles = update_status(hObject, handles);      
   guidata(hObject, handles);
   

% --- Executes during object creation, after setting all properties.
function slider_high_end_CreateFcn(hObject, eventdata, handles)
   if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
       set(hObject,'BackgroundColor',[.9 .9 .9]);
   end


%__________________________________________________________________________
%
% Radiobutton Load Music Controls
%__________________________________________________________________________
%
function radiobutton_Test_Bass_Callback(hObject, eventdata, handles)
   if get(hObject,'Value')
      handles.data.load_music_command = 'test bass';
      fprintf('  Music selection: test bass.\n');
      guidata(hObject, handles);
   end

function radiobutton_test_low_mid_Callback(hObject, eventdata, handles)
   if get(hObject,'Value')
      handles.data.load_music_command = 'test low mid';
      fprintf('  Music selection: test low mid.\n');
      guidata(hObject, handles);
   end
   
function radiobutton_test_upper_mid_Callback(hObject, eventdata, handles)
   if get(hObject,'Value')
      handles.data.load_music_command = 'test upper mid';
      fprintf('  Music selection: test upper mid.\n');
      guidata(hObject, handles);
   end
   
% --- Executes on button press in radiobutton_test_high_end.
function radiobutton_test_high_end_Callback(hObject, eventdata, handles)
   if get(hObject,'Value')
      handles.data.load_music_command = 'test high end';
      fprintf('  Music selection: test high end.\n');      
      guidata(hObject, handles);
   end

function radiobutton_Song_Callback(hObject, eventdata, handles)
   if get(hObject,'Value')
      handles.data.load_music_command = 'song';
      fprintf('  Music selection: song.\n'); 
      guidata(hObject, handles);
   end

%__________________________________________________________________________
%
% Push button to load music
%__________________________________________________________________________
%
function pushbutton_Load_Music_Callback(hObject, eventdata, handles)
   % Check data initialized
   [~, handles] = data_initialized(hObject, eventdata, handles);

   [result, handles] = take_action('load music', hObject, eventdata, handles);
   
   if result
      handles.data.music_loaded = 1;
      handles.data.music_processed = 0;
      handles.data.y_processed = [];
      fprintf('  Load music successful.\n');
   else
      handles.data.music_loaded = 0;
      handles.data.music_processed = 0;
      handles.data.y_processed = [];
      fprintf('  Load music failed.\n');
   end
   
   handles = update_status(hObject, handles);
   guidata(hObject, handles);
   
%__________________________________________________________________________
%
% Push button to load filter coefficients
%__________________________________________________________________________
%
function pushbutton_Load_Coeff_Callback(hObject, eventdata, handles)
   % Check data initialized
   [~, handles] = data_initialized(hObject, eventdata, handles);

   [result, handles] = take_action('load coeff', hObject, eventdata, handles);
   
   if result
      handles.data.coeff_loaded = 1;
      handles.data.music_processed = 0;
      handles.data.y_processed = [];
      fprintf('  Coefficient load successful.\n');
   else
      handles.data.coeff_loaded = 0;
      handles.data.music_processed = 0;
      handles.data.b = [];
      handles.data.a = [];
      handles.data.y_processed = [];
      fprintf('  Coefficient load successful.\n');
   end
   
   handles = update_status(hObject, handles);
   guidata(hObject, handles);
   
%__________________________________________________________________________
%
% Push button to play and process music
%__________________________________________________________________________
%
function pushbutton_Play_Music_Callback(hObject, eventdata, handles)
   % Check data initialized
   [~, handles] = data_initialized(hObject, eventdata, handles);
   
   if handles.data.music_loaded == 0
      fprintf('Music must be loaded before music can be played.\n');
   elseif handles.data.music_processed == 0
      fprintf('Music must be processed before music can be played.\n');
   elseif handles.data.coeff_loaded == 0
      fprintf('Filter coefficients must be loaded music can be played.\n');
   else
      [result, handles] = take_action('play music', hObject, eventdata, handles);
      
      if result
         fprintf('  Play music successful.\n');
      else
         fprintf('  Play music failed.\n');
      end
      
      handles = update_status(hObject, handles);      
      guidata(hObject, handles);
   
   end
   
function pushbutton_Process_Music_Callback(hObject, eventdata, handles)
   % Check data initialized
   [~, handles] = data_initialized(hObject, eventdata, handles);

   if handles.data.music_loaded == 0
      fprintf('Music must be loaded before music can be processed.\n');
   elseif handles.data.coeff_loaded == 0
      fprintf('Filter coefficients must be loaded music can be processed.\n');
   else
      [result, handles] = take_action('process music', hObject, eventdata, handles);
      
      if result
         handles.data.music_processed = 1;
         fprintf('  Process music music successful.\n');
      else
         handles.data.music_processed = 0;
         handles.data.y_processed = [];
         fprintf('  Process music music failed.\n');
      end
      
      handles = update_status(hObject, handles);
      guidata(hObject, handles);
   end
   
%__________________________________________________________________________
%
% Helper functions
%__________________________________________________________________________
%

% Function to check if data structures initialized. Will init if not.
function [init, handles] = data_initialized(hObject, eventdata, handles)
   if isfield(handles, 'data')
      % Data is initialized, just return
      init = true;
   else
      fprintf('   init check: calling init_data\n');
      handles = init_data(hObject, eventdata, handles);
      init = true;
   end
  
   
% Function to init data structures
function handles = init_data(hObject, ~, handles)
   
   % Init data structures
   handles.data.music_loaded = false;                 % true if music loaded
   handles.data.coeff_loaded = false;                 % true if coeff loaded
   handles.data.music_processed = false;              % true if music processed
   handles.data.num_filters = 4;                      % Number of filters
   handles.data.slider_gain_dB = -10 * ones(1,4);     % Slider gains in dB
   handles.data.slider_gain_natural = 10*log10(handles.data.slider_gain_dB);      % Slider gains in natural units
   handles.data.fs = 0.0;                             % Sampling rate in Hz
   handles.data.Ts = inf;                             % Sampling interval
   handles.data.y = [];                               % Holds music
   handles.data.y_processed = [];                     % Processed music
   handles.data.load_music_command = 'test bass';     % Music load command
   handles.data.b = [];                               % Filter B coefficients
   handles.data.a = [];                               % Filter A coefficients
   handles.data.frame_power_dB = {};                  % Stores processed frame power data
   handles.data.Nframes = 0;                          % Number of frames in song
   handles.data.frame_size_samples = 0;               % Number of samples in a frame
   handles.data.audio_playing = false;                % true if audio is playing
   
   handles.data.init = true;                          % true if initialized
   
   % Update user
   clc;
   fprintf('MP3 GUI initialized.\n');
   
   handles = update_status(hObject, handles);
   guidata(hObject, handles);
   pause(1);
   

% Function to take action
function [result, handles] = take_action(command, hObject, eventdata, handles)

   result = true;
   
   switch command
      
      case 'process music'
         fprintf('Processing music.\n');
         handles = process_music(hObject, handles);
         result = true;
         handles = update_status(hObject, handles);
   
      case 'load coeff'
         fprintf('Loading coeff.\n');
         file = uigetfile('*.mat');
         if file == 0
            result = false;
            handles.data.b = [];
            handles.data.a = [];
         else
            try
               load(file);
               if (size(b,1) == 1) && (size(b,2) == 4) && ...
                  (size(a,1) == 1) && (size(a,2) == 4)
                  handles.data.b = b;
                  handles.data.a = a;
                  result = true;
               else
                  handles.data.b = [];
                  handles.data.a = [];
                  result = false;
               end
            catch
               handles.data.b = [];
               handles.data.a = [];
               result = false;
            end
         end
         if result
            fprintf('  Data file: %s.\n', file);
         end
         handles = update_status(hObject, handles);
         
      case 'load music'
         music_type = handles.data.load_music_command;
         fprintf('Loading music (%s).\n', music_type);
      
         switch music_type
                          
            case 'test bass'
               fname = 'test_signal_bass.mat';
               try
                  load(fname);
                  handles.data.y = y;
                  handles.data.fs = fs;
                  handles.data.music_loaded = true;
                  handles.data.music_processed = false;
                  handles.data.y_processed = [];
                  result = true;
               catch ME
                  handles.data.y = [];
                  handles.data.fs = 0;
                  handles.data.music_loaded = false;
                  handles.data.music_processed = false;
                  handles.data.y_processed = [];
                  result = false;
               end
               
            case 'test low mid'
               fname = 'test_signal_lower_midrange.mat';
               try
                  load(fname);
                  handles.data.y = y;
                  handles.data.fs = fs;
                  handles.data.music_loaded = true;
                  handles.data.music_processed = false;
                  handles.data.y_processed = [];
                  result = true;
               catch ME
                  handles.data.y = [];
                  handles.data.fs = 0;
                  handles.data.music_loaded = false;
                  handles.data.music_processed = false;
                  handles.data.y_processed = [];
                  result = false;
               end
               
            case 'test upper mid'
               fname = 'test_signal_upper_midrange.mat';
               try
                  load(fname);
                  handles.data.y = y;
                  handles.data.fs = fs;
                  handles.data.music_loaded = true;
                  handles.data.music_processed = false;
                  handles.data.y_processed = [];
                  result = true;
               catch ME
                  handles.data.y = [];
                  handles.data.fs = 0;
                  handles.data.music_loaded = false;
                  handles.data.music_processed = false;
                  handles.data.y_processed = [];
                  result = false;
               end
               
            case 'test high end'
               fname = 'test_signal_high_end.mat';
               try
                  load(fname);
                  handles.data.y = y;
                  handles.data.fs = fs;
                  handles.data.music_loaded = true;
                  handles.data.music_processed = false;
                  handles.data.y_processed = [];
                  result = true;
               catch ME
                  handles.data.y = [];
                  handles.data.fs = 0;
                  handles.data.music_loaded = false;
                  handles.data.music_processed = false;
                  handles.data.y_processed = [];
                  result = false;
               end
            
            case 'song'
               fname = 'song.mat';
               try
                  load(fname);
                  
                  % One channel only
                  y = y(:,1)';                      
                  
                  % Trim song to 30 seconds
                  Ts = 1.0 / fs;
                  ymax = floor(30.0 / Ts);
                  handles.data.y = y(1:ymax);
                  handles.data.fs = fs;
                  handles.data.music_loaded = 1;
                  handles.data.music_processed = 0;
                  result = true;
               catch ME
                  handles.data.y = [];
                  handles.data.fs = 0;
                  handles.data.music_loaded = false;
                  handles.data.music_processed = false;
                  handles.data.y_processed = [];
                  result = false;
               end
               
            otherwise
               
               handles.data.y = [];
               handles.data.fs = 0;
               handles.data.music_loaded = false;
               handles.data.music_processed = false;
               handles.data.y_processed = [];
               error('Illegal option %s.\n', music_type);
               result = false;
               
         end       
         
         if result
            Ts = 1.0 / handles.data.fs;
            fprintf('  Data file: %s.', fname);
            fprintf('\n  Sampling rate: %.2f KHz.', handles.data.fs/1e3);                 
            fprintf('\n  Number of samples: %d.', length(handles.data.y));
            fprintf('\n  Song time = %.2f seconds.\n', length(handles.data.y) * Ts);
         end
         
         handles = update_status(hObject, handles);
         
      case 'play music'
         fprintf('Playing music.\n');
         handles = play_music(hObject, handles);
         result = true;
         
      otherwise
         fprintf('Unknown command to function take_action.\n');
         result = false;
         
   end

   guidata(hObject, handles)

   
% Update text status.
function handles = update_status(hObject, handles)

   tstr = 'Music: ';
   if handles.data.music_loaded == false
      tstr = [tstr, 'Not Loaded'];
   else
      tstr = [tstr, 'Loaded'];
   end
   
   tstr = [tstr, sprintf('\nCoefficients: ')];
   if handles.data.coeff_loaded == false
      tstr = [tstr, 'Not Loaded'];
   else
      tstr = [tstr, 'Loaded'];
   end
   
   tstr = [tstr, sprintf('\nProcessing: ')];
   if handles.data.music_processed == false
      tstr = [tstr, 'Not completed'];
   else
      tstr = [tstr, 'Completed'];
   end
   
   set(handles.text_Status, 'String', tstr);
   guidata(hObject, handles);

   
% Function to process music
function handles = process_music(hObject, handles)
   
   % Sampling interval
   Ts = 1.0 / handles.data.fs;

   % Define frame size in samples and frame overlap in [0,1]. 1 means skip to next frame, 
   % 0.5 means 50% overlap, etc.
   frame_size = floor(0.10/Ts);
   frame_overlap_factor = 1.0;
   frame_skip = floor(frame_size * frame_overlap_factor);

   % Create the signal to filter - append zeros so filter can tail out
   y = handles.data.y;
   yext = [y zeros(1,1000)];

   num_frames = inf;

   % Data storage
   frame_filtered_power_dB = {};
   
   % Run signals through filter
   for k = 1 : handles.data.num_filters

      % Get filter coeff and apply filter and slider gain to data frame
      a = handles.data.a{k};
      b = handles.data.b{k};
      gain = handles.data.slider_gain_natural(k);
      yfilt = filter(b, a, y) * gain;
      

      % Store filtered data
      if (k == 1)
         y_processed = yfilt;
      else
         y_processed = y_processed + yfilt;
      end
      
      % Filter ending point (last index to process)
      Nyfilt = length(yfilt) - frame_size;

      % Determine number of frames to process
      Nframes = 0;
      frame_indx = 1;
      while (frame_indx < Nyfilt)
         frame_indx = frame_indx + frame_skip;
         Nframes = Nframes + 1;
      end

      % Data storage
      frame_filtered_power_dB{k} = zeros(1, Nframes);

      % Analyze a frame at a time
      frame_indx = 1;
      frame_indx_array = 0 : (frame_size - 1);

      frame_counter = 1;
      while (frame_counter < Nframes)

         % Get the data frame of filtered data
         frame_indices = frame_indx + frame_indx_array;
         y_frame = yfilt(frame_indices);

         % Calculate frame power
         frame_power = sqrt(mean(y_frame .^ 2));
         frame_power_dB(frame_counter) = 20*log10(abs(frame_power + 1e-6));

         frame_indx = frame_indx + frame_skip;
         frame_counter = frame_counter + 1;
         
      end

      % Store for showing
      frame_filtered_power_dB{k} = frame_power_dB;
      num_frames = min(num_frames, length(frame_power_dB));

   end

   %
   % Convert frame_filtered_power_dB into a matrix
   %
   for k = 1 : handles.data.num_filters
      temp(k,:) = frame_filtered_power_dB{k};
   end
   frame_filtered_power_dB = temp;
   
   % Normalize data
   y_processed = y_processed / handles.data.num_filters;
   
   % Store data
   handles.data.frame_filtered_power_dB = frame_filtered_power_dB;
   handles.data.num_frames = num_frames;
   handles.data.Ts = Ts;
   handles.data.Nframes = Nframes;
   handles.data.frame_size_samples = frame_size;
   handles.data.y_processed = y_processed;
   
   guidata(hObject, handles);
         
% Function to play music   
function handles = play_music(hObject, handles)
   
   % Lock sliders
   handles.data.audio_playing = true;
   guidata(hObject, handles);
   
   % Create video file, and change : space and : to _ in the filename
   vfile = sprintf('Song_Analysis_Video_%s.avi', datestr(now));
   vfile(find(vfile == ' ')) = '_';
   vfile(find(vfile == '-')) = '_';
   vfile(find(vfile == ':')) = '_';
   vfile = ['.' filesep() vfile];
   v = VideoWriter(vfile);

   % Set AVI framerate and open the file
   Tframe = handles.data.frame_size_samples * handles.data.Ts;
   videoframerate = 1 / Tframe;
   v.FrameRate = videoframerate;
   open(v);

   % Prepare to play
   done = 0;

   % Get data, sampling rate and sampling intervel
   y = handles.data.y_processed;
   Fs = handles.data.fs;
   Ts = handles.data.Ts;
   
   % Calcualte some params
   L = floor(Tframe/Ts);
   last_frame = handles.data.num_frames;
   
   % Create audio player handle
   clear audio_handle
   audio_handle = audioplayer(y, Fs);

   % Get number of filters
   NC = handles.data.num_filters;

   % Last index to play
   indx_end = length(y);
   
   % Play it
   play(audio_handle, [1 indx_end]);
   axvals = [0 (NC+1) -140 40];
   
   % Get power data
   X_CH_power_dB_frame = handles.data.frame_filtered_power_dB';

   % Record start time and keep track of current time in song
   samplenum = get(audio_handle,'CurrentSample');
   delta_t = samplenum * Ts;
   current_frame = floor(samplenum/L) + 1;

   % Plot
   ax = handles.axes_display_meter;
   xticklabels = {'B','LMR','UMR','HE'};
   
   bar(ax, X_CH_power_dB_frame(current_frame,:) ,'basevalue', axvals(3));
   axis(ax, axvals);
   title(ax, sprintf('Music Meter: t = %6.3f sec, frame = %d.', delta_t, current_frame));
   xlabel(ax, 'Band');
   ylabel(ax, 'Power (dB)');
   set(ax, 'XTickLabel', xticklabels);
   drawnow;
   
   while (done == 0)

      %
      % Update figure
      %
      samplenum = get(audio_handle,'CurrentSample');
      delta_t = samplenum * Ts;
      framenumber = floor(samplenum / L) + 1;

      if (framenumber > last_frame)
         done = 1;
         break;
      end

      bar(ax, X_CH_power_dB_frame(current_frame,:) ,'basevalue', axvals(3));
      axis(ax, axvals);
      title(ax, sprintf('Music Meter: t = %6.3f sec, frame = %d.', delta_t, current_frame));
      xlabel(ax, 'Band');
      set(ax, 'XTickLabel', xticklabels);
      ylabel(ax, 'Power (dB)');
      drawnow;

      % Record the GUI, which is the Parent of the current axis ax
      frame = getframe(get(ax, 'Parent'));
      writeVideo(v, frame);

      %
      % If we are done, then stop.
      % 
      done = strcmp(get(audio_handle, 'Running'), 'Off');
      if (done == 1)
         break;
      end

      done2 = 0;
      while (done2 == 0)
         samplenum = get(audio_handle,'CurrentSample');
         framenumber = floor(samplenum / L) + 1;
         done2 = framenumber > current_frame;
      end
      current_frame = framenumber;

      %
      % Are we done yet?
      %
      done = strcmp(get(audio_handle, 'Running'), 'Off');

   end
   
   % Close video file
   close(v)
   
   handles.data.audio_playing = false;
   guidata(hObject, handles);
   
