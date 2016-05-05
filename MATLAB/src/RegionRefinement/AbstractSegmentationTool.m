classdef (Abstract) AbstractSegmentationTool < handle
    %ABSTRACTSEGMENTATIONAPPROACH Contains useful methods for all
    %segmentation refinement tools.
    
    properties (Access = public)
        segMap
    end
    
    methods (Access = public)
        function ready = isReady(this)
            ready = true;
        end
        
        function contourImage = getMap(this)
            contourImage = this.segMap.getContourImage();
        end
    end
    
    methods (Access = protected)
        function y = toAbsolute(this, x, ref)
            if(x < 1.0)
                y = round(x * ref) + 1;
            else
                y = round(x);
            end
        end
        
        function fixIds(this)
            % consolidate ids
            labelMap = this.segMap.getMap();
            u = unique(labelMap);
            LUT = zeros(max(u),1);
            LUT(u+1) = (1:numel(u)) - 1;
            this.segMap.setMap(LUT(labelMap+1));
        end
    end
end