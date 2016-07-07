classdef SuperPixelExtractor < AbstractSegmentationApproach
    %SMARTREGIONSELECTOR a super pixel extractor.
    %   This class is a simple wrapper to the vl_feat implementation for
    %   superpixel extraction. It includes a simple threshold-based graph cut algorithm.
    properties (Access = private)
        regionSize
        regularizer
        graphCutRatio
        % texture maps
        lbpMap
        colorMap
        numBins % used by graph cuts
    end
    
    
    methods (Access = public)
        % Constructor
        function this = SuperPixelExtractor(image, segMap)
            if nargin < 1 || isempty(image)
                error('Invalid image argument.');
            end
            if nargin < 2 || isempty(segMap)
                this.segMap = SegmentationMap();
            else
                this.segMap = segMap;
            end
            
            this.regionSize = 200;
            this.regularizer = 400;
            this.graphCutRatio = 0;
            %% this is an experiment: it replaces RGB with PCA local texture features (LBP + hue hist)
%             f_ = imresize(image,0.5);
%             textureMap = computeTextureMap( f_, 20);
%             % sample some points
%             points = reshape(textureMap,[],20);
%             % normalize
%             points = normalize( 'minmax', points);
%             % Principal component analysis
%             [coeff,~,~] = pca(points,3,'svd');
%             newIm = reshape(coeff',size(f_));
%             newIm = imresize(newIm,[size(image,1),size(image,2)]);
%             newIm = newIm - min(newIm(:));
%             newIm = newIm / max(newIm(:));
%             newIm_ = uint8(newIm * 255);
%             for i=3:-1:1
%                 newIm__(:,:,i) = histeq(newIm_(:,:,i));
%             end
            newIm__ = image;
            %%
            this.setImage(newIm__);
        end
        
        % redefining setImage to use Lab space
        function setImage(this, image)
            if(this.resizeFactor < 0) % hasn't been defined yet
                this.resizeFactor = min(1,750 / max(size(image))); % default size
            elseif this.resizeFactor > 1
                error('Upscaling image not supported.')
            end
            
            %this.image = image;
            this.image = vl_xyz2lab(vl_rgb2xyz(image)) ;
            
            this.image = image;
            this.resizedImage = imresize(this.image, this.resizeFactor);
            this.afterImageChanged();
        end
        
        function setRegionSize(this,newRegionSize)
            this.regionSize = newRegionSize;
        end
        
        function setRegularizer(this,newRegularizer)
            this.regularizer = newRegularizer;
        end
        
        function setGraphCutRatio(this,newGraphCutRatio)
            if newGraphCutRatio < 0 || newGraphCutRatio > 1.0
                error('GraphCutRatio should be between 0 and 1')
            end
            this.graphCutRatio = newGraphCutRatio;
        end
        
        function r = getRegionSize(this)
            r = this.regionSize;
        end
        
        function r = getRegularizer(this)
            r = this.regularizer;
        end
        
        function r = getGraphCutRatio(this)
            r = this.graphCutRatio;
        end
        
        function [contourImage] = getMap(this)
            labelMap = vl_slic(single(this.resizedImage), this.regionSize, this.regularizer, 'MinRegionSize',(this.regionSize/2).^2) + 1;
            
            % eliminate small regions
            %labelMap = medfilt2(labelMap, round([this.regionSize this.regionSize] / 4), 'symmetric');
            
            if this.graphCutRatio > 0
                labelMap = this.cutGraph(labelMap);
            end 
            this.segMap.setMap(labelMap);
            contourImage = this.segMap.getContourImage();
        end
        
    end
    
    methods (Access = protected)
        function afterImageChanged(this)
            if(this.graphCutRatio > 0)
                this.cacheTextureFeatures();
            end
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
        
        %% TODO: this needs to be improved significantely (it's just a proof on concept for now)
        function labelMap = cutGraph(this, labelMap)
            if isempty(this.lbpMap) || isempty(this.colorMap)
                this.cacheTextureFeatures();
            end
            
            % extract feature vector for each cell
            n = max(labelMap(:));
            features = zeros(n,2*this.numBins);
            weights = zeros(n,1);
            for i=1:n
                map = labelMap == i;
                weights(i) = sum(map(:));
                features(i,1:this.numBins) = hist(this.lbpMap(map),0:this.numBins-1);
                features(i,this.numBins+1:2*this.numBins) = hist(this.colorMap(map),0:this.numBins-1)';
            end
            
            % normalize Features
            features = features ./ repmat(max(features),n,1);
            
            % find neighbors 4-connected (to represent as a graph)
            [h,w] = size(labelMap);
            isConnected = false(n);
            for i = 2:h
                for j = 2:w
                    if(labelMap(i,j) ~= labelMap(i-1,j))
                        isConnected(labelMap(i,j), labelMap(i-1,j)) = true;
                        isConnected(labelMap(i-1,j), labelMap(i,j)) = true;
                    end
                    if(labelMap(i,j) ~= labelMap(i,j-1))
                        isConnected(labelMap(i,j), labelMap(i,j-1)) = true;
                        isConnected(labelMap(i,j-1), labelMap(i,j)) = true;
                    end
                end
            end
            
            % evaluate cost
            cost = ones(n) * Inf;
            for i = 1:n
                for j = i+1:n
                    if isConnected(i,j)
                        v = features(i,:);
                        u = features(j,:);
                        %             cost(i,j) = sum((features(i,:) - features(j,:)).^2);
                        cost(i,j) = 1- (sum(v .* u) ./(sqrt(sum(u*u')) .* sqrt(sum(v*v'))));
                        cost(j,i) = cost(i,j);
                    end
                end
            end
            
            % loop and cut
            index = DisjointSet(n);
            target = n * this.graphCutRatio;
            
            while((n - numel(unique(labelMap))) <= target)
                sizeLoss = (repmat(weights,[1,n]) + repmat(weights',[n,1]));
                sizeLoss = max(cost(~isinf(cost))) * sizeLoss ./ max(sizeLoss(:));
                weightedCost = cost + sizeLoss;
                [val,id] = min(weightedCost(:));
                % apply cut
                [i,j] = ind2sub([n,n],id);
                cost(i,j) = Inf; cost(j,i) = Inf; % cannot merge anymore!
                i = index.find(i);
                j = index.find(j);
                newId = index.union(i,j);
                % update cost
                for x=n:-1:1
                    % row
                    if ~isinf(cost(i,x)) && ~isinf(cost(j,x))
                        newRowVal(x) = (cost(i,x) * weights(i) + cost(j,x) * weights(j)) ./ (weights(i) + weights(j));
                    elseif isinf(cost(i,x)) && ~isinf(cost(j,x))
                        newRowVal(x) = cost(j,x);
                    elseif ~isinf(cost(i,x)) && isinf(cost(j,x))
                        newRowVal(x) = cost(i,x);
                    else
                        newRowVal(x) = Inf;
                    end
                    
                    %col
                    if ~isinf(cost(x,i)) && ~isinf(cost(x,j))
                        newColVal(x) = (cost(x,i) * weights(i) + cost(x,j) * weights(j)) ./ (weights(i) + weights(j));
                    elseif isinf(cost(x,i)) && ~isinf(cost(x,j))
                        newColVal(x) = cost(x,j);
                    elseif ~isinf(cost(x,i)) && isinf(cost(x,j))
                        newColVal(x) = cost(x,i);
                    else
                        newColVal(x) = Inf;
                    end
                end
                weights(newId) = weights(i) + weights(j);
                cost(newId,:) = newRowVal;
                cost(:,newId) = newColVal;
                % update segment
                labelMap(labelMap == i | labelMap == j) = newId;
            end
            % consolidate ids
            u = unique(labelMap);
            LUT = zeros(max(u),1);
            LUT(u) = 1:numel(u);
            labelMap = LUT(labelMap);
        end
    end
    
end