%% Replacing Data viewer 

% Goal : A demo for reading and exporting Data using ALITrack  

% Example 1 : One EDF File 
% Assumption : Using EDF File
% Input : Path to EDF file , Output csv path
% output : CSV file duplicating dataviewer tempelate 

EDF_File = '../../../Data/ALItracker_Data/aj031ro/aj031ro.edf';
Output_file = '/Users/ryanlab/Desktop/AliT/Data/ALItracker_Data/sample_output.csv';

myparticipant = participant(EDF_File);
myparticipant.set_trials();
% feel free to explore the created myparticipant object at this stage



% base case
myparticipant.to_csv(Output_file)

myparticipant.to_csv(Output_file, 'output','eyelink')


%Specifying Trials

myparticipant.to_csv(Output_file, 'trials', 1:10)

myparticipant.to_csv(Output_file, 'trials', 1:10,'output','eyelink')

%Specifying Output

myparticipant.to_csv(Output_file, 'output', 'base')

myparticipant.to_csv(Output_file, 'output', 'extended')

myparticipant.to_csv(Output_file, 'output', 'saccades')

% Putting it together 

myparticipant.to_csv(Output_file, 'trials', [5,7,1], ...
            'output', ["base" , "saccades",  "fixations", "extended"])


        







 