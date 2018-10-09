%{
To Do list : 
0) ADD A GET SET TRIAL TO PARTICIPANT
1) Decide on what the outputs should look like
1) Make all saccade variables the same dimensions
4) remove hits when removing roi
5) need more setters 
6) remove index from csv_output
7) remove util, use class functions 
%} 
classdef trial < handle
    % inherited from data. Sets, calculates and plots trial specific data
    properties
        parent % Reference to parent object
        start_time %Trial indexed start time of the all data in this trial obj 
        end_time % Trial indexed end time of the all data in this trial obj 
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
        angular_velocity % angular_speed in rad / s
        angular_acceleration % angular_accelration in rad /s^2
        angle_change % change in anglular values in rad
        %Fixation features
        fixations = struct()
        %             fixation_start
        %             fixation_end
        %             num_fixations % number of fixations in trial
        %             fixation_location %location of fixation in cartesian formo
        %             fixation_duration_variation % variation in the duraiton of fixation
        %             isfixation % Array indicating whether each sample is part of a fixation
        
        
        %Saccade features
        saccades = struct()
        %             saccade_start
        %             saccade_end
        %             num_saccades % Number of saccades in trial
        %             saccade_location % Location of Saccades, includes starting points (saccade_location[1:2, :] and end points saccade_location[3:4,:]
        %             saccade_duration_variation %Variation in saccade durations
                
        % ROIs
        rois = struct()

        %Conditions
        condition %Associated condition for the given trial
    end
    properties (Access = private)
        status
    end
   
    methods
        %% Constrcutor  
        function obj = trial(parent, trial_no, varargin)
            % Given a parent participant, the data and a trial number with
            % optional arguments for start and end time of relevant data
            % creates a trial object. Also sets the x and y parameter
            p = inputParser;
            p.addRequired('parent', @(parent) isa(parent, 'participant'))
            p.addRequired('trial_no',  @(x) isvector(x));
            p.addOptional('temporal_roi', [' ';' '] , @checktemporal)
            p.addOptional('from_fixation', 0)
            p.parse(parent, trial_no, varargin{:})            
            start_event = p.Results.temporal_roi(1);
            end_event = p.Results.temporal_roi(2);       
            % main properties  
            obj.trial_fieldname = ['trial_' int2str(trial_no)];
            obj.trial_no = trial_no;
            obj.parent = parent;
            obj.status = 0;
            % fixation_case
            if p.Results.from_fixation == 1
                obj = obj.trial_fromfixation();                
            else
                % data properties
                trial_data = obj.get_itrack;  
                % setting Temporal ROI's if specified
                [obj.start_time, obj.end_time ,full_trial_time] = ...
                        obj.get_timeindex(start_event, end_event);            
                obj.index = find(full_trial_time >= obj.start_time,1):find(full_trial_time >= obj.end_time,1);   

                if isfield(obj.parent.screen,'dims')
                    trial_data.gx(trial_data.gx > obj.parent.screen.dims(1)) = nan;
                    trial_data.gy(trial_data.gy > obj.parent.screen.dims(2)) = nan;
                    trial_data.gx(trial_data.gx < 0 ) = nan;
                    trial_data.gy(trial_data.gy < 0 ) = nan;
                end

                obj.x = trial_data.gx(obj.index);
                obj.y = trial_data.gy(obj.index);
                obj.num_samples = length(obj.x);
                obj.sample_time = full_trial_time(obj.index);
                obj.trial_time = obj.sample_time - obj.sample_time(1);
            end
            obj.rois.single = [];
            obj.rois.combined = [];
        end 
        function obj = trial_fromfixation(obj)
            trial_column = 9; %% generalize  later
            fixation_x = 11; %% generalize  later
            fixation_y = 12;  %% generalize  later
            duration_column = 10; %% generalize  later
            image_name_column = 3; %% generalize  later
            trial_data = obj.parent.RAW(cell2mat(obj.parent.RAW(:,9)) == obj.trial_no,:);
            obj.fixations.raw = trial_data;
            obj.fixations.number = length(trial_data);
            obj.fixations.average_gazex = trial_data(:,fixation_x);
            obj.fixations.average_gazey = trial_data(:,fixation_y);
            obj.fixations.durtion = trial_data(:,duration_column);
            obj.fixations.image_name = trial_data(:,image_name_column);
        end
        %% Helper funcions
        function get_polar(obj)
            % sets the polar cordinates for the trial. Saved in the theta
            % and rho properties
            [obj.theta, obj.rho] = cart2pol(obj.x, obj.y);
        end        
        function time = get_time(obj,varargin)
            % assumes edf time values are ms 
            % returns trial indexed time values 
            try 
                idx = varargin{2};
            catch 
                idx = 1:obj.num_samples;
            end
            
            if nargin == 1
                time  = double(obj.trial_time(idx)); 
            else
                switch(varargin{1})
                    case 'ms'
                        time = double(obj.trial_time(idx));
                    case 's'
                        time = double(obj.trial_time(idx)) / 1000;                 
                    otherwise
                        disp('time_unit identifier not found, or left blank, default units used')
                        time = double(obj.trial_time(idx));  
                end
            end
        end
        function data = get_itrack(obj)
            data = obj.parent.data{1,1}(obj.trial_no);
        end
        function time = extract_event(obj,event)
              % Todo: deal with name inherit, call to super? different name?
              searchfor = regexprep(event,'[!@#$%^&()?"*+='',./~` ]','');
              idx = ~cellfun(@isempty,regexp(obj.get_itrack.events.message,event));
              time = obj.get_itrack.events.time(idx);
        end
        function [first, last, full_trial_time]  = get_timeindex(obj,firstinput,lastinput)
             trial_data = obj.get_itrack;
         
             full_trial_time = 1000*(0:trial_data.numsamples-1) * 1/trial_data.sample_rate;
             
              if mod(trial_data.StartTime,2) %if the trial time data are odd sampels
                 full_trial_time = full_trial_time+1;
              end
       
             % Todo:  handle durations
             switch class(firstinput)         
                case 'char' %empty
                    first = full_trial_time(1);
                case 'string'
                    first = obj.extract_event(firstinput);
                case 'numeric'
                    first = firstinput;
                 otherwise
                     error ( 'Input must be a string or a number')
             end           
            switch class(lastinput)       
                case 'char' %empty
                    last = full_trial_time(end);
                case 'string'
                    last = double(obj.extract_event(lastinput));
                case 'numeric'
                    last = lastinput;
                otherwise
                    error ( 'Input must be a string or a number')
            end           
        end
        %% Setters
        function set_base(obj)
            if obj.status < 20 
                obj.fixation_base
                obj.saccade_base
            end
        end
        function set_extended(obj)
            obj.fixation_extended
            obj.saccade_extended
        end
        %% Fixation methods 
        function fixation_base(obj)
            obj.number_of_fixation()
            if obj.fixations.number > 0 
                obj.duration_of_fixation()
                obj.avarage_fixation_duration()
                obj.max_fixation_duration()
                obj.min_fixation_duration()
                obj.location_of_fixation()
            end
            obj.status = obj.status + 10;
        end
        function fixation_extended(obj)
            obj.fixation_base()
            if obj.fixations.number > 0
                obj.deviation_of_duration_of_fixation()           
            end
        end
        %base 
        function number_of_fixation(obj)
            % sets the number of fixations for the trial
            trial_data = get_itrack(obj);
            minimum_duration = 100;
            intrial_index = find(ismember(trial_data.Fixations.entime,obj.sample_time));
            col = [];
            if ~isempty(intrial_index)
                if trial_data.Fixations.entime(intrial_index(1)) - obj.start_time  <  minimum_duration
                    intrial_index = intrial_index(2:end);
                end
            end
            
            if ~isempty(intrial_index) % our indices might be reduced to non after the previous step
                obj.fixations.rawindex = intrial_index;
                obj.fixations.number = length(intrial_index);
                [~,col,~] =  find(obj.sample_time == trial_data.Fixations.sttime(intrial_index));
                
                obj.fixations.start = obj.trial_time(col);
                [~,col,~] =  find(obj.sample_time == trial_data.Fixations.entime(intrial_index));
                obj.fixations.end = obj.trial_time(col);
                if length(obj.fixations.start) < length(obj.fixations.end)
                    obj.fixations.start = [0 ,  obj.fixations.start];
                end     
                fixation_cordinates = util.inbetween(obj.trial_time, obj.fixations.start, obj.fixations.end);
                for i = 1:length(intrial_index)
                    obj.fixations.cordinates{i,1} = obj.x(find(fixation_cordinates(i,:)));
                    obj.fixations.cordinates{i,2} = obj.y(find(fixation_cordinates(i,:)));
                end
                
            else
                obj.fixations.number = 0;
            end  
        end
        function duration_of_fixation(obj)
            obj.fixations.duration = obj.fixations.end - obj.fixations.start ;
        end   
        function avarage_fixation_duration(obj)
           %sets the average duration of all fixations
           obj.fixations.average_duration = mean(obj.fixations.duration);
        end
        function max_fixation_duration(obj)
           %sets the max duration of all fixations
           [obj.fixations.max_duration, obj.fixations.max_duration_index] = max(obj.fixations.duration);
        end
        function min_fixation_duration(obj)
            %sets the min duration of all fixations
            [obj.fixations.min_duration, obj.fixations.min_duration_index] = min(obj.fixations.duration);
        end
        function location_of_fixation(obj)
            % sets the location of fixation for the trial
            trial_data = get_itrack(obj);
            obj.fixations.average_gazex = trial_data.Fixations.gavx(obj.fixations.rawindex);
            obj.fixations.average_gazey = trial_data.Fixations.gavy(obj.fixations.rawindex);
        end
        %extended
        function deviation_of_duration_of_fixation(obj)
            % sets the deviation of saccades  duration for the trial
            if ~isfield(obj.fixations, 'duration')
                duration_of_fixation(obj)
            end
            obj.fixations.duration_standard_deviation = std(double(obj.fixations.duration));
            obj.fixations.duration_zscore = util.zscore(obj.fixations.duration);           
        end
        %functional
        function get_isfixation(obj)
            % sets the issaccade vector.  Also creates fixation_start,
            % num_samples and sample_times
            obj.fixations.isfixation = zeros(1,obj.num_samples);
            [~,col,~ ] = find(obj.fixations.start' <= obj.trial_time & obj.trial_time <= obj.fixations.end');
            obj.fixations.isfixation(col) = 1;
        end       
        %% Saccade methods
        function saccade_base(obj)
            obj.number_of_saccade
            obj.duration_of_saccade
            obj.amplitude_of_saccade
            obj.deviation_of_amplitude_of_saccade
            obj.average_saccade_amplitude
            obj.status = obj.status + 10;
        end
        function saccade_extended(obj)
            obj.saccade_base
            if obj.saccades.number > 0
                obj.deviation_of_duration_of_saccade
            end
        end
        %base
        function number_of_saccade(obj)
            % sets the number of saccades for the trial
            minimum_duration = 100;
            trial_data = get_itrack(obj);
            intrial_index = find(ismember(double(trial_data.Saccades.entime),obj.sample_time));
            if ~isempty(intrial_index)
                if trial_data.Saccades.entime(intrial_index(1)) - obj.start_time  <  minimum_duration
                    intrial_index = intrial_index(2:end);
                end         
            end
            if ~isempty(intrial_index) % our indices might be reduced to non after the previous step
                [~,col,~] =  find(obj.sample_time == trial_data.Saccades.sttime(intrial_index));
                obj.saccades.start = obj.trial_time(col);
                [~,col,~] =  find(obj.sample_time == trial_data.Saccades.entime(intrial_index));
                obj.saccades.end = obj.trial_time(col);
                
                if (length(obj.saccades.start) < length(obj.saccades.end))
                    obj.saccades.start = [obj.trial_time(1) , obj.saccades.start];
                end

                saccade_cordinates = util.inbetween(obj.sample_time, obj.saccades.start, obj.saccades.end);
                
                for i = 1:length(intrial_index)
                    obj.saccades.cordinates{i,1} = obj.x(find(saccade_cordinates(i,:)));
                    obj.saccades.cordinates{i,2} = obj.y(find(saccade_cordinates(i,:)));
                end
            else
                obj.saccades.start = NaN;
                obj.saccades.end = NaN;
            end
            
            obj.saccades.rawindex = intrial_index;
            obj.saccades.number = length(intrial_index);


        end       
        function duration_of_saccade(obj)
            % sets the duraiton of saccades for the trial
            if obj.saccades.number == 0
                obj.saccades.duration = NaN;
            else
                obj.saccades.duration = obj.saccades.end - obj.saccades.start ;
            end
        end   
        function amplitude_of_saccade(obj)
            % sets the amplitude of saccades for the trial
            trial_data = get_itrack(obj);
            obj.saccades.amplitude =  trial_data.Saccades.ampl(obj.saccades.rawindex);
        end
        function deviation_of_amplitude_of_saccade(obj)
            obj.saccades.amplitude_standard_deviation = std(double(obj.saccades.amplitude));
            obj.saccades.amplitude_variation = util.zscore(double(obj.saccades.amplitude));
        end
        function average_saccade_amplitude(obj)
            % sets the avereage amplitude of saccadess
            obj.saccades.average_amplitude =  mean(obj.saccades.amplitude);
        end
        function location_of_saccade(obj)
            % sets the location of saccades points  for the trial
            trial_data = get_itrack(obj);
            obj.saccades.start_gazex = trial_data.Saccades.gstx(obj.saccades.rawindex);
            obj.saccades.start_gazey = trial_data.Saccades.gsty(obj.saccades.rawindex);
            obj.saccades.end_gazex = trial_data.Saccades.genx(obj.saccades.rawindex);
            obj.saccades.end_gazey = trial_data.Saccades.geny(obj.saccades.rawindex);
        end
        %extended 
        function deviation_of_duration_of_saccade(obj)
            % Sets the deviation of duration for saccades for the
            % saccades
            if isfield(obj.saccades, 'duration')
                duration_of_saccade(obj)
            end
            obj.saccades.duration_standard_deviation = std(double(obj.saccades.duration));
            obj.saccades.duration_variation = util.zscore(double(obj.saccades.duration));
        end    
        %functional 
        function get_issaccade(obj)
            % sets the issaccade vector.
            obj.saccades.issaccade = zeros(1,obj.num_samples);
            [~,col,~ ] = find(obj.saccades.start' <= obj.trial_time & obj.trial_time <= obj.saccades.end');
            obj.saccades.issaccade(col) = 1;
        end 
        %% ROI methods        
        function makeROIs(obj,pos,varargin)            
            p = inputParser;
            p.addParameter('radius',50,@isnumeric);
            p.addParameter('shape','circle',@(x) ismember(x,{'circle','circular','ellipse','elliptical','square','rectangle','userDefined','file'})); %zhongxu add 'userDefined'
            p.addParameter('xradius',50,@isnumeric);
            p.addParameter('yradius',10,@isnumeric);
            p.addParameter('angle',0,@(x) min(x)>=0 && max(x)<= 360);
            p.addParameter('clear',0);
            p.addParameter('userDefinedMask',{},@iscell);
            p.addParameter('fromfile','', @(x) exist(x,'file'))
            p.addParameter('names',{},@iscell);
            parse(p,varargin{:});
            
            if p.Results.clear==1 || ~isfield(obj.rois,'single')
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
            
            for roi_number = number_of_rois , roi_index = roi_number - num_existingrois; 
                %% For all Roi
                obj.rois.single(roi_number).name = names(roi_index);
                obj.rois.single(roi_number).coords = pos(roi_index,:);
                
                switch p.Results.shape
                    case 'userDefined'                       
                        obj.rois.single(roi_number).shape = 'userdefined';
                        obj.rois.single(roi_number).mask = p.Results.userDefinedMask{roi_index};
                    case 'file'
                        [XX, YY] = meshgrid(0:(obj.parent.screen.dims(1)-1),...
                            0:(obj.parent.screen.dims(2)-1));
                        roi_details = read_ias(p.Results.fromfile,roi_index+1,roi_index+1);
                        xpos = table2array(roi_details(:,[3,5]));
                        ypos = table2array(roi_details(:,[4,6]));
                        obj.rois.single(roi_number).mask  = ...
                            XX >= xpos(1) & XX <= xpos(2) &  ...
                            YY >= ypos(1) & YY <= ypos(2) ;
                        obj.rois.single(roi_number).shape = char(table2array(roi_details(:,1)));
                        obj.rois.single(roi_number).coords = [xpos; ypos];

                    otherwise                        
                        obj.rois.single(roi_number).shape = p.Results.shape(roi_index);
                        obj.rois.single(roi_number).radius = p.Results.radius(roi_index);
                        obj.rois.single(roi_number).xradius = p.Results.xradius(roi_index);
                        obj.rois.single(roi_number).yradius = p.Results.yradius(roi_index);
                        
                        xcenter = floor(obj.parent.screen.dims(1)/2);
                        ycenter = floor(obj.parent.screen.dims(2)/2);
                        
                        
                        [XX, YY] = meshgrid(0:(obj.parent.screen.dims(1)-1),...
                            0:(obj.parent.screen.dims(2)-1));
                        
                        
                        switch p.Results.shape
                            case {'circle','circular'}
                                obj.rois.single(roi_number).mask = sqrt(XX-pos(roi_index,1).^2+(YY-pos(roi_index,2).^2))...
                                                        <=p.Results.radius;
                                
                            case {'ellipse','elliptical'}
                                xshift = xpos - xcenter;
                                yshift = ypos - ycenter;
                                
                                %create an ellipse in the center, then rotate
                                el=((XX-xcenter)/p.Results.xradius).^2+((YY-ycenter)/p.Results.yradius).^2<=1;
                                el=imrotate(el,angles(roi_index),'nearest','crop');
                                
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
        function combineROIs(obj,RoiIndex)
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
        function calcHits(obj,varargin)
            %wrapper for calcEyehits_ to make it easier to repeat for
            %fixations and saccades.
            p = inputParser;
            p.addParameter('rois','all',@(x) iscell(x) || ischar(x));
            parse(p,varargin{:});
            
            obj = calcEyehits_(obj,'rois',p.Results.rois,'type','fixations');
            obj = calcEyehits_(obj,'rois',p.Results.rois,'type','saccade_start');
            obj = calcEyehits_(obj,'rois',p.Results.rois,'type','saccade_end');
            
       end      
        function calcEyehits_(obj,varargin)
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
                roi_idx = arrayfun(@(s) s.name == rois{r}, obj.rois.single);
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
                overlap = roi_mask(idx);            
                if strcmpi(p.Results.type,'fixations')
                    obj.rois.single(r).hits = overlap';
                    if ~isfield(obj.fixations,'hits')
                        obj.fixations.hits = cell(obj.fixations.number,1);
                    end
                    for i = 1:obj.fixations.number
                         if overlap(i) == 1
                            obj.fixations.hits{i} = [obj.fixations.hits{i}, obj.rois.single(r).name];      
                         end
                    end
                elseif strcmpi(p.Results.type,'saccade_start')
                    obj.rois.single(r).hits = overlap';
                    if ~isfield(obj.saccades,'starthits')
                        obj.saccades.starthits = [];
                    end
                    obj.saccades.starthits = [obj.saccades.starthits; obj.rois.single(r).name];
                    
                elseif strcmpi(p.Results.type,'saccade_end')
                    obj.rois.single(r).hits = overlap';
                    if ~isfield(obj.saccades,'endhits')
                        obj.saccades.endhits = [];
                    end
                    obj.saccades.endhits = [obj.saccades.endhits; obj.rois.single(r).name];
                end                
            end
        end  
        function set_grid(obj, gridsize)
            %size could either be a vectory or a value for square sized 
            xres = obj.parent.screen.dims(1);
            yres = obj.parent.screen.dims(2);
            if strcmpi(gridsize, 'default')  
                division_factor = gcd(xres,yres);
                gridsize = sqrt(gcd(xres,yres)); % better way to calculate the default size? eg, gcf of  xres yres
            end
           
           total_grids = floor(xres/ gridsize);
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
        %% Extended methods
        function set_eyelink_saccade(obj, thereshold)
            %% detects saccades based on existing  defenition 
            obj.saccades.eye_link = struct();
            % intializing the eyelink theresholds
            if ~isstruct(thereshold)
                thereshold = struct();
                thereshold.acceleration = 8000; % deg/s 
                thereshold.velocity = 30; % deg / s^2
                thereshold.degree = 0.5; % deg
                thereshold.saccade_duration = 10; %ms
            end
            %% TODO : add a check for thereshold.saccade_duration > 1/frqunecy
            % setting saccades
            
            [obj.angular_acceleration, obj.angular_velocity] = util.Speed_Deg(obj.x,obj.y, 700.0 , 250.0, 340.0 ,944.0,1285.0, 500);
            saccade_index = double(obj.angular_velocity > thereshold.velocity & obj.angular_acceleration > thereshold.acceleration);
            saccade_index = mark_endingpoints(obj.get_time,saccade_index,thereshold.saccade_duration); %maybe use a diff thereshold here?
            saccade_detector = find(saccade_index);
            starttime = [0, obj.get_time('ms',saccade_detector)]; %#ok<FNDSB>
            tmp = find(diff(starttime) > thereshold.saccade_duration)+1;
            obj.saccades.eye_link.start_time  = starttime(tmp);
            tmp = tmp(2:end); % trial cant start with a saccade ending 
            obj.saccades.eye_link.end_time  = starttime(tmp(1:end)-1);
            obj.saccades.eye_link.end_time = obj.saccades.eye_link.end_time + thereshold.saccade_duration; 
            if length(obj.saccades.eye_link.end_time) < length(obj.saccades.eye_link.start_time)
                obj.saccades.eye_link.end_time = [obj.saccades.eye_link.end_time, obj.saccades.eye_link.start_time(end)+ thereshold.saccade_duration];
            end
            obj.saccades.eye_link.num_saccades = length(tmp);
            obj.saccades.eye_link.marked_saccade = mark_fixations(obj.get_time,obj.saccades.eye_link.start_time,obj.saccades.eye_link.end_time);
            
            
            % setting fixations
            state_changes =  obj.get_time('ms',find(diff(obj.saccades.eye_link.marked_saccade == 0))); %#ok<FNDSB> 
            defined_states = saccade_index(~isnan(saccade_index));
            initial_state = defined_states(1);          
            if  initial_state == 0 %start with fixation
                fixation_starts = 1:2:length(state_changes);
            elseif initial_state == 1 % starts with saccade
               fixation_starts = 2:2:length(state_changes);
            end
            obj.fixations.eye_link.start_time = state_changes(fixation_starts);
            obj.fixations.eye_link.end_time = setdiff(state_changes, obj.fixations.eye_link.start_time);
            obj.fixations.eye_link.num_fixations = length( obj.fixations.eye_link.start_time);
            
            obj.saccades.eye_link.defenition = thereshold;              
         end
        function recurrence(obj, varargin)
            %% Fixed Grid method
            obj.calcHits('rois', {'grid_50'})
            grid_hits = obj.rois.single(1).hits;
            recurrance_scatter = zeros(length(grid_hits),length(grid_hits));
            for  i = 1:length(grid_hits)
                   hits = find(grid_hits == grid_hits(i));
                   recurrance_scatter(i, hits) = 1; %#ok<FNDSB>
            end
            
            
           %  spy(recurrance_scatter);
             
%             %% Fixation distance method
%             radius = 60; 
%             n = obj.fixations.number;
%             distance_matrix = fixation_distance(obj.fixations);
%             distance_matrix(find(distance_matrix <= radius)) = 1; %#ok<FNDSB>
%             distance_matrix(find(distance_matrix > radius)) = 0; %#ok<FNDSB>
%             spy(distance_matrix);            
%             R = (sum(sum(distance_matrix)) - b)/2;
%             Rec = 100  * (2 * R)/ (n * (n-1));
%             Determinism = 100 * abs(n)/R;
%             % better way of doing it : numel(find(distance_matrix))/ numel(distance_matrix)
        end         
        function entropy(obj, rois)        
            obj.calcEyehits_('rois', rois);           
            number_of_regions = length(rois);
            looked_regions = nan(1,number_of_regions);
            for fixation_index = 1:obj.fixations.number
                hit_regions = obj.fixations.hits{fixation_index};
                roi_idx = arrayfun(@(s) find(s == [rois{:}]), hit_regions, 'UniformOutput', false);
                if ~isempty(roi_idx) && ~isempty(roi_idx{1})
                   looked_regions(fixation_index) = roi_idx{:};   
                end
            end                      
                obj.entropy = get_ent(number_of_regions, looked_regions)
        end
        function fixationmap(obj)
            imageSize = [1920,1080]; %% HARDCODED FOR NOW
            obj.mark_badfixations(imageSize)
            obj.fixations.map =  zeros(imageSize); 
            obj.mark_badfixations(imageSize)
            for fix_num = 1:obj.fixations.number
                if ismember(fix_num,obj.fixations.outofbounds)
                   continue 
                else
                    x = obj.fixations.average_gazex{fix_num};
                    y = obj.fixations.average_gazey{fix_num};
                    d = obj.fixations.durtion{fix_num};   
                    x = ceil(x); 
                    y = ceil(y);
                    obj.fixations.map(y,x) = obj.fixations.map(x,y) + d;   
                end
            end         
            obj.fixations.map = obj.fixations.map / sum(obj.fixations.map(:));
        end
        %% Utility methods 
        function mark_badfixations(obj,imageSize)
             obj.fixations.outofbounds = [];
             x_lim = imageSize(1);
             y_lim = imageSize(2);
             for fix_num = 1:obj.fixations.number
                x = obj.fixations.average_gazex{fix_num}; %#ok<PROPLC>
                y = obj.fixations.average_gazey{fix_num};%#ok<PROPLC>
                
                if (x < 0 || x > x_lim) ||(y < 0 || y > y_lim) %#ok<PROPLC>  %% the 0 has to be changed later
                    obj.fixations.outofbounds = [obj.fixations.outofbounds, fix_num];
                end
             end   
        end
        %% Plotting methods
        function animate(obj)
            % Creates and draws an animation plot for the trial 
            h = animatedline('MaximumNumPoints',1,'color', 'r', 'marker','*');
            a = tic;
            xdim =  obj.parent.screen.dims(2);
            ydim = obj.parent.screen.dims(1);
            xlim ([0 xdim])
            ylim([0 ydim])
            for k = 1:length(obj.x)
                addpoints(h,obj.x(k),obj.y(k));
                b = toc(a);
                if b > 0.001
                    drawnow
                    a = tic;
                end
            end
        end
        function plot_angular_velocity(obj)
            figure
            hold on;
            obj.set_eyelink_saccade(1);
            plot(obj.trial_time,obj.x)
            plot(obj.trial_time,obj.y)
            plot(obj.trial_time,obj.angular_velocity,'linewidth',2)
            plot(obj.trial_time,obj.angular_acceleration/100)
            % should set some plot specifications here
            for saccade = obj.saccades.start
                plot([saccade saccade], [1 1000], 'r:','linewidth', 2)
            end
            line([0 obj.trial_time(end)],[30 30],'color','k')
            line([0 obj.trial_time(end)],[80 80],'color', 'k')
%             for saccade = obj.saccades.eye_link.start_time
%                plot([saccade saccade], [1 1000], 'b:','linewidth', 1)
%             end
            legend('x','y','velocty','acceleration/100')
            
        end
        function fixation_heat_map(obj)
            sample_rate = unique(diff(obj.trial_time));
            x_dim = obj.parent.screen.dims(1);
            y_dim = obj.parent.screen.dims(2);
            density = zeros(x_dim, y_dim);
            for fixation_number = 1:obj.fixations.number
                cord_x = floor(obj.fixations.cordinates{fixation_number,1});
                cord_y = floor(obj.fixations.cordinates{fixation_number,2});
                %cord_x = floor(obj.fixations.average_gazex(fixation_number));
                %cord_y = floor(obj.fixations.average_gazey(fixation_number));
                density(cord_x,cord_y ) = density(cord_x, cord_y) + sample_rate;
            end
            figure;
            heat_axes = axes();
            hold on
            h = fspecial('gaussian', 5, 5);
            HeatMap = imgaussfilt(density, 6, 'Padding', 'circular')';
            X = imagesc(HeatMap);
            colormap(heat_axes, 'jet');
            hold off          
            set(X, 'AlphaData', HeatMap ./ max(HeatMap(:)));
            LongestFixation = max(obj.fixations.duration);
            c = colorbar('Ticks',0:max(HeatMap(:))/4: max(HeatMap(:)),...
                'TickLabels',{round(0:LongestFixation/4:LongestFixation)},...
                'FontSize', 6);          
            c.Label.String = 'Fixation duration (ms)';
            c.Label.FontSize = 8;
        end
        function fixation_sequence_plot(obj)
            colorval = linspace(0,1,obj.fixations.number);
            for fixation_number = 1:obj.fixations.number-1
                line([obj.fixations.average_gazex(fixation_number),obj.fixations.average_gazex(fixation_number+1)],...
                    [obj.fixations.average_gazey(fixation_number),obj.fixations.average_gazey(fixation_number+1)], ...
                    'color',[0+colorval(fixation_number) 0 1-colorval(fixation_number)])
                hold on
            end            
        end
        function saccade_plot(obj)
            for saccade_index = 1:obj.saccades.number
                x = obj.saccades.cordinates{saccade_index,1};
                y = obj.saccades.cordinates{saccade_index,2};
                plot(x,y)
            end
            legend();
        end
        function roi_plot(obj,rois)
            if ~exist('rois')
                num_rois = length(obj.rois.single);
                rois = obj.rois.single;
            else
                num_rois  = length(rois);
            end
            for roi_index = 1:num_rois
                myroi = obj.rois.single(roi_index);
                switch myroi.shape
                    case 'RECTANGLE'
                        rectangle('Position', [myroi.coords(1), myroi.coords(2),myroi.coords(3),myroi.coords(4)])
                        hold on
                    otherwise
                        disp('hi')
                end
                hold off
            end
        end
     end
end      
%% HELPERS 
% FILE READERS
 function roi_table = read_ias(filename, startRow, endRow)
        % reads user_inputted ias masks
        % assumes  Format for each line of text:
        %   column1: categorical (%C)
        %	column2: double (%f)
        %   column3: double (%f)
        %	column4: double (%f)
        %   column5: double (%f)
        %	column6: double (%f)
        %   column7: text (%s)     
        delimiter = '\t';
        formatSpec = '%C%f%f%f%f%f%s%[^\n\r]';
        fileID = fopen(filename,'r');
        dataArray = textscan(fileID, formatSpec, endRow-startRow+1, 'Delimiter', delimiter, 'TextType', 'string', 'HeaderLines', startRow-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
        fclose(fileID);       
        roi_table = table(dataArray{1:end-1});
 end 
% MARKERS
 function samplemarker = mark_fixations(sample_time,saccade_start,saccade_end)
    samplemarker = zeros(length(sample_time),1);
    sample_index = 0;
    for sample = sample_time , sample_index = sample_index+1;
        if find(util.inbetween(sample, saccade_start, saccade_end)) 
            samplemarker(sample_index) = 1;
        end
    end
 
 end
 function samplemarker = mark_endingpoints(sample_time,samplemarker, thereshold)
    inital_state = samplemarker(1);
    state_change = find(samplemarker ~= inital_state, 1); 
    if sample_time(state_change) - sample_time(1) < thereshold
        samplemarker(1:state_change) = NaN;
    end
    
    final_state = samplemarker(end);
    state_change = find(samplemarker ~= final_state,1, 'last'); 
    if abs(sample_time(state_change) - sample_time(end)) < thereshold
        samplemarker(1:state_change) = NaN;
    end
 end
 % HANDLING ARGUMENTS
 function accept = checktemporal(inputs)
 numiunputs = length(inputs);
 accept = 1;
 if (numiunputs > 3 || numiunputs == 0)
     assert( ' You can only give one or two values for the temporal inputs ')
 end
 for input_idx = 1:numiunputs
     input = inputs(input_idx);
     if ~ ( isstring(input) || isnumeric(input) || input == ' ')
         accept = 0;
     end
 end
 end
 % Fixation utility
 function diff_matrix = fixation_distance(fixation)
 diff_matrix = zeros(fixation.number ,fixation.number );
 for i = 1:fixation.number
     x_values = fixation.average_gazex - fixation.average_gazex(i);
     y_values = fixation.average_gazey - fixation.average_gazex(i);
     diff_matrix(i,:) = sqrt(x_values .^ 2 + x_values .^ 2);
 end
 end 
 function entropytotal = get_ent(number_of_regions, looked_regions)
 %% Variable initlization
 looks_matrix = zeros(number_of_regions,number_of_regions);
 entropy_matix = zeros(number_of_regions,number_of_regions);
 row_total = zeros(number_of_regions);
 col_total = zeros(number_of_regions);
 
 %% Computing the transition matrix
 for looked_index =2:length(looked_regions)
     from = looked_regions(looked_index-1);
     to = looked_regions(looked_index);
     looks_matrix(from,to) = looks_matrix(from,to)+1;
 end
 
 %% Entropy calculations
 entropy_matrix = looks_matrix * log2(1./looks_matrix);
 columntotals = sum(looks_matrix,1); % option 1 for columns, 2 for rows
 rowtotals = sum(looks_matrix,2); 
 column_entropy = columntotals .* log2(1./columntotals);
 row_entropy = rowtotals .* log2(1./rowtotals); 
 column_entropy_totals = nansum(column_entropy); %nansum excludes nan values
 row_entropy_totals = nansum(row_entropy); 
 correction = (column_entropy_totals + row_entropy_totals)/2;
 cellenttotal = nansum(nansum(entropy_matrix));
 
 entropy_total = column_entropy_totals + row_entropy_totals - cellenttotal;
 entropytotal = 1-( entropy_total /correction);
 end
 
 
 
 
 