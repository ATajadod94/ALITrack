%% Description 
% Author : Alireza Tajadod 
% Input : Data : Behavioural EDF Data , Audio : Corresponding audio file 
% Output : 
clear;

p_folder = '/Users/ryanlab/Desktop/AliT/Data/ALItracker_Data/2003';

audio_file = audio;
audio_file.address = p_folder;
audio_file.transcribe()
audio_file.get_timestamps()

data_file = data;
data_file.address = '/Users/ryanlab/Desktop/AliT/Data/ALItracker_Data/2003/2003.edf';
data_file.getmatfiles()
data_file.setsaccades()


for trial = 1:audio_file.num_trials
   trial_field = ['trial_' int2str(trial)];
   audio_struct = audio_file.words.(trial_field);
   data_struct = data_file.saccade_start.(trial_field);
   for word_num = 1:length(audio_struct)
       start_time = audio_struct(word_num).start_time * 100 ;
       end_time = audio_struct(word_num).end_time * 100 ;
       audio_struct(word_num).num_saccades =  length(find(data_struct <= end_time & data_struct>= start_time));
   end 
   audio_file.words.(trial_field) = audio_struct;

end
clearvars -except data_file audio_file
%   
%for saccade_num = 1:length(data_struct)
%       [ dist , index ] = min(abs(double(data_struct(1,saccade_num)) - 1000*([audio_struct.start_time])));
%        data_struct(2,saccade_num) =  categorical(audio_struct(index).Word};
%        data_struct(3,saccade_num) =  dist;
%   end