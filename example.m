%% Description 
% Author : Alireza Tajadod 
% Input : Data : Behavioural EDF Data , Audio : Corresponding audio file 
% Output : 
clear;
close all;

%using Participant Class
myparticipant = participant(2003, '/Users/ryanlab/Desktop/AliT/Data/ALItracker_Data/2003');
myparticipant.setdata()
myparticipant.setaudio()

myparticipant.word_saccade_correlator(3,'duration', 'before' , 100  , 'after', 200)  %myparticipant.word_saccadefinder(numberofwindows,

myparticipant.get_trial_features(1:12)
trial = myparticipant.gettrial(1);

%using trial class directly
trial = gettrial(myparticipant,1);
trial.number_of_fixation
trial.number_of_saccade
trial.duration_of_fixation
trial.duration_of_saccade
trial.location_of_fixation
trial.location_of_saccade_endpoints
trial.amplitude_of_saccade
trial.deviation_of_duration_of_fixation
trial.deviation_of_duration_of_saccade
trial.regionsofinterest






%windowtype :{durationofword,before,after}
%followingindex : {how long}
