classdef util < handle
    % inherited from data. Sets, calculates and plots trial specific data
    methods(Static)
        function score_array = zscore(data)
          if ~isa(data,'double')
              data = double(data);
          end
          score_array = (data - mean(data))/ std(data);
        end
        
        function diff_matrix = fixation_distance(fixation)
            diff_matrix = zeros(fixation.number ,fixation.number );
            for i = 1:fixation.number 
                x_values = fixation.average_gazex - fixation.average_gazex(i);
                y_values = fixation.average_gazey - fixation.average_gazex(i);
                diff_matrix(i,:) = sqrt(x_values .^ 2 + x_values .^ 2);
            end
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
