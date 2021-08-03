#!/usr/local/bin/octave -qf
dbstop if error
dbstop if warning
disp('here1');
addpath('/home/octave/eeglab');
disp('here2');
eeglab nogui;
disp('here3');
arg_list = argv();
disp('here4');
EEG = pop_loadset(arg_list{1});
disp('here5');
%addpath(pwd, 'iclabel');
%addpath(pwd, 'firfilt');
EEG = pop_runica(EEG, 'icatype', 'runica');
disp('here6');
disp('Success');
