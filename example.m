%% Description 
% Author : Alireza Tajadod 
% Input : Data : Behavioural EDF Data , Audio : Corresponding audio file 
% Output : 
clear;
close all;

%using Participant Class
%p_folder= '/Users/ryanlab/Desktop/AliT/Data/ALItracker_Data/2003';
%myparticipant = participant(2003, p_folder);

p_folder = '/Users/Ali/Desktop/Baycrest/ALITrack/testdata/aj031ro.edf';
myparticipant = participant(p_folder, 'samples', true);
myparticipant.set_trial_features(1:70,'start_event',"Study_display", 'end_event', "Study_timer")



trial = myparticipant.gettrial(1);
trial.animate()
%using trial class directly
trial = gettrial(myparticipant,1);
trial.number_of_fixation
trial.number_of_saccade
trial.duration_of_fixation
trial.duration_of_saccade
trial.location_of_fixation
trial.amplitude_of_saccade
trial.deviation_of_duration_of_fixation
trial.deviation_of_duration_of_saccade
trial.set_grid('default')
% trial.regionsofinterest



condition(myparticipant, @fixmlt_importer);

%windowtype :{durationofword,before,after}
%followingindex : {how long}
