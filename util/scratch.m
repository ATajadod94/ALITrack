    x = myparticipant.data{1,1}(trial_no).gx;
    x(x>1000) = nan;
    y = myparticipant.data{1,1}(trial_no).gy;
    y(y>1000) = nan;
    saccades = myparticipant.data{1,1}(trial_no).Saccades.sttime;
    figure
    hold on
    plot(x)
    plot(y)
    for saccade = saccades
       plot([saccade/2 saccade/2], [1 1000])
    end

            
        %         % original combineROIs
        %         function obj=combineROIs(obj)
        %
        %             numrois = length(obj.rois.single);
        %
        %             combined = zeros(size(obj.rois.single(1).mask));
        %
        %             for r = 1:numrois
        %
        %                 combined = combined + obj.rois.single(r).mask;
        %
        %             end
        %
        %             obj.rois.combined = combined;
        %
        %         end
        
        
     
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
        
        