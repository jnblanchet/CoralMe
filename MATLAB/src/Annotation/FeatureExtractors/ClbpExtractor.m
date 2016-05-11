classdef ClbpExtractor < AbstractTextureRepresentationExtractor
    %CLBPEXTRACTOR a CLBP feature extractor. Color information is also
    %extracted. TODO: add citations.
    
    properties (Access = private)
        cache
    end
    
    methods (Access = public)
        function this = ClbpExtractor()
            this.cache = [];
        end
        
        function features = extractFeatureFunction(this, x0, x1, y0, y1, mask, image, imageName)
            [features, this.cache] = extractClbpWithColor(x0, x1, y0, y1, mask, image, imageName, this.cache);
        end
    end
    
end

