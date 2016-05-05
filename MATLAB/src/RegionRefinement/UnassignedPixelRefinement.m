classdef UnassignedPixelRefinement < AbstractSegmentationTool
    %UNASSAIGNEDPIXELREFINEMENT
    properties (Access = private)
        unlabeledPoints
        classes 
        textureMap
        positionModels
        textureModels
        image
    end
    
    
    methods (Access = public)
        % Constructor
        function this = UnassignedPixelRefinement(image, segMap)
            this.image = image;
            if nargin < 1 || isempty(image) || isempty(image)
                error('A valid image must be specified.');
            end
            this.segMap = segMap;
            this.fixIds();
            this.unlabeledPoints = find(segMap.getMap() <= 0);
            
            if nargin < 1 || isempty(segMap) || isempty(segMap.getMap())
                error('A valid segmentation map must be specified.');
            end
            %this.segMap.setMap(imresize(segMap.getMap(),[size(image,1),size(image,2)],'nearest'));
            this.cacheTextureFeatures(image);
        end
        
        function contourImage = assignFreePixels(this,regularizationWeight)
            newMap = this.segMap.getMap();
             
%             classes
%             unlabeledPoints
             
            textureDistance = zeros(numel(this.unlabeledPoints),numel(this.classes));
            positionDistance = textureDistance;
            
            % compute position distance
            [i,j] = ind2sub(size(newMap),this.unlabeledPoints);
            for n=1:numel(this.classes)
                [~, distance] = vl_kdtreequery(this.positionModels{n}.kdtree, this.positionModels{n}.X, [i';j']);
                positionDistance(:,n) = distance(:);
            end
            positionDistance = positionDistance ./ max(positionDistance(:));
            
            % compute texture distance

            for c = size(this.textureMap,3):-1:1;
                m = this.textureMap(:,:,c);
                texturePoints(c,:) = m(this.unlabeledPoints);
            end

            for n=1:numel(this.classes)
                %TODO: consider sigma (not using it is faster, this is why we ignore it for now)
                distance = vl_alldist2(this.textureModels{n}.mu,texturePoints);
                mindistance = min(distance .* repmat((1./this.textureModels{n}.p),1,size(distance,2)));
                textureDistance(:,n) = mindistance(:);
            end
            textureDistance = textureDistance ./ max(textureDistance(:));

            % compute total distance
            totalDistance = regularizationWeight * positionDistance + textureDistance;
            [~,newLabels] = min(totalDistance,[],2);
            
            % assign to new map
            newMap(this.unlabeledPoints) = this.classes(newLabels);
            newMap = medfilt2(newMap, [25,25]);
            this.segMap.setMap(newMap);
            contourImage = this.segMap.getContourImage();
        end
        
    end
    
    methods (Access = private)
        function cacheTextureFeatures(this, image)
            segMap = this.segMap.getMap();
            
            % extract texture maps
            resizeFact = min(1,1000 / max(size(image))); % default size
            image = imresize(image,resizeFact);
            fullTextureMap = computeTextureMap( image, 20);
            for i=size(fullTextureMap,3):-1:1
                this.textureMap(:,:,i) = imresize(fullTextureMap(:,:,i),size(segMap));
            end
            
            % model each regions (position, and texture)
            samplesPerClass = 100; % for efficiency, the number of pixels per class considered for modeling
            this.classes = unique(segMap(:));
            this.classes = this.classes(this.classes > 0); % negative or zero means unassigned.
            numclasses = numel(this.classes);
            this.positionModels = cell(numclasses,1); % positions are modeled using one KD-tree per class
            this.textureModels = cell(numclasses,1); % texture is modeled using one GMM per class
            for x=1:numel(this.classes)
                n = this.classes(x);
                pixels_n = find(segMap == n);
                sample_n = pixels_n(unique(round(1:numel(pixels_n)/samplesPerClass:numel(pixels_n))));
                [i,j] = ind2sub(size(segMap),sample_n);
                % position
                kdt = struct();
                kdt.X = [i';j'];
                kdt.kdtree = vl_kdtreebuild(kdt.X);
                this.positionModels{x} = kdt;
                % texture
                for c = size(this.textureMap,3):-1:1;
                    m = this.textureMap(:,:,c);
                    texturePoints(c,:) = m(this.unlabeledPoints);
                end
                gmm = struct();
                [gmm.mu, gmm.sigma, gmm.p] = vl_gmm(texturePoints,5);                
                this.textureModels{x} = gmm;
            end
        end
    end
end
