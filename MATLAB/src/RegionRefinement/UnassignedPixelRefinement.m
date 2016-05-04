classdef UnassignedPixelRefinement < AbstractSegmentationTool
    %UNASSAIGNEDPIXELREFINEMENT 
    properties (Access = private)
        lbpMap
        colorMap
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
            this.segMap = imresize(segMap,size(image,1),size(image,2),'nearest');
            this.cacheTextureFeatures();
        end
        
        function this = assignFreePixels(image, segMap)
            % (sample a bunch of random pixels)
            % start by building a K-D tree for each class (sample a bunch of random
            % pixels)
            
            % for each pixel
                % calculate GMM probability to each class. (nbPixels x nbClasses)
                % calculate euclidian distance to nearest pixel of this
                % query type KD-TREE.
                
        end
     
    end
    
    methods (Access = private)
        function cacheTextureFeatures(this)
            im_g = rgb2gray(this.resizedImage);
            [h,w,~] = size(im_g);
            samplingPoints = 8; distance = 1;
            mapping = LbpMapping(samplingPoints,'riu2');
            [~,map] = Lbp(im_g,distance,samplingPoints,mapping); % extract lbp map
            this.lbpMap = imresize(map, [h,w],'nearest');
            colorNorm = comprehensiveColorNorm(this.resizedImage); % generate colorMap
            hsv = rgb2hsv(colorNorm);
            this.numBins = 10; % numel(uniquemapping)), hard coded for speed
            this.colorMap = uint8(hsv(:,:,1)*(this.numBins-1));
        end
    end
end
