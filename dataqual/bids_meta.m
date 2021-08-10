%function bids_dataqual(dataset)

addpath('/home/arno/eeglab');
if ~exist('pop_loadset.m', 'file')
    eeglab
end

filepath = pwd;
[~,dsname] = fileparts(filepath);

% read or import data
[STUDY, ALLEEG, bids, stats] = pop_importbids(filepath, 'bidsevent','off','bidschanloc', 'off','studyName','temp','outputdir', '/tmp', 'metadata', 'on');

fid = fopen(fullfile('..','results',[dsname '_out.txt']), 'w'); 
results = struct2array(stats);
for iRow = 1:length(results)
    fprintf(fid, '%d\n', results(iRow));
end
fprintf(fid, '%2.2f\n', mean(results));
fclose(fid);
