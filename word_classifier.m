%% Description 
% Author : Alireza Tajadod 
% Input : Data : Behavioural EDF Data , Audio : Corresponding audio file 
% Output : 
clear;

myparticipant = participant( );
myparticipant.id = 2003;
myparticipant.address =   '/Users/ryanlab/Desktop/AliT/Data/ALItracker_Data/2003';
myparticipant.setdata()
myparticipant.setaudio()
myparticipant.word_saccadefinder() %window before or after can be used here as arguments  in ms : eg (.....world_saccadefinder(100,100))
