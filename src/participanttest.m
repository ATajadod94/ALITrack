classdef participanttest < matlab.unittest.TestCase
    
    %% Test Method Block
    methods (Test)
        
        %% Test Function
        function test_loadingraw(testCase)      
            %% Exercise function under test
            p_folder = '../../Data/ALItracker_Data/sver308/sver308.edf';
            actSolution = participant('testdata/aj031ro.edf');
            
            %% Verify using test qualification
            testCase.verifyInstanceOf(actSolution,'participant')
        end
    end
end