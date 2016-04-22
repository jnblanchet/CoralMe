classdef (Abstract) AbstractSegmentationApproach < handle
    %ABSTRACTSEGMENTATIONAPPROACH Contains useful methods for all
    %segmentation approaches
    
    properties (Access = protected)
        image
        resizedImage
        labelMap
        resizeFactor
    end
    
    methods (Access = protected)        
        function contourImage = getContourImage(this)
            s = size(this.image);
            labels_rgb = label2rgb(uint8(this.labelMap),'jet','k');
            labels_rgb = imresize(labels_rgb,s(1:2),'nearest');
            labels = this.labelMap;
            labels = ~~abs(imfilter(labels,[-1,-1,-1;-1,8,-1;-1,-1,-1], 'same'));
            labels = imresize(labels,s(1:2));
            labels = imdilate(labels,strel('disk',3));
            contourImage = zeros(s(1),s(2),4,'uint8');
            contourImage(:,:,1:3) = labels_rgb;
            
            % 4th channel is transparency
            contourImage(:,:,4) = uint8(labels(:,:,1));
        end
    end
    
    methods (Access = public)
        function setImage(this, image, sizeFactor)        
            if(nargin < 3)
                sizeFactor = min(1,750 / max(size(image))); % default size
            elseif sizeFactor > 1
                error('Upscaling image not supported.')
            end
            
            this.image = image;
            % TODO: replace imresize to remove image processing toolbox
            % dependency
            this.resizedImage = imresize(image, sizeFactor);
            
            % call custom invalidation logic
            this.afterImageChanged();
        end
        
        function ready = isReady(this)
            ready = true;
        end
        
        function setResizeFactor(this, resizeFactor)
            if resizeFactor > 1
                error('Upscaling image not supported.')
            end
            this.resizeFactor = resizeFactor;
            this.resizedImage = imresize(image ,resizeFactor);
            this.afterImageChanged();
        end
        
        function resizeFactor = getResizeFactor(this)
            resizeFactor = this.resizeFactor;
        end
        
        function labelMap = getLabelMap(this)
            labelMap = this.labelMap;
        end
    end
    
    methods (Abstract, Access = protected)
        afterImageChanged(this);
    end
    
    methods (Access = protected)
        function y = toAbsolute(this, x, ref)
            if(x < 1.0)
                y = round(x * ref);
            else
                y = round(x);
            end
        end
    end
end