
folders = dir('/home/arno/nemar/openneuro/ds*');
rows = [0 0 1 1 1 1 1 1 1 1 1 1 1 1];
rows = [1 1 1 1 1 1 1 1 1 1 1 1 1 1];

% get results for all algorithms
res = [];
for iFold = 1:length(folders)
    if isempty(strfind(folders(iFold).name, 'processed'))
        res(end+1).name = folders(iFold).name;

        % find result file
        resFile = dir( [ '/home/arno/nemar/openneuro/results/' folders(iFold).name '_res.txt'] );
        if ~isempty(resFile)
            fid = fopen(fullfile(resFile(1).folder, resFile(1).name), 'r');
            fopen(fid);
            res(end).timeSec = fgetl(fid);
            res(end).timeHours = fgetl(fid);
            res(end).chans     = fgetl(fid);
            res(end).asrFail   = fgetl(fid);
            res(end).icaFail   = fgetl(fid);
            res(end).goodChans = fgetl(fid);
            res(end).goodData  = fgetl(fid);
            res(end).goodICA   = fgetl(fid);
            fclose(fid);
        end
    end
end

% sort algorithm which have results
emptyTime = cellfun(@isempty, { res.goodChans });
nanTime   = cellfun(@(x)isequal(x, 'NaN - NaN'), { res(~emptyTime).goodChans });

resNotEmpty = res(~emptyTime);
res = [ res(emptyTime) resNotEmpty(nanTime) resNotEmpty(~nanTime) ];
for iRes = 1:length(res)
    if isempty(res(iRes).timeSec)
        fprintf('%s\n', res(iRes).name);
    else
        fprintf('%s\t%s\t%s\t%s\t%s\t%s\t%s\n', res(iRes).name, res(iRes).chans, res(iRes).asrFail, res(iRes).icaFail, res(iRes).goodChans, res(iRes).goodData, res(iRes).goodICA);  
    end
end
