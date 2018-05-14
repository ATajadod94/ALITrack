classdef trial < data
    properties 
        parent
        trial_no 
        trial_fieldname
        x
        y
        rho
        theta
        %Fixation features 
        num_fixations
        fixation_location
        fixation_duration_variation
        
        %Saccade features
        num_saccades
        num_fixation
        sample_time
        issaccade
        isfixation
        issaccadeorfixation
        num_samples
        saccade_location
        saccade_duration_variation
    end
    methods
        function obj = trial(parent, data, trial_no)
          obj.parent = parent;
          obj.trial_fieldname = ['trial_' int2str(trial_no)];
          obj.trial_no = trial_no;
          obj.x = data(trial_no).Events.gstx;
          obj.y = data(trial_no).Events.gsty;
        end
        function plot(obj)
            [obj.theta, obj.rho] = cart2pol(obj.x, obj.y);
            num_samples = length(obj.theta);
            color_per_sample = 10;
            num_colors = ceil(num_samples / color_per_sample);
            colorvector = [255:-255/num_colors:0;zeros(1,num_colors+1) ;0:255/num_colors:255]'/255;       
            for i =2:num_colors-1
              polarplot(obj.theta((i-1)*color_per_sample:i*color_per_sample) ...
              , obj.rho((i-1)*color_per_sample:i*color_per_sample), 'color', ...
              colorvector(i,:));
              hold on;
            end
        end
        function get_polar(obj)
          [obj.theta, obj.rho] = cart2pol(obj.x, obj.y);
        end
        function number_of_fixation(obj)
            obj.num_fixations = length(obj.parent.data.fixation_start.(obj.trial_fieldname));
        end
        function number_of_saccade(obj)
            obj.num_saccades = length(obj.parent.data.saccade_start.(obj.trial_fieldname));
        end
        function duration_of_fixation(obj)
            obj.fixation_duration = obj.parent.data.fixation_duration.(obj.trial_fieldname);
        end
        function duration_of_saccade(obj)
            obj.saccade_duration = obj.parent.data.saccade_duration.(obj.trial_fieldname);
        end
        function location_of_fixation(obj)
            obj.fixation_location = [obj.parent.data.datfile(obj.trial_no).Fixations.gavx ;obj.parent.data.datfile(obj.trial_no).Fixations.gavy];
        end
        function location_of_saccade_endpoints(obj)
            obj.saccade_location = [obj.parent.data.datfile(obj.trial_no).Saccades.gstx; obj.parent.data.datfile(obj.trial_no).Saccades.gsty;
                                    obj.parent.data.datfile(obj.trial_no).Saccades.genx; obj.parent.data.datfile(obj.trial_no).Saccades.geny];        
        end
        function amplitude_of_saccade(obj)
            obj.saccade_amplitude =  (obj.parent.data.fixation_duration.(obj.trial_fieldname));       
        end
        function deviation_of_duration_of_fixation(obj)
            if isempty(obj.fixation_duration)
                duration_of_fixation(obj)
            end
            obj.fixation_duration_variation = zscore(double(obj.fixation_duration));
                    
        end
        function get_issaccade(obj)
            obj.saccade_start = obj.parent.data.saccade_start.(obj.trial_fieldname);
            obj.sample_time = obj.parent.data.datfile(obj.trial_no).Events.sttime - obj.parent.data.datfile(obj.trial_no).Events.sttime(1);
            obj.num_samples  = length(obj.x);
            obj.issaccade = zeros(size(obj.sample_time));
            for i = 1:obj.num_saccades
                time_of_saccade = [obj.saccade_start(i), obj.saccade_start(i) + obj.saccade_duration(i)];
                idx = obj.sample_time >= time_of_saccade(1) & obj.sample_time <= time_of_saccade(2);
                if isempty(find(idx,1))
                    idx = find(obj.sample_time >= time_of_saccade(1),1);
                end
                obj.issaccade(idx) = i ;
            end
        end
        function get_isfixation(obj)
            obj.fixation_start = obj.parent.data.fixation_start.(obj.trial_fieldname);
            obj.num_samples  = length(obj.x);
            obj.isfixation = zeros(size(obj.sample_time));
            obj.num_fixation = length(obj.fixation_start);
            for i = 1:obj.num_fixation
                time_of_saccade = [obj.fixation_start(i), obj.fixation_start(i) + obj.fixation_duration(i)];
                idx = obj.sample_time >= time_of_saccade(1) & obj.sample_time <= time_of_saccade(2);
                if isempty(find(idx,1))
                    idx = find(obj.sample_time >= time_of_saccade(1),1);
                end
                obj.isfixation(idx) = i ;
            end
            obj.issaccadeorfixation = zeros(size(obj.sample_time));
            obj.issaccadeorfixation(find(obj.issaccade)) = 1;
            obj.issaccadeorfixation(find(obj.isfixation)) = -1;
       end
        function deviation_of_duration_of_saccade(obj)
            if isempty(obj.saccade_duration)
                duration_of_saccade(obj)
            end
            obj.saccade_duration_variation = zscore(double(obj.saccade_duration));    
        
        end
        function regionsofinterest(obj)
            if isempty(obj.fixation_location)
                location_of_fixation(obj)
            end
            figure
            hold on
            a = [obj.fixation_location' , kmeans(obj.fixation_location',10)];
            for i=1:10
                 scatter(a(a(:,3) == i,1), a(a(:,3) == i,2))
            end
        end
       end
end