classdef condition < handle
    properties 
        parent
        address
        data
        image_name
        roi_data
        
        
        %% Grid
        grid
        grid_x
        grid_y
    end
    
    methods
        function obj = condition(parent, fcn)
          obj.parent = parent;
          obj.address = dir(fullfile(parent.parent.address, '*.dat'));
          obj.address = fullfile(obj.address.folder, obj.address.name);
          obj.data = fcn(obj.address);
        end
        function get_imagefile(obj)
            obj.image_name =  obj.data(1,'filename');
        end
        function get_roidata(obj, fcn)
            roi_data_file = dir(fullfile(obj.parent.parent.address, '*.ias'));
            roi_data_file =  fullfile(roi_data_file.folder, roi_data_file.name);
            obj.roi_data = fcn(roi_data_file);
        end 
        function get_grid(obj)
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
