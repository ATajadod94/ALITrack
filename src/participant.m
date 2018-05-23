classdef participant < iTrack
    % Get Data, Trials , conditions and features for a given participant
    properties
        id  % Participant identifier 
        address % Path of the participant's data folder
        trials % Collection of Trial objects
    end
    
    methods
      function obj = participant(varargin) 
            % Creates a participant object given an Id and path.
            obj = obj@iTrack(varargin{:});
      end
      
           
      %function setcondition(obj, fcn)
      %      %Sets behaviorual condition data for the participant. 
      %   obj.condition = condition(obj, fcn); %no I didn't matlab
      %end
      
      function requested_trial = gettrial(obj, trial_number,varargin)
          %Returns the requested trial number as a trial object. If given
          %a start_event and end_event, it will accordingly bound the
          %data
          
          %% Parsing Arguments
          p = inputParser;
          addRequired(p, 'obj')
          addRequired(p, 'trial_number')
          addOptional(p,'start_event',"Study_display");
          addOptional(p,'end_event',"Study_timer");
          p.parse(p,obj,trial_number, varargin{:})
          
          %% Finding start/end time 
          start_time = extract_event(obj  ,'search','Study_display','time',true,'behfield',true);
          start_time = start_time.data{1, 1}(trial_number).beh.Study_display;
          end_time = extract_event(obj  ,'search','Study_timer','time',true,'behfield',true);
          end_time = end_time.data{1, 1}(trial_number).beh.Study_timer;
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
%               obj.trials{i}.number_of_fixation
%               objo.trials{i}.number_of_saccade
%               obj.trials{i}.duration_of_fixation
%               obj.trials{i}.duration_of_saccade
%               obj.trials{i}.location_of_fixation
%               obj.trials{i}.location_of_saccade
%               obj.trials{i}.amplitude_of_saccade
%               obj.trials{i}.deviation_of_duration_of_fixation
%               obj.trials{i}.deviation_of_duration_of_saccade
%               obj.trials{i}.get_polar
%               obj.trials{i}.get_issaccade
%               obj.trials{i}.get_isfixation
              %obj.trials{i}.regionsofinterest                          
          end
      end
      
    end
   
end 
