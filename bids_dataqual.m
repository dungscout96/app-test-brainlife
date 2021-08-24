function bids_dataqual()
load_eeglab()

arg_list = argv();
filepath = arg_list{1};
modeval = 'import';
modeval = 'read';

tic;

nChans              = 0;
percentChanRejected = 0;
percentDataRejected = 0;
percentBrainICs     = 0;
asrFail             = 0;
icaFail             = 0;
try
    parpool;
catch
end

EEG = pop_loadset(filepath);

processedEEG = [ EEG.filename(1:end-4) '_processed.set' ];
if ~exist(fullfile(EEG.filepath, processedEEG), 'file')
    fprintf('Processing dataset %s\n', EEG.filename);
    EEG = eeg_checkset(EEG, 'loaddata');

    %allVars = whos;
    %fprintf('******** Memory used (Mb) %d/n', round(sum([allVars.bytes])/1e6));

    % check channel locations
    % remove non-EEG channels
    disp('Selecting channels based on type...');
dipfit_path = fileparts(which('pop_dipplot'));
    chanfile = [dipfit_path '/standard_BEM/elec/standard_1005.elc'];
    if ~exist(chanfile,'file')
        chanfile = '/home/octave/eeglab/plugins/dipfit4.0/standard_BEM/elec/standard_1005.elc';
    end
    if isfield(EEG.chanlocs, 'theta')
        notEmpty = ~cellfun(@isempty, { EEG.chanlocs.theta });
        if any(notEmpty)
            EEG = pop_select(EEG, 'channel', find(notEmpty));
        else
            EEG = pop_chanedit(EEG, 'lookup',chanfile);
        end
    else
        EEG = pop_chanedit(EEG, 'lookup',chanfile);
    end
    notEmpty = ~cellfun(@isempty,  { EEG.chanlocs.theta });
    EEG = pop_select(EEG, 'channel', find(notEmpty));

    % resample ds002336
    if EEG.srate == 5000
        EEG = pop_resample(EEG, 250); % instead of 5000 Hz (ds002336 and ds002338)
    end

    % remove DC
    disp('Remove DC');
    EEG = pop_rmbase(EEG, [EEG.times(1) EEG.times(end)]);
    EEG.etc.orinbchan = EEG.nbchan;
    EEG.etc.oripnts   = EEG.pnts;
    if any(any(any(EEG.data))) % not all data is 0
        % remove bad channels
        disp('Call clean_rawdata...');
        try
            EEGTMP = pop_clean_rawdata( EEG,'FlatlineCriterion',5,'ChannelCriterion',0.8,'LineNoiseCriterion',4,'Highpass',[0.25 0.75] ,...
                'BurstCriterion',20,'WindowCriterion',0.25,'BurstRejection','on','Distance','Euclidian','WindowCriterionTolerances',[-Inf 7] );
            EEG = EEGTMP;

            % run ICA and IC label
            %if ~isempty(EEG.chanlocs) && isfield(EEG.chanlocs, 'X') && ~isempty(EEG.chanlocs(1).X)
            try
                EEG = pop_reref(EEG, []);
                EEG = pop_runica(EEG, 'icatype','picard','options',{'pca',EEG.nbchan-1});
                EEG = pop_iclabel(EEG,'default');
                EEG = pop_icflag(EEG,[0.6 1;NaN NaN;NaN NaN;NaN NaN;NaN NaN;NaN NaN;NaN NaN]);

                pop_saveset(EEG, fullfile(EEG.filepath, processedEEG));
            catch
                l = lasterror
                for iL = 1:length(l.stack)
                    l.stack(iL)
                end
                icaFail(iDat) = 1;
            end
        catch
            l = lasterror
            for iL = 1:length(l.stack)
                l.stack(iL)
            end
            asrFail = 1;
        end
    else
        asrFail = 1;
    end
else
    % do not load binary data
    fprintf('Loading dataset %s\n', processedEEG);
    EEG = load('-mat', fullfile(EEG.filepath, processedEEG));
    EEG = EEG.EEG;
end

% get results
if ~asrFail && ~icaFail
    percentBrainICs = sum(EEG.reject.gcompreject)/(EEG.nbchan-1);
    nChans = EEG.etc.orinbchan;
    percentChanRejected = 1-EEG.nbchan/EEG.etc.orinbchan;
    percentDataRejected = 1-EEG.pnts/EEG.etc.oripnts;
end

timeItTook = toc
timeItTook2 = timeItTook/3600/24;
hoursStr = datestr(timeItTook2, 'HH');
minStr   = datestr(timeItTook2, 'MM');

res.timeSec   = sprintf('%d', round(timeItTook));
res.timeHours = sprintf('%d:%2.2d', round(timeItTook2)*24+str2num(hoursStr), str2num(minStr));
res.nChans    = sprintf('%d', nChans);
res.goodChans = sprintf('%1.1f', (1-percentChanRejected)*100);
res.goodData  = sprintf('%1.1f', (1-percentDataRejected)*100);
res.goodICA   = sprintf('%1.1f', percentBrainICs*100);
res.asrFail   = sprintf('%d', asrFail);
res.icaFail   = sprintf('%d', icaFail);

fid = fopen('result.txt', 'w');
if fid ~= -1
    fprintf(fid, '%s\n', res.timeSec);
    fprintf(fid, '%s\n', res.timeHours);
    fprintf(fid, '%s\n', res.nChans);
    fprintf(fid, '%s\n', res.asrFail);
    fprintf(fid, '%s\n', res.icaFail);
    fprintf(fid, '%s\n', res.goodChans);
    fprintf(fid, '%s\n', res.goodData);
    fprintf(fid, '%s\n', res.goodICA);
    fclose(fid);
end

fid = fopen('result.json', 'w');
if fid ~= -1
    fprintf(fid, '%s\n', jsonwrite(res));
    fclose(fid);
end
