#!/usr/local/bin/octave -qf
arg_list = argv();
EEG = load(arg_list{1});
EEG = EEG.EEG;
addpath(pwd, 'iclabel');
addpath(pwd, 'firfilt');
EEG = pop_runica(EEG, 'icatype', 'runica');
EEG = iclabel(EEG);

eeg_icalabelstat(EEG);
