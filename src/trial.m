classdef trial < handle
       % inherited from data. Sets, calculates and plots trial specific data
      
       properties 
        data %Data_file , extracted from participant's ztrack
        trial_no % Number of Trial
        trial_fieldname % Fieldname of Trial in string format
        num_samples % Number of samples 
        sample_time % Time of each sample, used as index 
        x % Sample X value of the eye movement 
        y % Sample Y value of eye movements 
        rho % Distance parameter of the sample Eye momvemnt in polar form 
        theta % Angle parametger of the sample Eye movement in polar form
        issaccadeorfixation % Indicates whether each sample is a saccade(1) or fixation (-1) or neither (0) 

        %Fixation features 
        num_fixations % number of fixations in trial 
        fixation_location %location of fixation in cartesian formo
        fixation_duration_variation % variation in the duraiton of fixation 
        isfixation % Array indicating whether each sample is part of a fixation 
        
        %Saccade features
        num_saccades % Number of saccades in trial 
        issaccade % Array indicatig whether each sample is oart of a saccade 
        saccade_location % Location of Saccades, includes starting points (saccade_location[1:2, :] and end points saccade_location[3:4,:] 
        saccade_duration_variation %Variation in saccade durations
        
        %Conditions 
        condition %Associated condition for the given trial 
        
       end
    
    methods
        function obj = trial(participant, trial_no, varargin)
             % Given a parent data file, the data and a trial number with
             % optional arguments for start and end time of relevant data
             % creates a trial object. Also sets the x and y parameter
             
          if nargin == 3
            time = varargin{1};
            start_time = time(1);
            end_time = time(2);
          end
          obj.trial_fieldname = ['trial_' int2str(trial_no)];
          obj.trial_no = trial_no;
          obj.data = participant.Itrack.data{1,1}(trial_no);
          obj.x = data(trial_no).gx(start_time:end_time);
          obj.y = data(trial_no).gy(start_time:end_time);
          obj.num_samples = length(obj.x);
          obj.sample_time = obj.data.StartTime + uint32(0:obj.num_samples - 1) * uint32(obj.data.sample_rate);
        end
        
%         function plot(obj)
%             [obj.theta, obj.rho] = cart2pol(obj.x, obj.y);
%             num_samples = length(obj.theta);
%             color_per_sample = 10;
%             num_colors = ceil(num_samples / color_per_sample);
%             colorvector = [255:-255/num_colors:0;zeros(1,num_colors+1) ;0:255/num_colors:255]'/255;       
%             for i =2:num_colors-1
%               polarplot(obj.theta((i-1)*color_per_sample:i*color_per_sample) ...
%               , obj.rho((i-1)*color_per_sample:i*color_per_sample), 'color', ...
%               colorvector(i,:));
%               hold on;
%             end
%         end


        function animate(obj)
             % Creates and draws an animation plot for the trial 
            h = animatedline('MaximumNumPoints',1,'color', 'r', 'marker','*');
            a = tic;
            for k = 1:length(obj.x)
                addpoints(h,obj.x(k),obj.y(k));
                b = toc(a);
                if b > 0.001
                    drawnow
                    a = tic;
                end
            end
        end
        
        function get_polar(obj)
            % sets the polar cordinates for the trial. Saved in the theta
            % and rho properties 
          [obj.theta, obj.rho] = cart2pol(obj.x, obj.y);
        end
        
        function number_of_fixation(obj)
            % sets the number of fixations for the trial
            [row,col,~] = find(obj.data.fixation_times ==1 );
            [~,m]  = unique(row,'first')
            obj.num_fixations = length(obj.data.fixation_start.(obj.trial_fieldname));
        end
        function number_of_saccade(obj)           
            % sets the number of saccades for the trial
            obj.num_saccades = length(obj.parent.data.saccade_start.(obj.trial_fieldname));
        end
        function duration_of_fixation(obj)
            % sets the duration of fixation for the trial
            obj.fixation_duration = obj.parent.data.fixation_duration.(obj.trial_fieldname);
        end
        function duration_of_saccade(obj)
            % sets the duraiton of saccades for the trial 
            obj.saccade_duration = obj.parent.data.saccade_duration.(obj.trial_fieldname);
        end
        function location_of_fixation(obj)
             % sets the location of fixation for the trial 
            obj.fixation_location = [obj.parent.data.datfile(obj.trial_no).Fixations.gavx ;obj.parent.data.datfile(obj.trial_no).Fixations.gavy];
        end
        function location_of_saccade(obj)
            % sets the location of saccades points  for the trial 
            obj.saccade_location = [obj.parent.data.datfile(obj.trial_no).Saccades.gstx; obj.parent.data.datfile(obj.trial_no).Saccades.gsty;
                                    obj.parent.data.datfile(obj.trial_no).Saccades.genx; obj.parent.data.datfile(obj.trial_no).Saccades.geny];        
        end
        function amplitude_of_saccade(obj)
            % sets the amplitude of saccades for the trial 
            obj.saccade_amplitude =  (obj.parent.data.fixation_duration.(obj.trial_fieldname));       
        end
        function deviation_of_duration_of_fixation(obj)
             % sets the deviation of saccades  duration for the trial 
            if isempty(obj.fixation_duration)
                duration_of_fixation(obj)
            end
            obj.fixation_duration_variation = zscore(double(obj.fixation_duration));
                    
        end
        function get_issaccade(obj)
             % sets the issaccade vector.  Also creates saccade_starts,
             % num_samples and sample_times 
            obj.saccade_start = obj.parent.data.saccade_start.(obj.trial_fieldname);
            obj.issaccade = zeros(size(obj.sample_time));
            for i = 1:obj.num_saccadesr45554
                time_of_saccade = [obj.saccade_start(i), obj.saccade_start(i) + obj.saccade_duration(i)];
                idx = obj.sample_time >= time_of_saccade(1) & obj.sample_time <= time_of_saccade(2);
                if isempty(find(idx,1))
                    idx = find(obj.sample_time >= time_of_saccade(1),1);
                end
                obj.issaccade(idx) = i ;
            end
        end
        function get_isfixation(obj)
             % sets the issaccade vector.  Also creates fixation_start,
             % num_samples and sample_times 
            obj.fixation_start = obj.parent.data.fixation_start.(obj.trial_fieldname);
            obj.num_samples  = length(obj.x);
            obj.isfixation = zeros(size(obj.sample_time));
            obj.num_fixations = length(obj.fixation_start);
            for i = 1:obj.num_fixations
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
                % Sets the deviation of duration for saccades for the
                % saccades
            if isempty(obj.saccade_duration)
                duration_of_saccade(obj)
            end
            obj.saccade_duration_variation = zscore(double(obj.saccade_duration));    
        
        end
        function regionsofinterest(obj)
                %doesn't do anything useful =] (yet)
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