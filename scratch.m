%testCase = participanttest;
%res = run(testCase);



%% Loading Raw Data
p_folder = 'testdata/raw/aj031ro.edf'; 
myparticipant = participant(p_folder); 

%% Calculating Base statistics 

% First, we need to create trials . In this step, ROI's can also be set.
myparticipant.set_trials();
% After the trials are already set, the base statistics can be used. 

% First, find out how many trials there are 
num_trials = myparticipant.NUM_TRIALS;
myparticipant.set_base(1:num_trials);

%1) Get your Trial 
mytrial = myparticipant.gettrial(10);

%2 ) Explore!
disp(mytrial.fields)