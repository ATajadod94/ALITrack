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
myparticipant.word_saccadefinder()
