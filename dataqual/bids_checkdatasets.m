clear
allDirs1 = dir('/home/arno/nemar/openneuro/*-processed');
allDirs2 = dir('/home/arno/nemar/openneuro/*');

allDirs1 = { allDirs1.name };
allDirs2 = { allDirs2.name };

allDirs2 = setdiff(allDirs2, { allDirs1{:} '.' '..' 'dataqual' 'results' } );

for iDir = 1:length(allDirs2)
    if ~exist(fullfile('/home/arno/nemar/openneuro', [allDirs2{iDir} '-processed' ]), 'file');
        fprintf('%s-processed missing\n', allDirs2{iDir});
    end
end

% check that the original folder
for iDir = 1:length(allDirs1)
    tmpData = load('-mat', fullfile('/home/arno/nemar/openneuro', allDirs1{iDir}, 'temp.study'));
    STUDY = tmpData.STUDY;
    ALLEEG = STUDY.datasetinfo;

    countFound = 0;
    for iDat = length(ALLEEG):-1:1
    
        processedEEG = [ ALLEEG(iDat).filename(1:end-4) '_processed.set' ];
        if exist(fullfile(ALLEEG(iDat).filepath, processedEEG), 'file')
            countFound = countFound+1;
            %fullfile(ALLEEG(iDat).filepath, processedEEG)
        end
    end
    
    if countFound < length(ALLEEG)
        fprintf('%s -> found %d/%d datasets\n', allDirs1{iDir}, countFound, length(ALLEEG));
    end
end
