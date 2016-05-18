classdef RegionInfoProvider < handle
    %REGIONINFOPROVIDER Provides display data for a segmented image.
    % Designed to provide data helpful for visualization when performing
    % annotation. It uses a segmentation map (see constructor) and provides
    % info. Note that all regions with a zero or negative index are
    % ignored, and considered to be background information.
    % The class has the following functionalities:
    %
    % 1) getgoodRegionCenters() will provide a center (relative coordiantes
    % between 0 and 1) in the form (x,y) that represents the center of the
    % largest region beloging to a reagion. The returned value contains one
    % entry per region on the segmentation.
    %
    % 2) getRegionColors() returns the (R,G,B) values used in the color
    % representation of the map.
    
    
    properties (Access = private)
        segMap
    end
    
    methods (Access = public)
        function this = RegionInfoProvider(segMap)
            segMap.fixIds();
            this.segMap = segMap;
        end
        
        function bestCenter = getGoodRegionCenters(this)
            map = this.segMap.getMap();
            [h,w] = size(map);
            
            classes = unique(map(:));
            classes = classes(classes > 0);
            if ~isequal(classes,(1:max(map(:)))')
                error('labels should be from 1 to n at this point.')
            end
            
            bestCenter = zeros(numel(classes),2,'double'); % (x,y) of each class
            for c = classes' % dependency to the image processing toolbox!
                CC = struct2cell(regionprops(map == c,'Centroid','FilledArea'));
                [~,id] = max(cell2mat(CC(2,:)));
                bestCenter(c,:) = cell2mat(CC(1,id)) ./ [h,w];
            end
        end
        
        % returns a color legend matrix of size n (labels count) by 3 (R G B)
        function colorLegend = getRegionColors(this)
            colorLegend = this.segMap.getColors();
        end
        
    end
    
end

