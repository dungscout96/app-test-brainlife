addpath('/home/octave/eeglab');
addpath('/home/octave/dataqual');
eeglab nogui;

arg_list = argv();
bids_path = arg_list{1};
bids_dataqual(bids_path);
%EEG = pop_runica(EEG, 'icatype', 'runica');
disp('Success');
