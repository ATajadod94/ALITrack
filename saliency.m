%testCase = participanttest;
%res = run(testCase);



%% Loading Raw Data
p_folder = 'testdata/raw/aj031ro.edf';
myparticipant = participant(p_folder);

%% Calculating Base statistics

% First, we need to create trials . In this step, ROI's can also be set.
myparticipant.set_trials('start_event',"Study_display",'end_event', "Blank_display");
% After the trials are already set, the base statistics can be used.

% First, find out how many trials there are
num_trials = myparticipant.NUM_TRIALS;
myparticipant.set_base(1:num_trials);

%1) Get your Trial
mytrial = myparticipant(1);

%2 ) Explore!
disp(mytrial)


myparticipant.makeROIs(ones(4,1), 'shape', 'file' ,'fromfile', '/Users/ryanlab/Desktop/AliT/Data/ALItracker_Data/aj031ro/M102.jpg.ias','clear',1);
myparticipant.entropy({"2","3","4"})
face = imread('/Users/ryanlab/Desktop/AliT/Data/ALItracker_Data/aj031ro/M102.jpg');


x_temp = obj.x;
y_temp = obj.y;
x_temp(isnan(obj.x)) = 1000;
y_temp(isnan(obj.y)) = 1000;

[obj.angular_acceleration, obj.angular_velocity] = util.Speed_Deg(lowpass(x_temp,1000,10),lowpass(y_temp,1000,10), 700.0 , 250.0, 340.0 ,944.0,1285.0, 500);


obj.angular_velocity(isnan(obj.angular_velocity)) = 1000;
obj.angular_velocity = lowpass(obj.angular_velocity, 1000,10);
obj.angular_velocity(isnan(obj.angular_velocity)) = 1000;
obj.angular_velocity = lowpass(obj.angular_velocity, 1000,10);