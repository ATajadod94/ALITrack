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
%mytrial.set_base()
mytrial.fixation_heat_map()
hold on
mytrial.fixation_sequence_plot()
mytrial.makeROIs(ones(4,1), 'shape', 'file' ,'fromfile', '/Users/ryanlab/Desktop/AliT/Data/ALItracker_Data/aj031ro/M102.jpg.ias','clear',1);
mytrial.roi_plot()
hold off


%% Other participant 
p_folder = 'testdata/raw/sver102.edf'; 
myparticipant = participant(p_folder); 
myparticipant.set_trials();
myparticipant.set_base();

Output_file = '/Users/ryanlab/Desktop/AliT/Data/ALItracker_Data/sample_output2.csv';
myparticipant.to_csv(Output_file,'output', 'extended')

mytrial = myparticipant(1);
mytrial.fixation_heat_map()
hold on
mytrial.fixation_sequence_plot()

figure
mytrial.plot_angular_velocity()
