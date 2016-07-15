classdef SegmentationMap < handle
    %SEGMENTATIONMAP An index map wrapper to keep a reference on it.
    
    properties (Access = private)
        map
    end
    
    methods (Access = public)
        
        function this = SegmentationMap()
        end
        function contourImage = getContourImage(this)
            if isempty(this.map)
                error('Segmentation map has not been set.')
            end
            s = size(this.map);
            labels_rgb = label2rgb(uint8(this.map),'jet','k');
            labels_rgb = imresize(labels_rgb,s(1:2),'nearest');
            labels = this.map;
            labels = ~~abs(imfilter(labels,[-1,-1,-1;-1,8,-1;-1,-1,-1], 'same'));
            labels = imresize(labels,s(1:2));
            labels = imdilate(labels,strel('disk',2));
            contourImage = zeros(s(1),s(2),4,'uint8');
            contourImage(:,:,1:3) = labels_rgb;
            
            % 4th channel is transparency
            contourImage(:,:,4) = uint8(labels(:,:,1));
        end
        
        function map = getMap(this)
            map = this.map;
        end
        function setMap(this, map)
            this.map = int32(map); % unit8 doesn't support more than 256 regions!
        end
        
        function fixIds(this)
            % consolidate ids
            u = unique(this.map);
            
            restoreBg = false;
            if sum(u<=0) > 0 %handle background class
                this.map = this.map + 1;
                u = u + 1;
                restoreBg = true;
            end
            
            LUT = zeros(max(u),1);
            LUT(u) = (1:numel(u));
            this.map = LUT(this.map);
            
            if restoreBg %restore background class
                this.map = this.map - 1;
            end
        end
        
        function colorLegend = getColors(this)
            classes = unique(this.map);
            colorLegend = squeeze(label2rgb(classes,'jet','k'));
            % filter out non zeros classes
            colorLegend = colorLegend(classes > 0,:);
        end
        
        function clearMap(this)
            this.map = [];
        end
    end
    
end

