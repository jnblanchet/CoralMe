classdef (Abstract) AbstractTextureRepresentationExtractor < handle
    %ABSTRACTTEXTUREREPRESENTATIONEXTRACTOR an interface for feature
    %extraction functions. Wrapping these in classes allows caching for
    %efficient sucessive extraction calls.
    
    methods (Abstract)
        features = extractFeatureFunction(this, x0, x1, y0, y1, mask, image, imageName)
    end
    
    methods (Access = public)
        function features = extractFeatures(this,image,segmap)
            map = imresize(segmap.getMap(),[size(image,1),size(image,2)],'nearest');                
            % get unique image signature (so we can use cache when possible)
            sig = this.getSignature(image);
            for p=max(map(:)):-1:1
                % extract features
                features(p,:) = this.extractFeatureFunction(1, size(image,1), 1, size(image,2), map == p, image, sig);
            end
        end
    end
    methods (Access = private)
        % a "hash" algorithm that generates a unique Id
        function sig = getSignature(this,f)
            f = [f(:); zeros((32-mod(numel(f),32)),1)];
            h = reshape(f,32,[]);
            sig = zeros(32,1,'uint8');
            for i=1:size(h,2)
               sig = bitxor(sig, h(:,i));
            end
            sig = char(mod(sig - 'a',('z'-'a'))+'a')';
        end
    end
end

