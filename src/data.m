classdef data < handle
        % uses Itrack to import the participant's data from the respective
        % EDF file. 
    properties
        address % Adress of the edf file 
        itrack % Itrack object set by importing the edf file
        datfile % Data table for the participant. Edited and appended in usage
        num_trials % Number of trials in the dataset 
        saccade_start %Saccade start times for selected trials 
        saccade_duration %Saccade duration for selected trials 
        saccade_amplitude %Saccade amplitude for selected trials 
        saccade_peakvelocity %Saccade peak velocity for selected trials  
        saccade_avgvelocity %Saccade average velocity for selected trials  
        fixation_start %fixation start times for selected trials  
        fixation_duration %fixation duration for selected trials  
    end
    
    methods
        function getmatfiles(obj)
            % imports the edf file, sets the Itrack, datfile and
            % num_trialds properties. 
            if obj.address
              obj.itrack = iTrack(obj.address,'samples',true);
              obj.datfile = obj.itrack.data{1, 1};
            end
            obj.num_trials = length(obj.datfile);
        end   
   
        function  getsaccades(obj, trial_number) 
            % sets saccade related features for the datafile. Including
            % Saccade_start, duration , amplitude, peakvelocity and average
            % velocity for the given trial number
            trial_field = ['trial_' int2str(trial_number)];
            obj.saccade_start.(trial_field) = obj.datfile(trial_number).Saccades.sttime;
            obj.saccade_duration.(trial_field) = obj.datfile(trial_number).Saccades.entime -  obj.datfile(trial_number).Saccades.sttime;
            obj.saccade_amplitude.(trial_field) = obj.datfile(trial_number).Saccades.ampl;
            obj.saccade_peakvelocity.(trial_field) = obj.datfile(trial_number).Saccades.pvel;
            obj.saccade_avgvelocity.(trial_field) =  obj.datfile(trial_number).Saccades.avel;
        end
         function  getfixations(obj, trial_number) 
            % sets fixation related features for the datafile. Including
            % Fixaation_start and duration for the given trial number
            trial_field = ['trial_' int2str(trial_number)];
            obj.fixation_start.(trial_field) = obj.datfile(trial_number).Fixations.sttime;
            obj.fixation_duration.(trial_field) = obj.datfile(trial_number).Fixations.entime -  obj.datfile(trial_number).Fixations.sttime;
        end
     
        function setsaccades(obj)
            % sets all saccade features for all trials
            for i = 1:obj.num_trials
                getsaccades(obj,i)
            end
        end
        function setfixations(obj)
             % sets all fixatio features for all trials
            for i = 1:obj.num_trials
                getfixations(obj,i)
            end
        end
    end
    
end



