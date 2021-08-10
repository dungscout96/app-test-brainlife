%function bids_dataqual(dataset)

modeval = 'import';
%modeval = 'read';

addpath('/home/arno/eeglab');
eeglab
tic;

filepath = pwd;
[~,dsname] = fileparts(filepath);
outputDir = fullfile('..', [ dsname '-processed']);

% read or import data
pop_editoptions( 'option_storedisk', 1);
if strcmpi(modeval, 'import')
    if exist(outputDir)
        system([ 'rm -r --force ' outputDir ]);
    end
    [STUDY, ALLEEG] = pop_importbids(filepath, 'bidsevent','off','bidschanloc','off','studyName','temp','outputdir', outputDir);
else
    tic
    [STUDY, ALLEEG] = pop_loadstudy(fullfile(outputDir, 'temp.study'));

end
if any([ ALLEEG.trials ] > 1)
    disp('Cannot process data epochs');
end    
percentChanRejected = zeros(1, length(ALLEEG));
percentDataRejected = zeros(1, length(ALLEEG));
percentBrainICs     = zeros(1, length(ALLEEG));
try
    %parpool(100);
catch
end

% write channel information
percentEmpty = sum(cellfun(@isempty, { ALLEEG.chanlocs }))/length(ALLEEG);
for iDat = 1:length(ALLEEG)
    EEG = ALLEEG(iDat);
    if isfield(EEG.chanlocs, 'type')
        allTypes = { EEG.chanlocs.type };
        allTypes(cellfun(@isempty, allTypes)) = { '' };

        allTypes = strmatch('eeg', lower(allTypes), 'exact');
        percentChanEEG(iDat) = length(allTypes)/length(EEG.chanlocs);
    else
        percentChanEEG(iDat) = NaN;
    end
end

fid = fopen(fullfile('../results', [ dsname '_res.txt' ]), 'w');
timeSec = toc;
if fid ~= -1
    fprintf(fid, '%s\n', timeSec);
    fprintf(fid, '%1.2f\n', percentEmpty);
    fprintf(fid, '%1.2f\n', mean( percentChanEEG ));
    fprintf(fid, '%s\n', sprintf('%s,', EEG.chanlocs.labels) );
    fprintf(fid, '\n');
end
fclose(fid);

