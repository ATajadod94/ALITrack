classdef data < handle
    properties
        address 
        datfile
        num_trials
        saccade_start
        saccade_duration
        saccade_amplitude
        saccade_peakvelocity
        saccade_avgvelocity
        fixation_start
        fixation_duration 
    end
    
    methods
        function getmatfiles(obj)
            if obj.address
              obj.datfile = edfImport(obj.address);
              obj.datfile = edfExtractInterestingEvents(obj.datfile);
            end
            obj.num_trials = length(obj.datfile);
        end   
   
        function  getsaccades(obj, trial_number) 
            trial_field = ['trial_' int2str(trial_number)];
            obj.saccade_start.(trial_field) = obj.datfile(trial_number).Saccades.sttime;
            obj.saccade_duration.(trial_field) = obj.datfile(trial_number).Saccades.entime -  obj.datfile(trial_number).Saccades.sttime;
            obj.saccade_amplitude.(trial_field) = obj.datfile(trial_number).Saccades.ampl;
            obj.saccade_peakvelocity.(trial_field) = obj.datfile(trial_number).Saccades.pvel;
            obj.saccade_avgvelocity.(trial_field) =  obj.datfile(trial_number).Saccades.avel;
        end
         function  getfixations(obj, trial_number) 
            trial_field = ['trial_' int2str(trial_number)];
            obj.fixation_start.(trial_field) = obj.datfile(trial_number).Fixations.sttime;
            obj.fixation_duration.(trial_field) = obj.datfile(trial_number).Fixations.entime -  obj.datfile(trial_number).Fixations.sttime;
        end
     
        function setsaccades(obj)
            for i = 1:obj.num_trials
                getsaccades(obj,i)
            end
        end
        function setfixations(obj)
            for i = 1:obj.num_trials
                getfixations(obj,i)
            end
        end
        
    end
    
end



