classdef data < handle
    properties
        address 
        datfile
        num_trials
        saccade_start
    end
    
    methods
        function getmatfiles(obj)
            if obj.address
              obj.datfile = edfImport(obj.address);
              obj.datfile = edfExtractInterestingEvents(obj.datfile);
            end
            obj.num_trials = length(obj.datfile);
        end
        
        function fixations = get_fixations(trial)
            pass
        end
        
        function saccades = getsaccades(obj, trial_number) 
            trial_field = ['trial_' int2str(trial_number)];
            obj.saccade_start.(trial_field) = obj.datfile(trial_number).Saccades.sttime;
        end
        
        function setsaccades(obj)
            for i = 1:obj.num_trials
                getsaccades(obj,i)
            end
        end
        
    end
    
end



