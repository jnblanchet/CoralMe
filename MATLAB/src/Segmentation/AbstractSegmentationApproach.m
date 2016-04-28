classdef (Abstract) AbstractSegmentationApproach < handle
    %ABSTRACTSEGMENTATIONAPPROACH Contains useful methods for all
    %segmentation approaches
    
    properties (Access = protected)
        image
        resizedImage
        segMap
        resizeFactor = -1
    end
    
    methods (Access = protected)        
        function contourImage = getContourImage(this)            
            contourImage = this.segMap.getContourImage();
        end
    end
    
    methods (Access = public)
        function setImage(this, image)        
            if(this.resizeFactor < 0) % hasn't been defined yet
                this.resizeFactor = min(1,750 / max(size(image))); % default size
            elseif this.resizeFactor > 1
                error('Upscaling image not supported.')
            end
            
            this.image = image;
            % TODO: replace imresize to remove image processing toolbox
            % dependency
            this.resizedImage = imresize(image, this.resizeFactor);
            
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
            if resizeFactor <= 0
                error('Scale factor should greater than zero.')
            end
            this.resizeFactor = resizeFactor;
            if ~isempty(this.image)
                this.resizedImage = imresize(this.image, resizeFactor);
                this.afterImageChanged();
            end
        end
        
        function resizeFactor = getResizeFactor(this)
            resizeFactor = this.resizeFactor;
        end
        
        function labelMap = getLabelMap(this)
            labelMap = this.segMap.getMap;
        end
    end
    
    methods (Abstract, Access = protected)
        afterImageChanged(this);
    end
    
    methods (Access = protected)
        function y = toAbsolute(this, x, ref)
            if(x < 1.0)
                y = round(x * ref) + 1;
            else
                y = round(x);
            end
        end
    end
end