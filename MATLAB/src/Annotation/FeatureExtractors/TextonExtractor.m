classdef TextonExtractor < AbstractTextureRepresentationExtractor
    %TEXTONEXTRACTOR a texton extractor. TODO: add citations.
    
    
    properties (Access = private)
        cache
    end
    
    methods (Access = public)
        function this = TextonExtractor()
            this.cache = [];
        end
        
        function features = extractFeatureFunction(this, x0, x1, y0, y1, mask, image, imageName)
            [features, this.cache] = extractTexton(x0,x1,y0,y1, mask, image, imageName, this.cache);
        end
    end
    
end

