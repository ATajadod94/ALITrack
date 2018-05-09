classdef trial < data
    properties 
        parent
        trial_no 
        trial_fieldname
        x
        y
        rho
        theta
        num_fixations
        fixation_location
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
            num_colors = ceil(num_samples / 100);
            colorvector = [255:-255/num_colors:0;zeros(1,num_colors+1) ;0:255/num_colors:255]'/255;       
            for i =2:num_colors-1
              polarplot(obj.theta((i-1)*100:i*100) , obj.rho((i-1)*100:i*100), 'color', colorvector(i,:));
              hold on;
            end
        end
        function number_of_fixation(obj)
            obj.num_fixations = length(obj.parent.data.fixation_start.(obj.trial_fieldname));
        end
        function duration_of_fixation(obj)
            obj.fixation_duration = (obj.parent.data.fixation_duration.(obj.trial_fieldname));
        end
        function location_of_fixation(obj)
            obj.fixation_location = [obj.parent.data.datfile(obj.trial_no).Fixations.gavx ;obj.parent.data.datfile(obj.trial_no).Fixations.gavy];
        end
        function amplitude_of_saccade(obj)
            obj.saccade_amplitude =  (obj.parent.data.fixation_duration.(obj.trial_fieldname));       
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