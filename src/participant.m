classdef participant < iTrack
    % Get Data, Trials , conditions and features for a given participant
    properties
        trials % Collection of Trial objects
        num_trials % number of trials for a given participant 
    end    
    methods
        function obj = participant(use_edf, varargin)         
            obj = obj@iTrack(use_edf, varargin{:});
            if ~use_edf
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
                obj.data{1}(obj.num_trials).gx = [];
                obj.data{1}(obj.num_trials).gy = [];
                obj.data{1}(obj.num_trials).time = [];
                obj.data{1}(obj.num_trials).numsamples = [];
                 
                obj.data{1}(obj.num_trials).events = struct();
                obj.data{1}(obj.num_trials).events.message = {};
                obj.data{1}(obj.num_trials).events.time = {};
                % vectorized way of setting multiple structs 
                [obj.data{1}.gx] = p.Results.x{:}; 
                [obj.data{1}.gy] = p.Results.y{:};
                [obj.data{1}.time] = p.Results.time{:};
                events = num2cell(p.Results.events); 
                [obj.data{1}.events] = events{:};  
              
                for i=1:obj.num_trials
                    obj.data{1}(i).numsamples = length(obj.data{1}(i).gx);
                    obj.data{1}(i).sample_rate = 1000*unique(diff(obj.data{1}(i).time));
                end
                
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
            addOptional(p,'start_event','Study_display');
            addOptional(p,'end_event','Study_timer');
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
        function set_trial_features(obj,trial_numbers,varargin)
            % Sets all features available for the given trials in the
            % participant object's trials. Check Trial documentaiton for more
            % information
            p = inputParser;
            addRequired(p, 'obj')
            addRequired(p, 'trial_number')
            addOptional(p,'start_event',"Study_display");
            addOptional(p,'end_event',"Study_timer");
            p.parse(p,obj,trial_numbers, varargin{:})
            
            if strcmp('All',trial_numbers)
                trial_numbers = 1:obj.data.datfile.trial_no;
            end
            for i = trial_numbers
                obj.trials{i} = gettrial(obj,i,'start_event', p.Results.start_event,'end_event',  p.Results.end_event);
                obj.trials{i}.number_of_fixation
                obj.trials{i}.number_of_saccade
                obj.trials{i}.duration_of_fixation
                obj.trials{i}.duration_of_saccade
                obj.trials{i}.location_of_fixation
                obj.trials{i}.location_of_saccade
                obj.trials{i}.amplitude_of_saccade
                obj.trials{i}.deviation_of_duration_of_fixation
                obj.trials{i}.deviation_of_duration_of_saccade
                obj.trials{i}.get_polar
                obj.trials{i}.get_issaccade
                obj.trials{i}.get_isfixation
                %obj.trials{i}.regionsofinterest
            end
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
    end    
    methods(Static)        
        function data = getdata(trial)
            data = trial.parent.data{1,1}(trial.trial_no);
        end        
    end
    
end

