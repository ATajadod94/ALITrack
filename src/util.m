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
        
        function get_ent(number_of_regions, looked_regions)
            %% Inputs
            number_of_regions = 10;
            looked_regions = [1,3,2,5,6,7,9,4,10,9];
            
            %% Variable initlization
            looks_matrix = zeros(number_of_regions,number_of_regions);
            entropy_matix = zeros(number_of_regions,number_of_regions);
            row_total = zeros(number_of_regions);
            col_total = zeros(number_of_regions);
            
            %% Computing the transition matrix
            for looked_index =2:number_of_regions
                from = looked_regions(looked_index-1);
                to = looked_regions(looked_index);
                looks_matrix(from,to) = looks_matrix(from,to)+1;
            end
            
            %% Entropy calculations
            entropy_matrix = looks_matrix * log2(1/looks_matrix);
            
            columntotals = sum(looks_matrix,1); % option 1 for columns, 2 for rows
            rowtotals = sum(looks_matrix,2);
            
            column_entropy = columntotals * log2(1/columntotals);
            row_entropy = rowtotals *  log2(1/rowtotals);
            
            column_entropy_totals = nansum(column_entropy); %nansum excludes nan values
            row_entropy_totals = nansum(row_entropy);
            
            correction = (column_entropy_totals + row_entropy_totals)/2;
            cellenttotal = nansum(nansum(entropy_matrix));
            
            entropy_total = column_entropy_totals + row_entropy_totals - cellenttotal;
            entropytotal = 1-( entropy_total /correction);
        end
    end
    
end
