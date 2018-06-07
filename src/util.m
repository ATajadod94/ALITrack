classdef util < handle
    % inherited from data. Sets, calculates and plots trial specific data
    methods(Static)
        function score_array = zscore(data)
          if ~isa(data,'double')
              data = double(data);
          end
          score_array = (data - mean(data))/ std(data);
        end
    
        function sim_transition(transitions, targets)
            mysequence = []; % help targs 
            all_targets_hit = False; % boolean 
            
            while ~all_targets_hit 
                for i = 1:transitions
                    visited_state = randi(length(targets));
                    visited_state = targets(visited_state);
                    mysequence = [mysequence visited_state];                                                        
                end
            end
            
            
        end
        
        
    end
    
    
end
