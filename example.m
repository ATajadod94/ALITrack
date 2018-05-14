%% Description 
% Author : Alireza Tajadod 
% Input : Data : Behavioural EDF Data , Audio : Corresponding audio file 
% Output : 
clear;
close all;

%using Participant Class
%p_folder= '/Users/ryanlab/Desktop/AliT/Data/ALItracker_Data/2003';
%myparticipant = participant(2003, p_folder);

p_folder = '/Users/ryanlab/Desktop/AliT/Data/ALITracker_Data/aj031ro';
myparticipant = participant('aj031ro', p_folder);

myparticipant.setdata()
myparticipant.setaudio()

%myparticipant.word_saccade_correlator(3,'duration', 'before' , 100  , 'after', 200)  %myparticipant.word_saccadefinder(numberofwindows,

myparticipant.set_trial_features(1:70)
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