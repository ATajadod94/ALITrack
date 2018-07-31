%% Loading Data
p_folder = 'testdata/raw/aj031ro.edf'; 
myparticipant = participant(p_folder); 
myparticipant.set_trials();
myparticipant.set_base();

%% Writing data to file
%tic
Output_file = '/Users/ryanlab/Desktop/AliT/Data/ALItracker_Data/sample_output.csv';
myparticipant.to_csv(Output_file)
myparticipant.to_csv(Output_file,'output', 'extended')
%toc

myparticipant.set_trials('start_event',"Study_display",'end_event', "Blank_display");
myparticipant.to_csv(Output_file,'output', 'extended')


%% Saving Data
save('myparticipant.mat','myparticipant')
clear 
load('myparticipant.mat');

%% Plotting data
mytrial = myparticipant(15);
mytrial.fixation_heat_map()