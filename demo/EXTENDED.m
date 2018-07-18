%% Loading Raw Data (check LOADDATA demo)
p_folder = 'testdata/raw/aj031ro.edf'; 
myparticipant = participant(p_folder); 


%% Calculating Base statistics (check BASE demo)
myparticipant.set_trials();
num_trials = myparticipant.NUM_TRIALS;
myparticipant.set_base(1:num_trials);

%% Calculating Extended statistics 

myparticipant.set_extended(1:num_trials);