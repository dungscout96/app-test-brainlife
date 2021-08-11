load_eeglab();

arg_list = argv();
EEG = pop_loadset(arg_list{1});
%addpath(pwd, 'iclabel');
%addpath(pwd, 'firfilt');
EEG = pop_runica(EEG, 'icatype', 'runica');
disp('Success');
