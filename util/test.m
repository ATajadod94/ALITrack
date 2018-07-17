close all
scatter(myparticipant.trials{1, 1}.x,myparticipant.trials{1, 1}.y)
hold on
scatter(myparticipant.trials{1, 1}.fixation_location(1,:) ,myparticipant.trials{1, 1}.fixation_location(2,:),'r')

num_saccades = length(myparticipant.trials{1, 1}.saccade_location);

for i = 1:num_saccades
    line([myparticipant.trials{1, 1}.saccade_location(1,i),myparticipant.trials{1, 1}.saccade_location(3,i)] , ...
        [myparticipant.trials{1, 1}.saccade_location(2,i),myparticipant.trials{1, 1}.saccade_location(4,i)],'LineWidth',2,'color','k')
end


for i = 1:4
hold on;
rectangle('position', roi(i,2:end))
end


num_trees = 10;
for trials = 1:70
    features = [features, [myparticipant.trials{1, trials}.rho;myparticipant.trials{1, trials}.theta]];
    results =  [results, myparticipant.trials{1, trials}.issaccadeorfixation];
    time = [time,  [myparticipant.trials{1,trials }.sample_time]];
end

B = TreeBagger(num_trees,features',results');



t_2 = [myparticipant.trials{1, 2}.rho;myparticipant.trials{1, 2}.theta];
t2_result = predict(B,t_2');
for i = 1:length(t2_result)
   t2_array(i) =  str2num(cell2mat(t2_result(i)));
end



