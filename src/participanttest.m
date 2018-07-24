classdef participanttest < matlab.unittest.TestCase
    
    %% Test Method Block
    methods (Test)
        
        % Test Function
        function test_loadingraw(rawtestCase)
            % This function tests to ensure that the raw data can be
            %correctly loaded. In this way, it is testing Itrack.
            p_folder = {'testdata/raw/aj031ro.edf';
                        'testdata/raw/svrr101.edf';
                        'testdata/raw/sver101.edf';
                        'testdata/raw/2003.edf';
                        'testdata/raw/sver308.edf';
                        'testdata/raw/id02ma.edf';
                        'testdata/raw/sc04ra.edf'};
            for p_number = 1:length(p_folder)
                actSolution = participant(p_folder{p_number});
            
                % Check load completed
                rawtestCase.assertClass(actSolution, 'participant')
            end
        end
        %% Test Function
        function test_basefunctions(basetestCase)
            %% This function tests to ensure that the raw data can be
            % correctly loaded. In this way, it is testing Itrack.
            tests = {'testdata/Basic/aj031ro.mat';
                        'testdata/Basic/svrr101.mat';
                        'testdata/Basic/sver101.mat';
                        'testdata/Basic/2003.mat';
                        'testdata/Basic/sver308.mat';
                        'testdata/Basic/id02ma.mat';
                        'testdata/Basic/sc04ra.mat'};
            actuals = {'testdata/Basic/aj031ro_actual.mat';
                        'testdata/Basic/svrr101_actual.mat';
                        'testdata/Basic/sver101_actual.mat';
                        'testdata/Basic/2003_actual.mat';
                        'testdata/Basic/sver308_actual.mat';
                        'testdata/Basic/id02ma_actual.mat';
                        'testdata/Basic/sc04ra_actual.mat'};
                    
            for test_num = 1:length(tests)
                test = tests{test_num};
                actual = actuals{test_num};
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
        end
%         
%         function test_extendedfunctions(basetestCase)
%             %% This function tests to ensure that the raw data can be
%             % correctly loaded. In this way, it is testing Itrack.
%             test = 'testdata/extended/aj031ro.mat';
%             actual = 'testdata/extended/aj031ro_actual.mat';
%             myparticipant = basefunctions(test);
%             %% Check load completed
%             myparticipant_actual = loadraw(actual);
%             for trial_number = 1:length(myparticipant.TRIALS)
%                 basetestCase.verifyEqual(myparticipant.TRIALS(trial_number).saccades,...
%                                         myparticipant_actual(trial_number).TRIALS);
%             end
%        end        
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