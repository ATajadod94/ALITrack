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
            basetestCase.verifyEqual(myparticipant.TRIALS{:},myparticipant_actual.TRIALS{:} )
        end
        
        function test_extendedctions(basetestCase)
            %% This function tests to ensure that the raw data can be
            % correctly loaded. In this way, it is testing Itrack.
            test = 'testdata/basic/aj031ro.mat';
            actual = 'testdata/basic/aj031ro_actual.mat';
            myparticipant = basefunctions(test);
            %% Check load completed
            myparticipant_actual = loadraw(actual);
            basetestCase.verifyEqual(myparticipant.TRIALS{:},myparticipant_actual.TRIALS{:} )
        end
        
        
    end
end
function myparticipant = loadraw(matfile)
    %% assumes matfile contains a raw loaded participant object
    % returns the given participant object
    load(matfile);    
end
function myparticipant = basefunctions(matfile)
%% assumes matfile contains a raw loaded participant object
% returns and sets the base statistics for the given participant
load(matfile);
myparticipant.set_trials();
num_trials = myparticipant.NUM_TRIALS;
myparticipant.set_base(1:num_trials);

end