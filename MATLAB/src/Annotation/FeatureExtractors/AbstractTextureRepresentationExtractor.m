classdef (Abstract) AbstractTextureRepresentationExtractor < handle
    %ABSTRACTTEXTUREREPRESENTATIONEXTRACTOR an interface for feature
    %extraction functions. Wrapping these in classes allows caching for
    %efficient sucessive extraction calls.
    
    methods (Abstract)
        features = extractFeatureFunction(this, x0, x1, y0, y1, mask, image, imageName)
    end
    
    methods (Access = public)
        function features = extractFeatures(this,image,segmap)
            map = imresize(segmap.getMap(),size(image,1),size(image,2),'nearest');
            
            bb = regionprops(map,'BoundingBox');
            % Extract adaptive graph cut features for some points
            for p=numel(bb):-1:1 % start at 2, first one is quadrat
                box = round(bb(p).BoundingBox);
                x0 = box(2); x1 = x0 + box(4);
                y0 = box(1); y1 = y0 + box(3);
                mask = (map(x0:x1,y0:y1) == p);
                % get unique image signature (so we can use cache when possible)
                sig = this.getSignature(f);
                % extract features
                features(p,:) = this.extractFeatureFunction(this, x0, x1, y0, y1, mask, image, sig);
            end
        end
    end
    methods (Access = private)
        % a "hash" algorithm that generates a unique Id
        function sig = getSignature(this,f)
            h = reshape(f,32,[]);
            sig = zeros(32,1,'uint8');
            for i=1:size(h,2)
               sig = bitxor(sig, h(:,i));
            end
            sig = char(mod(sig - 'a',('z'-'a'))+'a');
        end
    end
end

