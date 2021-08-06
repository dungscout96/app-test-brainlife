addpath('/home/octave/eeglab');
addpath('/home/octave/JSONio');
eeglab nogui;

% arg_list = argv();
% EEG = pop_loadset(arg_list{1});
% parse config.json
file = 'config.json';
fid = fopen(file); 
raw = fread(fid,inf); 
str = char(raw');
args = jsonread(str);
EEG = pop_loadset(args.set);

%addpath(pwd, 'iclabel');
%addpath(pwd, 'firfilt');
EEG = pop_runica(EEG, 'icatype', 'runica');
disp('Success');
