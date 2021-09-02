function bids_dataqual(dataset)
load_eeglab()

arg_list = argv();
filepath = arg_list{1};
%filepath = dataset;%'/Volumes/LaCie/BIDS/ds002718-download';
modeval = 'import';
modeval = 'read';

tic;

%filepath = pwd;
[root_dir,dsname] = fileparts(filepath);
outputDir = fullfile(root_dir, 'processed', dsname);

%filepath = '/Users/arno/temp/BIDS_export_p300/BIDS_EXPORT';
%filepath = '/data/data/STUDIES/BIDS_hw';
%filepath = '/data/data/STUDIES/BIDS_EXPORT';
%filepath = '/Users/arno/GoogleDrive/bids_p3_2subjects/BIDS';

% read or import data
%pop_editoptions( 'option_storedisk', 1);
useBidsChans = { 'ds002718' 'ds003190' 'ds002578' 'ds002887' 'ds003004' 'ds002833' 'ds002691' 'ds002791' 'ds001787' };
studyFile = fullfile(outputDir, 'temp.study');
if ~exist(studyFile, 'file') || strcmpi(modeval, 'import')
    if exist(outputDir)
        system([ 'rm -r --force ' outputDir ]);
    end
    if ismember(dsname, useBidsChans), bidsChan = 'on'; else bidsChan = 'off'; end
    [STUDY, ALLEEG] = pop_importbids(filepath, 'bidsevent','off','bidschanloc', bidsChan,'studyName','temp','outputdir', outputDir);
else
    tic
    [STUDY, ALLEEG] = pop_loadstudy(studyFile);
end
if any([ ALLEEG.trials ] > 1)
    disp('Cannot process data epochs');
end
nChans              = zeros(1, length(ALLEEG))*NaN;
percentChanRejected = zeros(1, length(ALLEEG))*NaN;
percentDataRejected = zeros(1, length(ALLEEG))*NaN;
percentBrainICs     = zeros(1, length(ALLEEG))*NaN;
asrFail             = zeros(1, length(ALLEEG));
icaFail             = zeros(1, length(ALLEEG));
try
    parpool;
catch
end

for iDat = 1:length(ALLEEG)
    EEG = ALLEEG(iDat);
    
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

        if any(any(EEG.data')) % not all data is 0
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
                asrFail(iDat) = 1;
            end
        else
            asrFail(iDat) = 1;
        end
    else
        % do not load binary data
        fprintf('Loading dataset %s\n', processedEEG);
        EEG = load('-mat', fullfile(EEG.filepath, processedEEG));
        EEG = EEG.EEG;
    end
    
    % get results
    if ~asrFail(iDat) && ~icaFail(iDat)
        percentBrainICs(iDat) = sum(EEG.reject.gcompreject)/(EEG.nbchan-1);
        nChans(iDat) = EEG.etc.orinbchan;
        percentChanRejected(iDat) = 1-EEG.nbchan/EEG.etc.orinbchan;
        percentDataRejected(iDat) = 1-EEG.pnts/EEG.etc.oripnts;
    end
end

%nChans
%percentChanRejected
%percentDataRejected
%percentBrainICs
%asrFail
%icaFail

nChans(isnan(nChans)) = [];
percentChanRejected(isnan(percentChanRejected)) = [];
percentDataRejected(isnan(percentDataRejected)) = [];
percentBrainICs(isnan(percentBrainICs)) = [];
asrFail(isnan(asrFail)) = [];
icaFail(isnan(icaFail)) = [];

timeItTook = toc
timeItTook2 = timeItTook/3600/24;
hoursStr = datestr(timeItTook2, 'HH');
minStr   = datestr(timeItTook2, 'MM');

ciChan  = [NaN NaN];
ciData  = [NaN NaN];
ciBrain = [NaN NaN];
try
    ciChan = bootci(200, { @mean 1-percentChanRejected }, 'type', 'per');
    ciData = bootci(200, { @mean 1-percentDataRejected }, 'type', 'per');
    ciBrain = bootci(200, { @mean percentBrainICs }, 'type', 'per');
catch
end

res.timeSec   = sprintf('%d', round(timeItTook));
res.timeHours = sprintf('%d:%2.2d', round(timeItTook2)*24+str2num(hoursStr), str2num(minStr));
res.nChans    = sprintf('%d-%d', min(nChans), max(nChans));
res.goodChans = sprintf('%1.1f-%1.1f', ciChan(1)*100, ciChan(2)*100);
res.goodData  = sprintf('%1.1f-%1.1f', ciData(1)*100, ciData(2)*100);
res.goodICA   = sprintf('%1.1f-%1.1f', ciBrain(1)*100, ciBrain(2)*100);
res.asrFail   = sprintf('%d/%d', sum(asrFail), length(asrFail));
res.icaFail   = sprintf('%d/%d', sum(icaFail), length(icaFail));

fid = fopen(fullfile(filepath, 'result.txt'), 'w');
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

fid = fopen(fullfile(filepath, 'result.json' ), 'w');
if fid ~= -1
    fprintf(fid, '%s\n', jsonwrite(res));
    fclose(fid);
end
