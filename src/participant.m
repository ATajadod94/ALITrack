classdef participant < iTrack
    % Get Data, Trials , conditions and features for a given participant
    properties
        TRIALS % Collection of Trial objects
        NUM_TRIALS % number of trials for a given participant
        EDF_File
    end
    methods
        function obj = participant(use_edf, varargin)
            obj = obj@iTrack('edfs',use_edf);
            if ~use_edf % if use_edf is 0
                p = inputParser;
                p.addRequired('use_edf', @(x) x==0)
                p.addParameter('num_trials', @(x) isscalar(x) );
                p.addParameter('x',@(x) iscell(x));
                p.addParameter('y',@(x) iscell(x));
                p.addParameter('time',@(x) iscell(x));
                p.addParameter('events',@(x) iscell(x));
                p.parse(use_edf,varargin{:})
                
                obj.num_trials = p.Results.num_trials;
                % initlizing to itrack's data strcture
                obj.raw = p.Results;
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
            p.parse(obj, varargin{:})
            
            for i = p.Results.trial_number
                obj.TRIALS{i,1} = trial(obj, i ,varargin{:});
            end
        end
        function requested_trial = gettrial(obj, trial_number,varargin)
            %Returns the requested trial number as a trial object. If given
            %a start_event and end_event, it will accordingly bound the
            %data
            %% Parsing Arguments
            p = inputParser;
            addRequired(p, 'obj')
            addRequired(p, 'trial_number')
            
            p.parse(p,obj,trial_number, varargin{:});
            start_event = p.Results.start_event;
            end_event = p.Results.end_event;
            %% Finding start/end time
            start_time = extract_event(obj  ,'search',start_event,'time',true,'behfield',true);
            start_time = start_time.data{1, 1}(trial_number).beh.(start_event);
            end_time = extract_event(obj  ,'search', end_event,'time',true,'behfield',true);
            end_time = end_time.data{1, 1}(trial_number).beh.(end_event);
            requested_trial = trial(obj, trial_number,[start_time,end_time]);
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
                else
                    a = 2;
                    error('why are we here')
                end
            else
                [varargout{1:nargout}]  = builtin('subsref',obj,S);
            end
        end
        
        
    end
end
