classdef SmartRegionSelector < AbstractSegmentationApproach
    %SMARTREGIONSELECTOR A a tool for fast coral image segmentation.
    %   Segmenation is done by adding successive blobs and changing their
    %   parameters to fit the image. The LabelMap and contourImage give
    %   real-time feedback to better define the segmentation.
    
    properties (Access = private)
        currentGroupId
        kernelSize % the expected radius of a texel
    end
    
    properties (Access = public)
        Blobs
        TextureMap
    end
    
    methods (Access = public)
        % Constructor
        function this = SmartRegionSelector(image, segMap, kernelSize)
            % checks
            if nargin < 1 || isempty(image)
                error('Invalid image argument.');
            end
            if nargin < 2 || isempty(segMap)
                segMap = SegmentationMap();
            end
            if size(image,3) ~= 3
                error('Expected MxNx3 image argument.');
            end
            if nargin < 3 || kernelSize <= 0
                kernelSize = 20; % default value1
            end
            
            % initialize
            this.segMap = segMap;
            this.currentGroupId = 0;
            this.kernelSize = kernelSize;
            this.Blobs = {};
            this.TextureMap = [];
            this.setImage(image);
        end
        
        % called when adding a new blob.
        % coordinates may be absolute (in px, after resize) or relative (0 < x < 1)
        % if using relative coordinates, r is defined as a ratio of the width
        function newBlobId = createBlob(this,x,y,r)
            x = this.toAbsolute(x,size(this.resizedImage,1));
            y = this.toAbsolute(y,size(this.resizedImage,2));
            if(x < 1 || y < 1 || x > size(this.image,1) || y > size(this.image,2))
                error('Invalid point position');
            end
            
            newBlobId = numel(this.Blobs) + 1;
            % estimate a good default size (adaptive)
            if nargin < 4
                 r = this.getGoodRadiusEstimate();
            end
            r = this.toAbsolute(r,size(this.resizedImage,2));
            % create blob
            this.Blobs{newBlobId} = Blob(x,y,r,newBlobId,this.nextGroupId());
        end
        
        % an existing blob of the same group can be copied to a new location (extend region)
        % r is optional.
        function newBlobId = copyBlobToLocation(this, blobId, x, y, r)
            x = this.toAbsolute(x,size(this.resizedImage,1));
            y = this.toAbsolute(y,size(this.resizedImage,2));
            % estimate a good default size (adaptive)
            if nargin < 5
                 r = this.getGoodRadiusEstimate();
            end
            r = this.toAbsolute(r,size(this.resizedImage,2));
            
            newBlobId = numel(this.Blobs) + 1;
            this.Blobs{newBlobId} = Blob(x,y,100,newBlobId,this.Blobs{blobId}.getGroupId);
            
            if nargin >= 5
                this.resizeBlobRegion(newBlobId, r)
            end
        end
        
        % blobs can be relocated
        function moveBlob(this, blobId, x, y)
            x = this.toAbsolute(x,size(this.resizedImage,1));
            y = this.toAbsolute(y,size(this.resizedImage,2));
            this.Blobs{blobId}.moveTo(x,y);
        end
        
        % blobs can be deleted
        function deleteBlob(this, blobId)
            this.Blobs{blobId} = [];
        end
        
        % blobs can be resized
        % if using relative size is used for r (0 < r < W), r is defined as a ratio of the width
        function resizeBlobRegion(this, blobId, newSize)
            newSize = this.toAbsolute(newSize,size(this.resizedImage,2));
            this.Blobs{blobId}.resize(newSize);
        end
        
        % check if Id is valid
        function valid = isValidBlobId(this, blobId)
            valid = blobId >= 1 && blobId <= numel(this.Blobs) && ~isempty(this.Blobs{blobId});
        end
        
        % get the resulting segmentation maps for display, use the
        % this.getLabelMap (index map) method for feature extraction.
        function [contourImage] = getMap(this)
            labelMap = zeros(size(this.TextureMap,1),size(this.TextureMap,2),'uint16');
            for i=1:numel(this.Blobs)
                if(isempty(this.Blobs{i}))
                    continue;
                end
                [box,mask] = this.Blobs{i}.getSegmentation(this.TextureMap);
                tmpCrop = labelMap(box(1):box(2),box(3):box(4),:);
                mask(~~tmpCrop) = false; % ignore pixels that are already assigned
                tmpCrop(mask) = this.Blobs{i}.getGroupId();
                labelMap(box(1):box(2),box(3):box(4)) = tmpCrop;
            end
            this.segMap.setMap(labelMap);
            contourImage = this.getContourImage();
        end
        
        function size = getKernelSize(this)
            size = this.kernelSize;
        end
        
        function setKernelSize(this, newSize)
            this.kernelSize = newSize;
            this.initTextureMap(this.image);
        end
            
    end
    
    methods (Access = private)
        
        function id = nextGroupId(this)
            this.currentGroupId = this.currentGroupId + 1;
            id = this.currentGroupId;
        end
        
        function initTextureMap(this, image)
            this.TextureMap = computeTextureMap( this.resizedImage, this.kernelSize);
        end
        
        function r = getGoodRadiusEstimate(this)
            r = 0; counter = 0;
            for i=1:numel(this.Blobs)
                if(isempty(this.Blobs{i}))
                    continue;
                end
                r = r + this.Blobs{i}.getRadius();
                counter = counter + 1;
            end
            if counter == 0
                r = 100;
            else
                r = r ./ counter;
            end
        end
        
    end
    
    methods (Access = protected)
        
        function afterImageChanged(this)
            this.Blobs = {};
            this.initTextureMap(this.resizedImage);
        end
        
    end
    
end