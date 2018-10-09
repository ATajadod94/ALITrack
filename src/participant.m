classdef participant < iTrack
    % Get Data, Trials , conditions and features for a given participant
    properties
        TRIALS % Collection of Trial objects
        NUM_TRIALS % number of trials for a given participant
        EDF_File
        RAW % Raw data
    end
    methods
        % constructors
        function obj = participant(use_edf, varargin)
            obj = obj@iTrack(use_edf,varargin{:});
            if use_edf == 'from_fixation'
                p = inputParser;
                p.addRequired('use_edf', @(x) strcmp(x,'from_fixation'))
                p.addParameter('num_trials', @(x) isscalar(x) );
                p.addParameter('data', @(x) iscell(x) );
                p.parse(use_edf,varargin{:})
               
                obj.NUM_TRIALS = p.Results.num_trials;
                obj.RAW = p.Results.data;
                obj.EDF_File = 'from_fixation';
                obj.data = {};
                
            elseif ~use_edf % if use_edf is 0
                p = inputParser;
                p.addRequired('use_edf', @(x) x==0)
                p.addParameter('num_trials', @(x) isscalar(x) );
                p.addParameter('x',@(x) iscell(x));
                p.addParameter('y',@(x) iscell(x));
                p.addParameter('time',@(x) iscell(x));
                p.addParameter('events',@(x) iscell(x));
                p.parse(use_edf,varargin{:})
                
                obj.NUM_TRIALS = p.Results.num_trials;
                % initlizing to itrack's data strcture
                obj.RAW = p.Results;
                obj.data = {};
                obj.data{1} = struct();
                obj.data{1}(obj.NUM_TRIALS).gx = [];
                obj.data{1}(obj.NUM_TRIALS).gy = [];
                obj.data{1}(obj.NUM_TRIALS).time = [];
                obj.data{1}(obj.NUM_TRIALS).numsamples = [];
                
                obj.data{1}(obj.NUM_TRIALS).events = struct();
                obj.data{1}(obj.NUM_TRIALS).events.message = {};
                obj.data{1}(obj.NUM_TRIALS).events.time = {};
                % vectorized way of setting multiple structs
                [obj.data{1}.gx] = p.Results.x{:};
                [obj.data{1}.gy] = p.Results.y{:};
                [obj.data{1}.time] = p.Results.time{:};
                events = num2cell(p.Results.events);
                [obj.data{1}.events] = events{:};
                
                for i=1:obj.NUM_TRIALS
                    obj.data{1}(i).numsamples = length(obj.data{1}(i).gx);
                    obj.data{1}(i).sample_rate = 1000*unique(diff(obj.data{1}(i).time));
                end

            else
                obj.NUM_TRIALS = length(obj.data{1});
            end
            obj.EDF_File = use_edf;  %participant aware of source
        end
        %% setters
        function set_trials(obj,varargin)
            % Sets all features available for the given trials in the
            % participant object's trials. Check Trial documentaiton for more
            % information
            p = inputParser;
            p.addRequired('obj')
            p.addParameter('trial_number', 1:obj.NUM_TRIALS, @(x) isvector(x));
            addOptional(p, 'start_event',' ')
            addOptional(p, 'end_event',' ')
            p.parse(obj, varargin{:});

            if strcmp(obj.EDF_File,'from_fixation')
                for i = p.Results.trial_number
                    obj.TRIALS{i,1} = trial(obj, i, 'from_fixation', 1);
                end
            else
                %% TODO: unify this function and requested_trial
                start_event = p.Results.start_event;
                end_event = p.Results.end_event;
                for i = p.Results.trial_number
                    obj.TRIALS{i,1} = trial(obj, i ,'temporal_roi', [start_event;end_event]);
                end
            end
        end
        function set_base(obj, trials)
            if ~exist('trials', 'var')
                trials = 1:obj.NUM_TRIALS;
            end
            for trial = trials
                obj.TRIALS{trial}.set_base
            end
        end
        function set_extended(obj, trials)
            for trial = trials
                obj.TRIALS{trial}.set_extended()
            end
        end
        function set_eyelink(obj,trials)
            for trial = trials
                obj.TRIALS{trial}.set_eyelink_saccade(1)
            end
        end
        % output
        function output = to_matrix(obj,varargin)
            p = inputParser;
            p.addRequired('obj')
            p.addParameter('trials', 1:obj.NUM_TRIALS, @(x) isvector(x))
            p.addParameter('output', 'base', @(x) ischar(x) | isvector(x));
            p.parse(obj,varargin{:})            
            trials = p.Results.trials;
            fixation_locations = {};
            saccade_locations= {};
            switch p.Results.output
                case string('base')
                    obj.set_base(trials)
                case string('extended')
                    obj.set_extended(trials)
                case string('saccades')
                    obj.set_extended(trials)
                case string('fixations')
                    obj.set_extended(trials)
                case string('eyelink')
                    obj.set_eyelink(trials)
            end
            switch p.Results.output
                case string('eyelink')
                    for trialnum = trials
                        index(trialnum) = trialnum;
                        fixation_count(trialnum) =  obj.TRIALS{trialnum}.fixations.eye_link.num_fixations;
                        saccade_count(trialnum)  = obj.TRIALS{trialnum}.saccades.eye_link.num_saccades;
                    end
                case string('base')
                    for trialnum = trials
                        mytrial = obj.TRIALS{trialnum};
                        index(trialnum) = trialnum;
                        fixation_count(trialnum) =  mytrial.fixations.number;
                        saccade_count(trialnum) = mytrial.saccades.number;
                        output = [index', fixation_count',saccade_count'];
                    end
                case string('extended')
                    row_num = 2;
                    for trialnum = trials
                        mytrial = obj.TRIALS{trialnum};
                        % base
                        index(trialnum) = trialnum;
                        fixation_count(trialnum) =  mytrial.fixations.number;
                        saccade_count(trialnum) = mytrial.saccades.number;
                        output{row_num,1} = index(trialnum);
                        output{row_num,2} = fixation_count(trialnum);
                        output{row_num,3} = saccade_count(trialnum);
                        %extended
                        fixation_start{trialnum} = mytrial.fixations.start;
                        fixation_end{trialnum} = mytrial.fixations.end;
                        fixation_averagegaze_x{trialnum} = mytrial.fixations.average_gazex';
                        fixation_averagegaze_y{trialnum} = mytrial.fixations.average_gazey';
                        fixation_duration{trialnum} = mytrial.fixations.duration;
                        fixation_duration_standarddeviation(trialnum) = mytrial.fixations.duration_standard_deviation';
                        
                        output{row_num,4} = fixation_start{trialnum} ;
                        output{row_num,5} = fixation_end{trialnum};
                        output{row_num,6} = fixation_averagegaze_x{trialnum} ;                                         
                        output{row_num,7} = fixation_averagegaze_y{trialnum};
                        output{row_num,8} = fixation_duration{trialnum};
                        output{row_num,9} = fixation_duration_standarddeviation(trialnum);                        
                        saccades_start{trialnum} = mytrial.saccades.start;
                        saccades_end{trialnum} = mytrial.saccades.end;
                        saccade_amplitude{trialnum} = mytrial.saccades.amplitude';
                        saccades_amplitude_standarddeviation{trialnum} = mytrial.saccades.amplitude_variation;
                        saccades_duration{trialnum} = mytrial.saccades.duration;
                        saccades_duration_standarddeviation(trialnum) = mytrial.fixations.duration_standard_deviation';                        
                        
                        output{row_num,10} = saccades_start{trialnum} ;
                        output{row_num,11} = saccades_end{trialnum};
                        output{row_num,12} = saccade_amplitude{trialnum} ;
                        output{row_num,13} = saccades_amplitude_standarddeviation{trialnum}';
                        output{row_num,14} = saccades_duration{trialnum};
                        output{row_num,15} = saccades_duration_standarddeviation(trialnum);
                        
                        row_num = row_num + 1;
                    end
                case string('full')
                    output = obj.to_matrix('trials', trials,'output', 'extended');
                    
            end
        end        
        function to_csv(obj,filename, varargin)
            p = inputParser;
            p.addRequired('obj')
            p.addRequired('filename')
            p.addParameter('trials', 1:obj.NUM_TRIALS, @(x) isvector(x))
            p.addParameter('output', 'base', @(x) ischar(x) | isvector(x));
            p.parse(obj,filename, varargin{:})
            output = obj.to_matrix(varargin{:});
            switch p.Results.output
                case 'base'
                    headers = {'TRIAL_NUMBER'; 'FIXATION_COUNT'; 'SACCADE_COUNT'};
                    output_table = array2table(output);
                    output_table.Properties.VariableNames = headers;
                    writetable(output_table,filename);
                case 'extended'
                    headers = {'TRIAL_NUMBER'; 'FIXATION_COUNT'; 'SACCADE_COUNT';'FIXATION_STARTTIME'; 'FIXATION_ENDTIME'; ...
                        'FIXATION_X_AVG'; 'FIXATION_Y_AVG';'FIXATION_DURATION'; 'FIXATION_DURATION_DEVIATION'; ... 
                        'SACCADE_STARTTIME'; 'SACCADE_ENDTIME'; 'SACCADEAMPLITUDE'; 'SACCADEAMPLITUDE_DEVIATION'; ...
                        'SACCADE_DURATION'; 'SACCADE_DURATION_DEVIATION'}';
                    [output{1,:}] = headers{:};
                    util.cell2csv(filename, output, ',')
            end
        end
        % not organized
        function requested_trial = gettrial(obj, trial_number,varargin)
            %Returns the requested trial number as a trial object. If given
            %a start_event and end_event, it will accordingly bound the
            %datasize
            %% Parsing Arguments
            p = inputParser;
            addRequired(p, 'obj')
            addRequired(p, 'trial_number')
            addOptional(p, 'start_event',' ')
            addOptional(p, 'end_event',' ')
            addOptional(p, 'roi','')
            % TODO : add spatial ROI on gettrial
            p.parse(obj,trial_number, varargin{:});
            start_event = p.Results.start_event;
            end_event = p.Results.end_event;
            requested_trial = trial(obj, trial_number,[start_event;end_event]);
        end
        function plot_trial(obj,trial_no)
            x = obj.data{1,1}(trial_no).gx;
            x(x>1000) = nan;
            y = obj.data{1,1}(trial_no).gy;
            y(y>1000) = nan;
            saccades = obj.data{1,1}(trial_no).Saccades.sttime;
            figure
            hold on
            plot(x)
            plot(y)
            for saccade = saccades
                plot([saccade/2 saccade/2], [1 1000])
            end
        end
        % default overwrite 
        function varargout = subsref(obj,S)
            [objfields,behfields] = get_all_fields(obj);
            if length(S) == 1
                if S.type == '()'
                    [varargout{1:nargout}] = obj.trial__(S.subs{1});
                elseif  ismember(S.subs,[methods('iTrack');properties('iTrack')])
                    [varargout{1:nargout}]  = obj.subsref@iTrack(S);
                elseif ismember(S.subs,[methods('participant');properties('participant')])
                    [varargout{1:nargout}] = builtin('subsref',obj,S);
                elseif ismember(S.subs,objfields)
                    [varargout{1:nargout}]  = obj.subsref@iTrack(S);
                elseif ismember(S.subs, [methods('trial');properties('trial')])
                    for i = 1:obj.NUM_TRIALS
                        subsref(obj.TRIALS{i},S)
                    end
                end
            else
                if S(1).type == '()'
                   reqtrial = obj.trial__(S(1).subs{1});
                   builtin('subsref',reqtrial, S(2));
                   [varargout{1:nargout}] = reqtrial;
                elseif ismember(S(1).subs,[methods('participant');properties('participant')]) && ...
                    ~ismember(S(1).subs,[methods('iTrack');properties('iTrack')]);
                    [varargout{1:nargout}] = builtin('subsref',obj,S);
                elseif ismember(S(1).subs, [methods('trial');properties('trial')])
                    for i = 1:obj.NUM_TRIALS
                       [varargout{1:nargout}] =  subsref(obj.TRIALS{i},S)
                    end
                else
                    [varargout{1:nargout}]  = builtin('subsref',obj,S);
                end
            end
        end
    end
    
    methods (Hidden)
        function requested_trial = trial__(obj, trial_number)
            try 
                requested_trial = obj.TRIALS{trial_number};
            catch ME
                switch ME.identifier
                    case 'MATLAB:cellRefFromNonCell' 
                       error( ' Please set your trials before requesting them')
                    otherwise 
                        warning( 'Do you have %d trials?' , trial_number)
                        rethrow (ME)
                end
            end
        end
    end
    
    methods (Static) 
            function participant_list = participants_from_fixations(filename)
            participant_key = 'RECORDING_SESSION_LABEL';
            trial_key = 'trial';
            fixation_table = read_fixationreports(filename);
            participants = table2array(unique(fixation_table(:,participant_key)));
            num_participants = length(participants);
            for participant_number = 1:num_participants
                p_idx = find(table2array(fixation_table(:,participant_key)) == participants(participant_number));
                p_table = fixation_table(p_idx,:);
                num_trials = height(unique(p_table(:,trial_key)));                
                participant_list{participant_number} = participant('from_fixation', ...
                            'data', table2cell(p_table), 'num_trials',num_trials );
            end
        end

    end
end


function RSVFixationReportOutput = read_fixationreports(filename)
 delimiter = '\t';
 startRow = 2;
 
 %% Read columns of data as text:
 % For more information, see the TEXTSCAN documentation.
 formatSpec = '%s%s%s%s%s%s%s%s%s%s%s%s%[^\n\r]';
 
 %% Open the text file.
 fileID = fopen(filename,'r');
 
 %% Read columns of data according to the format.
 % This call is based on the structure of the file used to generate this
 % code. If an error occurs for a different file, try regenerating the code
 % from the Import Tool.
 dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'TextType', 'string', 'HeaderLines' ,startRow-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
 
 %% Close the text file.
 fclose(fileID);
 
 %% Convert the contents of columns containing numeric text to numbers.
 % Replace non-numeric text with NaN.
 raw = repmat({''},length(dataArray{1}),length(dataArray)-1);
 for col=1:length(dataArray)-1
     raw(1:length(dataArray{col}),col) = mat2cell(dataArray{col}, ones(length(dataArray{col}), 1));
 end
 numericData = NaN(size(dataArray{1},1),size(dataArray,2));
 
 for col=[1,2,4,6,8,9,10,11,12]
     % Converts text in the input cell array to numbers. Replaced non-numeric
     % text with NaN.
     rawData = dataArray{col};
     for row=1:size(rawData, 1)
         % Create a regular expression to detect and remove non-numeric prefixes and
         % suffixes.
         regexstr = '(?<prefix>.*?)(?<numbers>([-]*(\d+[\,]*)+[\.]{0,1}\d*[eEdD]{0,1}[-+]*\d*[i]{0,1})|([-]*(\d+[\,]*)*[\.]{1,1}\d+[eEdD]{0,1}[-+]*\d*[i]{0,1}))(?<suffix>.*)';
         try
             result = regexp(rawData(row), regexstr, 'names');
             numbers = result.numbers;
             
             % Detected commas in non-thousand locations.
             invalidThousandsSeparator = false;
             if numbers.contains(',')
                 thousandsRegExp = '^\d+?(\,\d{3})*\.{0,1}\d*$';
                 if isempty(regexp(numbers, thousandsRegExp, 'once'))
                     numbers = NaN;
                     invalidThousandsSeparator = true;
                 end
             end
             % Convert numeric text to numbers.
             if ~invalidThousandsSeparator
                 numbers = textscan(char(strrep(numbers, ',', '')), '%f');
                 numericData(row, col) = numbers{1};
                 raw{row, col} = numbers{1};
             end
         catch
             raw{row, col} = rawData{row};
         end
     end
 end
 
 
 %% Split data into numeric and string columns.
 rawNumericColumns = raw(:, [1,2,4,6,8,9,10,11,12]);
 rawStringColumns = string(raw(:, [3,5,7]));
 
 
 %% Replace non-numeric cells with NaN
 R = cellfun(@(x) ~isnumeric(x) && ~islogical(x),rawNumericColumns); % Find non-numeric cells
 rawNumericColumns(R) = {NaN}; % Replace non-numeric cells
 
 %% Make sure any text containing <undefined> is properly converted to an <undefined> categorical
 for catIdx = [1,2,3]
     idx = (rawStringColumns(:, catIdx) == string('<undefined>'));
     rawStringColumns(idx, catIdx) = string();
 end
 
 %% Create output variable
 RSVFixationReportOutput = table;
 RSVFixationReportOutput.RECORDING_SESSION_LABEL = cell2mat(rawNumericColumns(:, 1));
 RSVFixationReportOutput.block = cell2mat(rawNumericColumns(:, 2));
 RSVFixationReportOutput.category = categorical(rawStringColumns(:, 1));
 RSVFixationReportOutput.cb = cell2mat(rawNumericColumns(:, 3));
 RSVFixationReportOutput.condition = categorical(rawStringColumns(:, 2));
 RSVFixationReportOutput.imagename = cell2mat(rawNumericColumns(:, 4));
 RSVFixationReportOutput.set = categorical(rawStringColumns(:, 3));
 RSVFixationReportOutput.trial = cell2mat(rawNumericColumns(:, 5));
 RSVFixationReportOutput.TRIAL_LABEL = cell2mat(rawNumericColumns(:, 6));
 RSVFixationReportOutput.CURRENT_FIX_DURATION = cell2mat(rawNumericColumns(:, 7));
 RSVFixationReportOutput.CURRENT_FIX_X = cell2mat(rawNumericColumns(:, 8));
 RSVFixationReportOutput.CURRENT_FIX_Y = cell2mat(rawNumericColumns(:, 9));
 end
