classdef participanttest < matlab.unittest.TestCase
    
    %% Test Method Block
    methods (Test)
        
        %% Test Function
        function test_loadingraw(testCase)      
            %% This function tests to ensure that the raw data can be 
            % correctly loaded. In this way, it is testing Itrack.
            p_folder = 'testdata/aj031ro.edf';
            actSolution = participant(p_folder);
            
            %% Check load completed 
            testCase.assertClass(actSolution, 'participant') 
        end
                %% Test Function
        function test_basefunctions(testCase)      
            %% This function tests to ensure that the raw data can be 
            % correctly loaded. In this way, it is testing Itrack.
            p_folder = 'testdata/aj031ro.edf';
            actSolution = participant(p_folder);
            
            %% Check load completed 
            testCase.assertClass(actSolution, 'participant') 
        end
        
    end
end