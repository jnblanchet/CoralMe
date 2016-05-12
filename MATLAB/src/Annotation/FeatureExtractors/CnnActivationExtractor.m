classdef CnnActivationExtractor < AbstractTextureRepresentationExtractor
    %CNNACTIVATIONEXTRACTION a feature extraction based on CNN activation
    %weights. TODO: add citations.

    
    methods (Access = public)
        function this = CnnActivationExtractor()
        end
        
        function features = extractFeatureFunction(this, x0, x1, y0, y1, mask, image, imageName)
            % crop the mask
            bb = regionprops(mask,'BoundingBox');
            coords = cell2mat(struct2cell(bb)');
            coords(:,3:4) = coords(:,3:4) + coords(:,1:2);
            box = round([min(coords(:,1:2),[],1),max(coords(:,3:4),[],1)-.5]);
            
            features = extractCnnActivation(box(1), box(3), box(2), box(4), image);
        end
    end
    
end
