classdef UnassignedPixelRefinement < AbstractSegmentationTool
    %UNASSAIGNEDPIXELREFINEMENT 
    properties (Access = private)
    end
    
    
    methods (Access = public)
        % Constructor
        function this = GraphCutMergeTool(image, segMap)
            if nargin < 1 || isempty(image) || isempty(image)
                error('A valid image must be specified.');
            end            
            this.segMap = segMap;
            
            if nargin < 1 || isempty(segMap) || isempty(segMap.getMap())
                error('A valid segmentation map must be specified.');
            end            
            this.segMap = segMap;
        end
        
    
     
    end
    
    methods (Access = private)
    end
end
