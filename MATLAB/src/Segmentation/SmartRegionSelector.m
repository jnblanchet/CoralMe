classdef SmartRegionSelector < handle
    %SMARTREGIONSELECTOR A a tool for fast coral image segmentation
    %   Segmenation is done by adding successive blobs and changing their
    %   parameters to fit the image. The LabelMap and contourImage give
    %   real-time feedback to better define the segmentation.
    
    properties (Access = private)
        currentGroupId
        kernelSize % the expected radius of a texel
        image % for visualization
    end
    
    properties (Access = public)
        Blobs
        TextureMap
    end
    
    methods (Access = public)
        % Constructor
        function this = SmartRegionSelector(image, kernelSize)
            % checks
            if nargin < 1 || isempty(image)
                error('Invalid image argument.');
            end
            if size(image,3) ~= 3
                error('Expected MxNx3 image argument.');
            end
            if nargin < 2 || kernelSize <= 0
                kernelSize = 20; % default value
            end
            
            % initialize
            this.currentGroupId = 0;
            this.kernelSize = kernelSize;
            this.Blobs = {};
            this.TextureMap = [];
            this.image = image;
            
            this.initTextureMap(image);
        end
        
        % called when adding a new blob.
        function newBlobId = createBlob(this,x,y)
            if(x < 1 || y < 1 || x > size(this.image,1) || y > size(this.image,2))
                error('Invalid point position');
            end
            
            newBlobId = numel(this.Blobs) + 1;
            % estimate a good default size (adaptive)
            adaptiveSize = 0; counter = 0;
            for i=1:numel(this.Blobs)
                if(isempty(this.Blobs{i}))
                    continue;
                end
                adaptiveSize = adaptiveSize + this.Blobs{i}.getRadius();
                counter = counter + 1;
            end
            if counter == 0
                adaptiveSize = 100;
            else
                adaptiveSize = adaptiveSize ./ counter;
            end
            % create blob
            this.Blobs{newBlobId} = Blob(x,y,adaptiveSize,newBlobId,this.nextGroupId());
        end
        
        % an existing blob of the same group can be copied to a new location (extend region)
        function newBlobId = copyBlobToLocation(this, blobId, x, y)
            newBlobId = numel(this.Blobs) + 1;
            this.Blobs{newBlobId} = Blob(x,y,100,newBlobId,this.Blobs{blobId}.getGroupId);
        end
        
        % blobs can be relocated
        function moveBlob(this, blobId, x, y)
            this.Blobs{blobId}.moveTo(x,y);
        end
        
        % blobs can be deleted
        function deleteBlob(this, blobId)
            this.Blobs{blobId} = [];
        end
        
        % blobs can be resized
        function resizeBlobRegion(this, blobId, newSize)
            this.Blobs{blobId}.resize(newSize);
        end
        
        % check if Id is valid
        function valid = isValidBlobId(this, blobId)
            valid = blobId >= 1 && blobId <= numel(this.Blobs) && ~isempty(this.Blobs{blobId});
        end
        
        % get the resulting segmentation maps for display or feature extraction..
        function [labelMap, contourImage] = getMap(this)
            labelMap = zeros(size(this.image,1),size(this.image,2),'uint16');
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
            
            s = size(this.image);
            labels_rgb = label2rgb(uint8(labelMap),'jet');
            labels_rgb = imresize(labels_rgb,s(1:2),'nearest');
            labels = labelMap;
            labels = ~~abs(imfilter(labels,[-1,-1,-1;-1,8,-1;-1,-1,-1], 'same'));
            labels = imclose(labels,strel('disk',3));
            labels = imresize(labels,s(1:2));
            labels = imdilate(labels,strel('disk',2));
            contourImage = uint8(zeros(size(this.image)));
            p = uint8(~labels);
            n = uint8(labels);
            for c=1:3
                contourImage(:,:,c) = this.image(:,:,c) .* p + labels_rgb(:,:,c) .* n;
            end
        end
    end
    
    methods (Access = private)
        
        function id = nextGroupId(this)
            this.currentGroupId = this.currentGroupId + 1;
            id = this.currentGroupId;
        end
        
        function initTextureMap(this, image)
            this.TextureMap = computeTextureMap( image, this.kernelSize);
        end
        
    end
end