classdef CnnActivationExtractor < AbstractTextureRepresentationExtractor
    %CNNACTIVATIONEXTRACTION a feature extraction based on CNN activation
    %weights. TODO: add citations.

    
    methods (Access = public)
        function this = CnnActivationExtractor()
        end
        
        function features = extractFeatureFunction(this, x0, x1, y0, y1, mask, image, imageName)
            % crop the mask
            bb = regionprops(mask,'BoundingBox');
            coords = round(cell2mat(struct2cell(bb)'));
            box = [coords(2), coords(2) + coords(4), coords(1), coords(1) + coords(3)];
            
            features = extractCnnActivation(box(1), box(2), box(3), box(4), image);
        end
    end
    
end
