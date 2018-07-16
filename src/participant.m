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
            if ~use_edf % if use_edf is 0
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
        function set_trials(obj,varargin)
            % Sets all features available for the given trials in the
            % participant object's trials. Check Trial documentaiton for more
            % information
            p = inputParser;
            p.addRequired('obj')
            p.addParameter('trial_number', 1:obj.NUM_TRIALS, @(x) isvector(x));
            addOptional(p, 'start_event',' ')
            addOptional(p, 'end_event',' ')
            %% TODO: unify this function and requested_trial
            p.parse(obj, varargin{:});
            start_event = p.Results.start_event;
            end_event = p.Results.end_event;
            for i = p.Results.trial_number
                obj.TRIALS{i,1} = trial(obj, i ,[start_event;end_event]);
            end
        end
        function set_base(obj, trials)
            for trial = trials
                obj.TRIALS{trial}.set_base
            end
        end
        function set_extended(obj, trials)
            for trial = trials
                obj.TRIALS{trial}.set_extended
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
            p.addParameter('fiename', obj.EDF_File, @(x) ischar(x))
            p.parse(obj,varargin{:})
            
            trials = p.Results.trials;
            fixation_locations = {};
            saccade_locations= {};
            switch p.Results.output
                case string(base)
                    obj.set_base(trials)
                case string(extende)
                    obj.set_extended(trials)
                case string(saccades)
                    obj.set_extended(trials)
                case string(fixations)
                    obj.set_extended(trials)
                case string(eyelink)
                    obj.set_eyelink(trials)
            end
            switch p.Results.output
                case string(eyelink)
                    for trialnum = trials
                        index(trialnum) = trialnum;
                        fixation_count(trialnum) =  obj.TRIALS{trialnum}.fixations.eye_link.num_fixations;
                        saccade_count(trialnum)  = obj.TRIALS{trialnum}.saccades.eye_link.num_saccades;
                    end
                otherwise
                    for trialnum = trials
                        index(trialnum) = trialnum;
                        fixation_count(trialnum) =  obj.TRIALS{trialnum}.fixations.number;
                        saccade_count(trialnum) = obj.TRIALS{trialnum}.saccades.number;
                        %fixation_locations(trialnum) =  [obj.TRIALS{trialnum}.fixations.start,obj.TRIALS{trialnum}.fixations.end];
                        %saccade_locations(trialnum) = [obj.TRIALS{trialnum}.saccades.start,obj.TRIALS{trialnum}.saccades.end];
                    end
            end
            
            output = [index', fixation_count',saccade_count'];
            
        end
        function to_csv(obj,filename, varargin)
            p = inputParser;
            p.addRequired('obj')
            p.addRequired('filename')
            p.addParameter('trials', 1:obj.NUM_TRIALS, @(x) isvector(x))
            p.addParameter('output', 'base', @(x) ischar(x) | isvector(x));
            p.parse(obj,filename, varargin{:})
            
            headers = {'TRIAL_NUMBER'; 'FIXATION_COUNT'; 'SACCADE_COUNT'};
            output = obj.to_matrix(varargin{:});
            output_table = array2table(output);
            output_table.Properties.VariableNames = headers;
            writetable(output_table,filename);
            %xlswrite(filename,output);
            
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
        function varargout = subsref(obj,S)
            [objfields,behfields] = get_all_fields(obj);
            if length(S) == 1
                if  ismember(S.subs,[methods('iTrack');properties('iTrack')])
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
                if ismember(S(1).subs,[methods('participant');properties('participant')])
                    [varargout{1:nargout}] = builtin('subsref',obj,S);
                elseif ismember(S(1).subs, [methods('trial');properties('trial')])
                    for i = S(2).subs{:}
                        subsref(obj.TRIALS{i},S(1))
                    end
                else
                    [varargout{1:nargout}]  = builtin('subsref',obj,S);
                end
            end
        end
    end
end

