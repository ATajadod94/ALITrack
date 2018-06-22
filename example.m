clear;
close all;

%using Participant Class
%p_folder= '/Users/ryanlab/Desktop/AliT/Data/ALItracker_Data/2003';
%myparticipant = participant(2003, p_folder);
%p_folder = '/Users/ryanlab/Desktop/AliT/Data/ALItracker_Data/aj031ro/aj031ro.edf';
%p_folder = '/Users/Ali/Desktop/Baycrest/ALITrack/testdata/aj031ro.edf';
p_folder = '/Users/ryanlab/Desktop/AliT/Data/ALItracker_Data/svrr101/svrr101.edf';

myparticipant = participant(p_folder, 'samples', true);
tic
myparticipant.set_trial_features(1:864,'start_event','stimDisplay', 'end_event', 'stimDuration')
toc

trial = gettrial(myparticipant,1);
trial.number_of_fixation
trial.number_of_saccade
trial.duration_of_fixation
trial.duration_of_saccade
trial.location_of_fixation
trial.location_of_saccade
trial.amplitude_of_saccade
trial.deviation_of_duration_of_fixation
trial.deviation_of_duration_of_saccade
trial.set_grid('default')
trial.animate()


%% in development 
trial.set_eyelink_saccade

%condition(myparticipant, @fixmlt_importer);

%windowtype :{durationofword,before,after}
%followingindex : {how long}
