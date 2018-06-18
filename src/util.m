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
        
        function [velocity,acceleration] = get_angular_speed(x,y)
            % assuming constant time sampling 
            % math per https://ocw.mit.edu/courses/aeronautics-and-astronautics/16-07-dynamics-fall-2009/lecture-notes/MIT16_07F09_Lec05.pdf
            [theta, r] = cart2pol(x,y);
            er = cos(x)+ sin(y);
            et = - sin(y) + cos(x);
            d_er = et;
            d_et = -er;
            %radical_velocity = diff(x) .* er(1:end-1) + ...
            %                r(1:end-1) .*  d_er(1:end-1);
            velocity = r .* er ;
                      %      r(1:end-1) .* diff(theta) .* d_et(1:end-1);
            acceleration = r .* d_er;
            %er(1:end-2) .* (diff(diff(r)) - r(1:end-2) .* diff(diff(theta))) ;
                %% +  et(1:end-2) .* (r(1:end-2) .* diff(diff(theta)) + 2 * diff(r(1:end-1)) .* diff(theta(1:end-1)));           
        end
        
        
    end
    
    
end
