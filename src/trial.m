classdef trial < handle
    % inherited from data. Sets, calculates and plots trial specific data
    properties
        parent % Reference to parent object
        data %Data_file , extracted from participant's ztrack
        trial_no % Number of Trial
        trial_fieldname % Fieldname of Trial in string format
        num_samples % Number of samples
        index % Actual index of trial data in the raw data
        sample_time % Time of each sample, used as index
        trial_time  % Time of each sample, onset at 0
        x % Sample X value of the eye movement
        y % Sample Y value of eye movements
        rho % Distance parameter of the sample Eye momvemnt in polar form
        theta % Angle parametger of the sample Eye movement in polar form
        issaccadeorfixation % Indicates whether each sample is a saccade(1) or fixation (-1) or neither (0)
        
        %Fixation features
        fixations = struct()
        %             fixation_start
        %             fixation_end
        %             num_fixations % number of fixations in trial
        %             fixation_location %location of fixation in cartesian formo
        %             fixation_duration_variation % variation in the duraiton of fixation
        %             isfixation % Array indicating whether each sample is part of a fixation
        
        isfixation  % Array indicatig whether each sample is part of a fixation
        
        %Saccade features
        saccades = struct()
        %             saccade_start
        %             saccade_end
        %             num_saccades % Number of saccades in trial
        %             saccade_location % Location of Saccades, includes starting points (saccade_location[1:2, :] and end points saccade_location[3:4,:]
        %             saccade_duration_variation %Variation in saccade durations
        
        issaccade   % Array indicatig whether each sample is oart of a saccade
        
        % ROIs
        rois = struct()

        %Conditions
        condition %Associated condition for the given trial
        
        
    end
    
    properties (Access = private)
        baseref;  %reference to base object
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
            obj.parent = participant;
            obj.index = start_time:end_time;
            
            trial_data = obj.parent.getdata(obj);
            obj.x = trial_data.gx(obj.index);
            obj.y = trial_data.gy(obj.index);
            obj.num_samples = length(obj.x);
            obj.sample_time = trial_data.StartTime + uint32(0:obj.num_samples - 1) * uint32(trial_data.sample_rate);
            obj.trial_time = (obj.sample_time(:) - obj.sample_time(1))';
            obj.rois.single = [];
            obj.rois.combined = [];
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
        
        function set_trial_features(obj,varargin)
            obj.number_of_fixation
            obj.number_of_saccade
            obj.duration_of_fixation
            obj.duration_of_saccade
            obj.location_of_fixation
            obj.location_of_saccade
            obj.amplitude_of_saccade
            obj.deviation_of_duration_of_fixation
            obj.deviation_of_duration_of_saccade
            obj.get_polar
            obj.get_issaccade
            obj.get_isfixation
        end
        % ====== Feature detection methods =======
        %% Fixation methods
        function number_of_fixation(obj)
            % sets the number of fixations for the trial
            trial_data = obj.parent.getdata(obj);
            intrial_index = find(ismember(trial_data.Fixations.sttime,obj.index));
            obj.fixations.rawindex = intrial_index;
            obj.fixations.number = length(intrial_index);
            [~,col,~] =  find(obj.index == trial_data.Fixations.sttime(intrial_index));
            obj.fixations.start = obj.trial_time(col);
            [~,col,~] =  find(obj.index == trial_data.Fixations.entime(intrial_index));
            obj.fixations.end = obj.trial_time(col);
        end   
        
        function duration_of_fixation(obj)
            if length(obj.fixations.end) < length(obj.fixations.start)
                obj.fixations.end = [obj.fixations.end , obj.trial_time(end)];
            end
            obj.fixations.duration = obj.fixations.end - obj.fixations.start ;
        end
        
        function deviation_of_duration_of_fixation(obj)
            % sets the deviation of saccades  duration for the trial
            if isfield(obj.fixations, 'duration')
                duration_of_fixation(obj)
            end
            obj.fixations.duration_variation = util.zscore(obj.fixations.duration);           
        end
        
        function location_of_fixation(obj)
            % sets the location of fixation for the trial
            trial_data = obj.parent.getdata(obj);
            obj.fixations.average_gazex = trial_data.Fixations.gavx(obj.fixations.rawindex);
            obj.fixations.average_gazey = trial_data.Fixations.gavy(obj.fixations.rawindex);
        end
        
       function get_isfixation(obj)
            % sets the issaccade vector.  Also creates fixation_start,
            % num_samples and sample_times
            obj.isfixation = zeros(1,obj.num_samples);
            [~,col,~ ] = find(obj.fixations.start' <= obj.trial_time & obj.trial_time <= obj.fixations.end');
            obj.isfixation(col) = 1;
        end
        
        %% Saccade methods
        function number_of_saccade(obj)
            % sets the number of saccades for the trial
            trial_data = obj.parent.getdata(obj);
            intrial_index = find(ismember(trial_data.Saccades.sttime,obj.index));
            obj.saccades.rawindex = intrial_index;
            obj.saccades.number = length(intrial_index);
            [~,col,~] =  find(obj.index == trial_data.Saccades.sttime(intrial_index));
            obj.saccades.start = obj.trial_time(col);
            [~,col,~] =  find(obj.index == trial_data.Saccades.entime(intrial_index));
            obj.saccades.end = obj.trial_time(col);
        end
        
        function duration_of_saccade(obj)
            % sets the duraiton of saccades for the trial
            if length(obj.saccades.end) < length(obj.saccades.start)
                obj.saccades.end = [obj.saccades.end , obj.trial_time(end)];
            end
            obj.saccades.duration = obj.fixations.end - obj.fixations.start ;
        end
        
        function deviation_of_duration_of_saccade(obj)
            % Sets the deviation of duration for saccades for the
            % saccades
            if isfield(obj.saccades, 'duration')
                duration_of_saccade(obj)
            end
            
            obj.saccades.duration_variation = util.zscore(double(obj.saccades.duration));
        end
        
        function location_of_saccade(obj)
            % sets the location of saccades points  for the trial
            trial_data = obj.parent.getdata(obj);
            obj.saccades.start_gazex = trial_data.Saccades.gstx(obj.saccades.rawindex);
            obj.saccades.start_gazey = trial_data.Saccades.gsty(obj.saccades.rawindex);
            obj.saccades.end_gazex = trial_data.Saccades.genx(obj.saccades.rawindex);
            obj.saccades.end_gazey = trial_data.Saccades.geny(obj.saccades.rawindex);
        end
            
        function amplitude_of_saccade(obj)
            % sets the amplitude of saccades for the trial
            trial_data = obj.parent.getdata(obj);
            obj.saccades.amplitude =  trial_data.Saccades.ampl(obj.saccades.rawindex);
        end
        
        function get_issaccade(obj)
            % sets the issaccade vector.
            obj.issaccade = zeros(1,obj.num_samples);
            [~,col,~ ] = find(obj.saccades.start' <= obj.trial_time & obj.trial_time <= obj.saccades.end');
            obj.issaccade(col) = 1;
        end
        
        %% ROI features 
        
        function obj=makeROIs(obj,pos,varargin)
            
            p = inputParser;
            p.addParameter('radius',50,@isnumeric);
            p.addParameter('shape','circle',@(x) ismember(x,{'circle','circular','ellipse','elliptical','square','rectangle','userDefined'})); %zhongxu add 'userDefined'
            p.addParameter('xradius',50,@isnumeric);
            p.addParameter('yradius',10,@isnumeric);
            p.addParameter('angle',0,@(x) min(x)>=0 && max(x)<= 360);
            p.addParameter('clear',0);
            p.addParameter('userDefinedMask',{},@iscell);
            p.addParameter('names',{},@iscell);
            parse(p,varargin{:});
            
            if p.Results.clear==1
                obj.rois.single = [];
                obj.rois.combined = [];
                num_existingrois = 0;
            else
                num_existingrois = length(obj.rois.single);
            end
            
            if isempty(p.Results.names)
                number_of_rois = num_existingrois+1:num_existingrois+size(pos,1);
                names = num2str(number_of_rois(:));
            else
                number_of_rois = size(pos,1);
                names = p.Results.names;
            end
            
            for roi_number = 1:length(number_of_rois)
                %% For all Roi
                obj.rois.single(roi_number).name = names{roi_number};
                obj.rois.single(roi_number).coords = pos(roi_number,:);
                
                switch p.Results.shape
                    case 'userDefined'                       
                        obj.rois.single(roi_number).shape = 'userdefined';
                        obj.rois.single(roi_number).mask = p.Results.userDefinedMask{roi_number};
                        
                    otherwise
                        
                        obj.rois.single(roi_number).shape = p.Reults.shape(roi_number);
                        obj.rois.single(roi_number).radius = p.Results.radius(roi_number);
                        obj.rois.single(roi_number).xradius = p.Results.xradius(roi_number);
                        obj.rois.single(roi_number).yradius = p.Results.yradius(roi_number);
                        
                        xcenter = floor(obj.parent.screen.dims(1)/2);
                        ycenter = floor(obj.parent.screen.dims(2)/2);
                        
                        
                        [XX, YY] = meshgrid(0:(obj.parent.screen.dims(1)-1),...
                            0:(obj.parent.screen.dims(2)-1));
                        
                        
                        switch p.Results.shape
                            case {'circle','circular'}
                                obj.rois.single(roi_number).mask = sqrt(XX-pos(roi_number,1).^2+(YY-pos(roi_number,2).^2))...
                                                        <=p.Results.radius;
                                
                            case {'ellipse','elliptical'}
                                xshift = xpos - xcenter;
                                yshift = ypos - ycenter;
                                
                                %create an ellipse in the center, then rotate
                                el=((XX-xcenter)/p.Results.xradius).^2+((YY-ycenter)/p.Results.yradius).^2<=1;
                                el=imrotate(el,angles(roi_number),'nearest','crop');
                                
                                %then shift the image so it's centered over the
                                %correct point
                                RA = imref2d(size(el)); %so we keep the same image size
                                tform = affine2d([1 0 0; 0 1 0; xshift yshift 1]);
                                obj.rois.single(roi_number).mask = imwarp(el, tform,'OutputView',RA);
                                
                            case {'square','rectangle'}   % this needs to be checked :)
                                obj.rois.single(roi_number).mask = abs(XX-xpos)<=p.Results.xradius & abs(YY-ypos)<=p.Results.yradius;
                        end
                        
                        
                end
                
            end
        end
            
        function obj=combineROIs(obj,RoiIndex)
            % zhongxu add: specifiy which ROIs need to be combined, not  just combined all
            % TODO: these line of codes are ugly, need to be simplified.
            if nargin ==1
                numrois = length(obj.rois.single);
                RoiIndex=1:numrois;
            else
                numrois = length(RoiIndex);
                
                if iscell(RoiIndex)
                    if ischar(RoiIndex{1})
                        roitotal = length(obj.rois.single);
                        for i = 1:roitotal
                            for j = 1:numrois
                                if strcmp(obj.rois.single(i).name,RoiIndex{j})
                                    tempind(j)= i;
                                end
                            end
                        end
                        RoiIndex = tempind;
                    else
                        RoiIndex = cell2mat(RoiIndex);
                    end
                end
            end
            
            combined = zeros(size(obj.rois.single(1).mask));
            
            for r = 1:numrois
                
                combined = combined + obj.rois.single(RoiIndex(r)).mask;
                
            end
            
            obj.rois.combined = combined;
            
        end
        
       function obj = calcHits(obj,varargin)
            %wrapper for calcEyehits_ to make it easier to repeat for
            %fixations and saccades.
            p = inputParser;
            p.addParameter('rois','all',@(x) iscell(x) || ischar(x));
            parse(p,varargin{:});
            
            obj = calcEyehits_(obj,'rois',p.Results.rois,'type','fixations');
            obj = calcEyehits_(obj,'rois',p.Results.rois,'type','saccade_start');
            obj = calcEyehits_(obj,'rois',p.Results.rois,'type','saccade_end');
            
       end
        
        function obj= calcEyehits_(obj,varargin)
            %internal function for calculating whether fixations/saccades
            %hit a given roi or not.
            p = inputParser;
            p.addParameter('rois','all',@(x) iscell(x) || ischar(x));
            p.addParameter('type','fixations',@ischar);
            parse(p,varargin{:});
                        
            if ~iscell(p.Results.rois) && strcmp(p.Results.rois,'all')
                rois = {obj.rois.single.name};
            elseif ~iscell(p.Results.rois)
                rois = {p.Results.rois};
            else
                rois = p.Results.rois;
            end
            
            numROIs = length(rois);
            
            for r=1:numROIs

                xres = obj.parent.screen.dims(1);
                yres = obj.parent.screen.dims(2);

                roi_idx = find(ismember({obj.rois.single.name},rois{r}));

                roi_mask = obj.rois.single(roi_idx).mask;

                %matrix of all coordinates
                
                if strcmpi(p.Results.type,'fixations')
                    coords = [obj.fixations.average_gazex,obj.fixations.average_gazey];
                elseif strcmpi(p.Results.type,'saccade_start')
                    coords = [obj.saccades.start_gazex,obj.saccades.start_gazey];                  
                elseif strcmpi(p.Results.type,'saccade_end')
                     coords = [obj.saccades.end_gazex,obj.saccades.end_gazey];                                      
                end
                
                coords = ceil(coords);
                idx = sub2ind([yres,xres],coords(:,2),coords(:,1));
                overlap = ismember(idx, find(roi_mask));
                
                if strcmpi(p.Results.type,'fixations')
                   obj.fixations.hits = overlap';     
                elseif strcmpi(p.Results.type,'saccade_start')
                   obj.saccades.start_hits = overlap';     
                elseif strcmpi(p.Results.type,'saccade_end')
                   obj.saccades.end_hits = overlap';     
                end
                
            end
        end
% 
%         function regionsofinterest(obj)
%             %doesn't do anything useful =] (yet)
%             if isempty(obj.fixation_location)
%                 location_of_fixation(obj)
%             end
%             figure
%             hold on
%             a = [obj.fixation_location' , kmeans(obj.fixation_location',10)];
%             for i=1:10
%                 scatter(a(a(:,3) == i,1), a(a(:,3) == i,2))
%             end
%         end
        
        function set_grid(obj, gridsize)
            %size could either be a vectory or a value for square sized 
            xres = obj.parent.screen.dims(1);
            yres = obj.parent.screen.dims(2);
            if strcmpi(gridsize, 'default')  
                division_factor = gcd(xres,yres);
                gridsize = sqrt(gcd(xres,yres)); % better way to calculate the default size? eg, gcf of  xres yres
            end
           
           total_grids = xres/ gridsize;
           all_grids = cell(1,total_grids);
           mygrid = zeros(yres,xres);
           
           xbreaks = [1:gridsize:yres, yres];
           ybreaks = [1:gridsize:xres, xres];
           
           for grid_num = 1:total_grids
               for i = 1:length(xbreaks)-1
                   for j = 1:length(ybreaks)-1
                       mygrid(xbreaks(i):xbreaks(i+1),ybreaks(j):ybreaks(j+1))  = i;

                   end
               end
               all_grids(grid_num) = {mygrid}; 
               mygrid = zeros(yres,xres);
           end
           makeROIs(obj,size(mygrid),'shape','userDefined','userDefinedMask',  all_grids, 'names', {strcat('grid_', num2str(gridsize))})
        end
        
        function recurrence(obj, varargin)
            obj.calcHits('rois', 'grid16')
        
            
        end
      end
      

        
        
end
