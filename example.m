clear;
close all;

%% Todo : add lines for setting path

%% Example for no-edf construction  
%{
load('/Users/ryanlab/Desktop/AliT/Data/ALItracker_Data/sample_noedf.mat')
myparticipant = participant(0,'num_trials', 70, 'x', x, 'y' , y,'time',time,'events',events);
trial.set_eyelink_saccade(1) %% 1 indicates using the default thereshold 
%}


%% Available edf data for testing 
%paths are relative to wd of the example script

%{
p_folder = '/Users/ryanlab/Desktop/AliT/Data/ALItracker_Data/svrr101/svrr101.edf';
myparticipant = participant(p_folder, 'samples', true);
myparticipant.set_trials('start_event', string('stimDisplay'),'end_event', string('stimDuration')) % change to strings 
%}

% trial = gettrial(myparticipant,1,"start_event","Study_display", "end_event", "Blank_display");


p_folder = '../../Data/ALItracker_Data/sver308/sver308.edf';
myparticipant = participant(p_folder, 'samples', true);
myparticipant.set_trials('start_event',string('stimDisplay'),'end_event', string('stimDuration'));
% TODO : fix the saccade and fixation cut off , universalize the funciton
% written to use for eyelink

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

trial.makeROIs(ones(4,1), 'shape', 'file' ,'fromfile', '/Users/ryanlab/Desktop/AliT/Data/ALItracker_Data/aj031ro/M102.jpg.ias','clear',1);
trial.entropy({"1","2","3","4"})

trial.set_grid('default')
trial.animate()

trial.set_eyelink_saccade(1) %% 1 indicates using the default thereshold 

%windowtype :{durationofword,before,after}
%followingindex : {how long}