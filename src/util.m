classdef util < handle
    % a utility class
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
        function [acceleration,speed] = Speed_Deg(X, Y, distance, height_mm, width_mm , height_px , width_px, hz)
            hor = atan((width_mm / 2) / distance) * (180 / pi) * 2 / width_px * X;
            ver = atan((height_mm / 2) / distance) * (180 / pi) * 2 / height_px * Y;
            % bin into groups
            %num_bins = 2;
            %hor_grouped = arrayfun(@(i) mean(hor(i:i+num_bins-1)),1:num_bins:length(hor) - num_bins+1);
            %ver_grouped = arrayfun(@(i) mean(ver(i:i+num_bins-1)),1:num_bins:length(ver) - num_bins+1);
            %time_grouped = arrayfun(@(i) mean(time(i:i+num_bins-1)),1:num_bins:length(time) - num_bins+1);
            speed = [sqrt(diff(hor(1:2:end)).^2 + diff(ver(1:2:end)).^2) * (hz/2), 0 ];
            speed = repelem(speed,2);
            acceleration =  diff([speed , 0]) * (hz);
        end
        
        function bool = inbetween(value, lower, bigger)
            assert(length(lower) == length(bigger), 'Lower and upper bound must have the same dimensions')
            bool = zeros(length(lower),length(value));
            for i = 1:length(lower)
                bool(i,:) = value <= bigger(i) & value >= lower(i);
            end
        end
    end
    
end
