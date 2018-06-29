%% Replacing Data viewer 

% Goal : A demo for reading and exporting Data using ALITrack  

% Example 1 : One EDF File 
% Assumption : Using EDF File
% Input : Path to EDF file 
% output : CSV fle duplication dataviewer tempelate 

EDF_File = '../../Data/ALItracker_Data/aj031ro/aj031ro.edf';

myparticipant = participant(EDF_File);
myparticipant.set_trials()

% base case
myparticipant.to_csv()

myparticipant.to_csv('output','eye_link')


%Specifying Trials

myparticipant.to_csv(1:10)

myparticipant.to_csv(1:10,'output','eye_link')

%Specifying Output

myparticipant.to_csv('output', 'base')

myparticipant.to_csv('output', ["base" , "saccades", "fixations"])

% Putting it together 

myparticipant.to_csv([5,7,1], 'output', ["base" , "saccades", "fixations"])








 