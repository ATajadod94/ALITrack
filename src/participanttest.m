classdef participanttest < matlab.unittest.TestCase
    
    %% Test Method Block
    methods (Test)
        
        %% Test Function
        %{
        function test_loadingraw(rawtestCase)
            %% This function tests to ensure that the raw data can be
            % correctly loaded. In this way, it is testing Itrack.
            p_folder = 'testdata/raw/aj031ro.edf';
            actSolution = participant(p_folder);
            
            %% Check load completed
            rawtestCase.assertClass(actSolution, 'participant')
        end
        %}
        %% Test Function
        function test_basefunctions(basetestCase)
            %% This function tests to ensure that the raw data can be
            % correctly loaded. In this way, it is testing Itrack.
            test = 'testdata/basic/aj031ro.mat';
            actual = 'testdata/basic/aj031ro_actual.mat';
            myparticipant = basefunctions(test);
            %% Check load completed
            myparticipant_actual = loadraw(actual);
            for trial_number = 1:length(myparticipant.TRIALS)
                basetestCase.verifyEqual(myparticipant.TRIALS{trial_number}.saccades,...
                    myparticipant_actual.TRIALS{trial_number}.saccades);
                basetestCase.verifyEqual(myparticipant.TRIALS{trial_number}.fixations,...
                    myparticipant_actual.TRIALS{trial_number}.fixations);
            end
         end
%         
        function test_extendedfunctions(basetestCase)
            %% This function tests to ensure that the raw data can be
            % correctly loaded. In this way, it is testing Itrack.
            test = 'testdata/extended/aj031ro.mat';
            actual = 'testdata/extended/aj031ro_actual.mat';
            myparticipant = basefunctions(test);
            %% Check load completed
            myparticipant_actual = loadraw(actual);
            for trial_number = 1:length(myparticipant.TRIALS)
                basetestCase.verifyEqual(myparticipant.TRIALS(trial_number).saccades,...
                                        myparticipant_actual(trial_number).TRIALS);
            end
       end        
    end
end
function myparticipant = loadraw(matfile)
    %% assumes matfile contains a raw loaded participant object
    % returns the given participant object
    loaded_struct = load(matfile, 'myparticipant');    
    myparticipant = loaded_struct.myparticipant;
end
function myparticipant = basefunctions(matfile)
%% assumes matfile contains a raw loaded participant object
% returns and sets the base statistics for the given participant
loaded_struct = load(matfile);    
myparticipant = loaded_struct.myparticipant;
myparticipant.set_trials();
num_trials = myparticipant.NUM_TRIALS;
myparticipant.set_base(1:num_trials);

end