%% Description 
% Author : Alireza Tajadod 
% Input : Data : Behavioural EDF Data , Audio : Corresponding audio file 
% Output : 
clear;
close all;
myparticipant = participant(2003, '/Users/ryanlab/Desktop/AliT/Data/ALItracker_Data/2003');
myparticipant.setdata()
z = myparticipant.gettrial(1);
z.regionsofinterest()
z.plot()

myparticipant.setaudio()




myparticipant.word_saccadefinder(3,'duration', 'before' , 100  , 'after', 200)  %myparticipant.word_saccadefinder(numberofwindows,
%windowtype :{durationofword,before,after}
%followingindex : {how long}
