classdef CnnActivationExtractor < AbstractTextureRepresentationExtractor
    %CNNACTIVATIONEXTRACTION a feature extraction based on CNN activation
    %weights. TODO: add citations.

    
    methods (Access = public)
        function this = CnnActivationExtractor()
        end
        
        function features = extractFeatureFunction(this, x0, x1, y0, y1, mask, image, imageName)
            features = extractCnnActivation(x0, x1, y0, y1, image);
        end
    end
    
end
