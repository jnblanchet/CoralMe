classdef (Abstract) AbstractSegmentationTool < handle
    %ABSTRACTSEGMENTATIONAPPROACH Contains useful methods for all
    %segmentation refinement tools.
    
    properties (Access = protected)
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
    end
end