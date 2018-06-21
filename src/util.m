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
      
       function [acceleration,speed] = Speed_Deg(X, Y, distance , height_mm, width_mm , height_px , width_px, time)
            hor = atan((width_mm / 2) / distance) * (180 / pi) * 2 / width_px * X;
            ver = atan((height_mm / 2) / distance) * (180 / pi) * 2 / height_px * Y;
            % bin into groups 
            num_bins = 2;
            hor_grouped = arrayfun(@(i) mean(hor(i:i+num_bins-1)),1:num_bins:length(hor) - num_bins+1);
            ver_grouped = arrayfun(@(i) mean(ver(i:i+num_bins-1)),1:num_bins:length(ver) - num_bins+1);
            time_grouped = arrayfun(@(i) mean(time(i:i+num_bins-1)),1:num_bins:length(time) - num_bins+1);
            speed = [0, sqrt( diff(hor_grouped) .^ 2 + diff(ver_grouped) .^2) ./ diff(time_grouped)];
            acceleration =  [0,diff(speed) ./ diff(time_grouped)];
            speed = repelem(speed,2);
            acceleration = repelem(acceleration,2);
       end 

        
    end
    
    
end
