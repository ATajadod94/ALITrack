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
        
        
        % math justification : https://ocw.mit.edu/courses/aeronautics-and-astronautics/16-07-dynamics-fall-2009/lecture-notes/MIT16_07F09_Lec05.pdf
        function [ velocity,acceleration] = get_angular_speed(x,y,time)
            % assuming constant time sampling 
%             [th, r] = cart2pol(x,y);
%             %th = rad2deg(theta);
%             er = cos(th)+ sin(th);
%             eth = - sin(th) + cos(th);
%             d_er = eth;
%             d_eth = -er;
%             d_t = diff(time);
%             d_r = [0 , diff(r) ./  d_t];
%             d_th = [0, diff(th) ./  d_t];
%             dd_r = [0, [0 , diff(r,2)] ./ d_t];
%             dd_th = [0, [0 , diff(th,2)] ./ d_t];
%             %velocity = d_r .* er  + r .* d_er;
%             %acceleration = dd_r .* er  + d_r .* d_er + d_r .* d_th .* eth ...
%             %    + r .* dd_th .* eth + r .* d_eth .* d_eth;
%             velocity = r .* d_th;
%             acceleration = [ 0 , diff(velocity) ./ d_t];
            hor = atan((170 / 2) / 700) * (180 / pi) * (2 / 1024) .* x;
            ver = atan((130 / 2) / 700) * (180 / pi) * (2 / 768) .* y;
            velocity = sqrt( diff(hor(1:2:end)) .^ 2 + diff(ver(1:2:end)) .^ 2) ./ diff(time(1:2:end));
            acceleration = [ 0 , diff(velocity)] ./ diff(time(1:2:end));
            %er(1:end-2) .* (diff(diff(r)) - r(1:end-2) .* diff(diff(theta))) ;
                %% +  et(1:end-2) .* (r(1:end-2) .* diff(diff(theta)) + 2 * diff(r(1:end-1)) .* diff(theta(1:end-1)));           
        end
        
        
    end
    
    
end
