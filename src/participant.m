classdef participant < handle
    % Get Data, Trials , conditions and features for a given participant
    properties
        id  % Participant indentifier 
        address % Path of the participant's data folder
        data % Data object, use setdata to create for participant 
        audio % Audio object, use setaudio to create for participant 
        trials % Cell of Trial objects
        condition % Condition Object for participant
    end
    
    methods
      function obj = participant( id, address) 
            % Creates a participant object given an Id and path.
          obj.id = id;
          obj.address = address;
      end
      
      function setdata(obj)      
            % Sets the data object for the participant object. Turns id
            % into a string, sets saccades and fixations for all data 
        data_file = data; %no I didn't matlab
        obj.id = num2str(obj.id);
        data_file.address = [obj.address filesep obj.id '.edf'];
        data_file.getmatfiles()
        data_file.setsaccades()
        data_file.setfixations()
        obj.data = data_file;
      end
      
      function setaudio(obj)
           % Set audio is for transciription data. It can also transcribe
           % the audio file
           
         audio_file = audio; %no I didn't matlab
         audio_file.address = obj.address;
         %audio_file.transcribe()
         audio_file.get_timestamps() 
         obj.audio = audio_file;
      end
      
      function setcondition(obj, fcn)
            %Sets behaviorual condition data for the participant. 
         obj.condition = condition(obj, fcn); %no I didn't matlab
      end
      
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
          start_time = extract_event(obj.data.itrack  ,'search','Study_display','time',true,'behfield',true);
          start_time = start_time.data{1, 1}(trial_number).beh.Study_display;
          end_time = extract_event(obj.data.itrack  ,'search','Study_timer','time',true,'behfield',true);
          end_time = end_time.data{1, 1}(trial_number).beh.Study_timer;


          requested_trial = trial(obj, obj.data.datfile, trial_number,[start_time,end_time]);
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
              obj.trials{i}.location_of_saccade_endpoints
              obj.trials{i}.amplitude_of_saccade
              obj.trials{i}.deviation_of_duration_of_fixation
              obj.trials{i}.deviation_of_duration_of_saccade
              obj.trials{i}.get_polar
              obj.trials{i}.get_issaccade
              obj.trials{i}.get_isfixation
              %obj.trials{i}.regionsofinterest                          
          end
      end
      function get_stringpath(obj)
          a = 2;
      end
      
      function word_saccade_correlator(obj,num_windows, varargin )
          %Adds Saccade/Fixation data to the participants Audio object.
          %Uses num_windows. If Num_windows is not 1,  uses optional arguments 
          %'after' ,'before' and 'duration' optional arguments to determine saccade or fixations  
          if num_windows == 1
                window_before = 0;
                window_after = 0;
          else
              num_window = 1 ;
              index = 1;
            while num_window <= num_windows
               switch varargin{index}
                    case 'duration'
                        window(num_window,:) = [0,1];
                        num_window = num_window + 1;
                        index = index + 1;

                    case 'after' 
                       window(num_window,:) =  [1,varargin{index+1}];
                       num_window = num_window + 1;           
                       index = index + 1;

                    case 'before'
                       window(num_window,:) =  [-1,varargin{index+1}];
                       num_window = num_window + 1;
                       index = index + 1;

                   otherwise
                       index = index + 1;
               end
            end
          end
                  
          for trial = 1:obj.audio.num_trials
               trial_field = ['trial_' int2str(trial)];
               audio_struct = obj.audio.words.(trial_field);
               saccade_struct = obj.data.saccade_start.(trial_field);
               fixation_struct = obj.data.fixation_start.(trial_field);
               saccade_index = [];
               fixation_index = [];
               for word_num = 1:length(audio_struct)
                   start_time = audio_struct(word_num).start_time * 100;
                   end_time = audio_struct(word_num).end_time * 100;
                   for index = 1:num_windows
                       switch window(index,1) 
                           case 0
                                saccade_index =  find(saccade_struct <= end_time & saccade_struct>= start_time);
                                fixation_index =  find(fixation_struct <= end_time & fixation_struct>= start_time);
                           case -1
                               duration = window(index,2);
                               saccade_index = [saccade_index,find(saccade_struct >= start_time-duration & saccade_struct <= start_time)];
                               fixation_index = [fixation_index , find(fixation_struct >= start_time-duration & fixation_struct <= start_time)];
                           case 1 
                               duration = window(index,2);
                               saccade_index = [saccade_index, find(saccade_struct >= end_time & saccade_struct <= end_time + duration)];
                               fixation_index = [fixation_index,  find(fixation_struct >= end_time & fixation_struct <= end_time + duration)];
                       end
                   end

                   audio_struct(word_num).num_saccades =  length(saccade_index);
                   audio_struct(word_num).saccade_duration = obj.data.saccade_duration.(trial_field)(saccade_index);
                   audio_struct(word_num).saccade_amplitude = obj.data.saccade_amplitude.(trial_field)(saccade_index);
                   audio_struct(word_num).saccade_peakvelocity = obj.data.saccade_peakvelocity.(trial_field)(saccade_index);
                   audio_struct(word_num).saccade_averagevelocity = obj.data.saccade_avgvelocity.(trial_field)(saccade_index);
                   audio_struct(word_num).num_fixation = length(fixation_index);
                   audio_struct(word_num).fixation_duration = obj.data.fixation_duration.(trial_field)(fixation_index);
               end 
               obj.audio.words.(trial_field) = audio_struct;

          end
      end
    end     
end 
