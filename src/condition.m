classdef condition < handle
     % sets the experiments conditional data for the trial or participant 
    properties 
        parent % Related trial or experiment object
        address % adress of the .dat file
        data % condition data table
        image_name % Participant's view image name(s)
        roi_data % Participant interesting region(s), Spatial or temporal
        
        
        %% Grid
        grid % in development 
        grid_x
        grid_y
    end
    
    methods
        function obj = condition(parent, fcn)
            % Given a parent and import function, creates a condition
            % object. Sets the data and adress properties 
                  
          obj.parent = parent;
          obj.address = dir(fullfile(parent.address, '*.dat'));
          obj.address = fullfile(obj.address.folder, obj.address.name);
          obj.data = fcn(obj.address);
        end
        function get_imagefile(obj)
            % sets the image name for the condition 
            obj.image_name =  obj.data(1,'filename');
        end
        
        function get_roidata(obj, fcn)
            %sets roi_data for the condition 
            roi_data_file = dir(fullfile(obj.parent.address, '*.ias'));
            roi_data_file =  fullfile(roi_data_file.folder, roi_data_file.name);
            obj.roi_data = fcn(roi_data_file);
        end 
        function get_grid(obj)
            % Creates a grid the size of the image. Using 1*1 squares . In
            % develpment for varying square sizes 
            obj.grid_x= table2array(obj.roi_data(1,[3,5]));
            obj.grid_y= table2array(obj.roi_data(1,[4,6]));
            obj.grid = cell(obj.grid_x(2) - obj.grid_x(1), ...
                            obj.grid_y(2) - obj.grid_y(1));
            for i=1:(obj.grid_x(2) - obj.grid_x(1)) *  ... 
                     (obj.grid_y(2) - obj.grid_y(1))
                 obj.grid{i} = char(i+96);
            end
        end
        
    end
end
