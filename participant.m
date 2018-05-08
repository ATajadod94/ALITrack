classdef participant < handle
    properties
        id
        address
        data
        audio
    end
    
    methods
      function setdata(obj)
          
        data_file = data;
        data_file.address = [obj.address filesep int2str(obj.id) '.edf'];
        data_file.getmatfiles()
        data_file.setsaccades()
        data_file.setfixations()
        obj.data = data_file;

      end
      function setaudio(obj)
         audio_file = audio; %no I didn't matlab
         audio_file.address = obj.address;
         audio_file.transcribe()
         audio_file.get_timestamps() 
         obj.audio = audio_file;
      end
      function word_saccadefinder(obj,window_before, window_after)
          for trial = 1:obj.audio.num_trials
               trial_field = ['trial_' int2str(trial)];
               audio_struct = obj.audio.words.(trial_field);
               saccade_struct = obj.data.saccade_start.(trial_field);
               fixation_struct = obj.data.fixation_start.(trial_field);
               for word_num = 1:length(audio_struct)
                   start_time = audio_struct(word_num).start_time * 100 - window_before  ;
                   end_time = audio_struct(word_num).end_time * 100  + window_after;
                   saccade_index = find(saccade_struct <= end_time & saccade_struct>= start_time);
                   fixation_index =  find(fixation_struct <= end_time & fixation_struct>= start_time);
                   audio_struct(word_num).num_saccades =  length(saccade_index);
                   audio_struct(word_num).saccade_duration = obj.data.saccade_duration.(trial_field)(saccade_index);
                   audio_struct(word_num).saccade_amplitude = obj.data.saccade_amplitude.(trial_field)(saccade_index);
                   audio_struct(word_num).saccade_peakvelocity = obj.data.saccade_peakvelocity.(trial_field)(saccade_index);
                   audio_struct(word_num).saccade_averagevelocity = obj.data.saccade_avgvelocity.(trial_field)(saccade_index);
                   audio_struct(word_num).num_fixation = length(fixation_index);
                   audio_struct(word_num).fixation_start = obj.data.fixation_duration.(trial_field)(fixation_index);
               end 
               obj.audio.words.(trial_field) = audio_struct;

          end
      end
    end     
end 