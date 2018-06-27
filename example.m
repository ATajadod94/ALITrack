clear;
close all;

%% Example for no-edf construction  
%{
load(('/Users/ryanlab/Desktop/AliT/Data/ALItracker_Data/sample_noedf.mat')
myparticipant = participant(0,'num_trials', 70, 'x', x, 'y' , y,'time',time,'events',events);
trial.set_eyelink_saccade(1) %% 1 indicates using the default thereshold 
%}


%% Available edf data for testing 

%{
p_folder = '/Users/ryanlab/Desktop/AliT/Data/ALItracker_Data/svrr101/svrr101.edf';
myparticipant = participant(1,p_folder, 'samples', true);
%myparticipant.set_trial_features('all','start_event','stimDisplay', 'end_event', 'stimDuration')
% Elapsed time is 261.141535 seconds.
%}


p_folder = '../../Data/ALItracker_Data/aj031ro/aj031ro.edf';
myparticipant = participant(1,p_folder, 'samples', true);
trial = gettrial(myparticipant,1,'start_event','Study_display', 'end_event', 'Blank_display');




trial.number_of_fixation
trial.duration_of_fixation
trial.avarage_fixation_duration
trial.max_fixation_duration
trial.min_fixation_duration
trial.deviation_of_duration_of_fixation
trial.location_of_fixation
trial.get_isfixation

trial.number_of_saccade
trial.duration_of_saccade
trial.deviation_of_duration_of_saccade
trial.amplitude_of_saccade
trial.deviation_of_amplitude_of_saccade
trial.average_saccade_amplitude
trial.location_of_saccade
trial.get_issaccade
%Elapsed time is 0.085973 seconds.


trial.set_grid('default')
trial.animate()


trial.set_eyelink_saccade(1) %% 1 indicates using the default thereshold 


%condition(myparticipant, @fixmlt_importer);

%windowtype :{durationofword,before,after}
%followingindex : {how long}
