classdef GrabCut < AbstractSegmentationApproach
    %GrabCut segmentation, by Y.Boykov and V.Kolmogorov
    %   This class is a simple GrabCut Wrapper. It separates pixels of a
    %   given area in two groups: foreground and background. This is done
    %   using the max-flow graph cut and regularization. The user may
    %   impose hard constrains (e.g. pixel X must be part of background)
    %   allowing manual refinement.
    
    properties (Access = private)
        regularizer
        roi % current region of interest (image crop)
        roiRect % rectangle of the current region of interest
        mask % current segmentation solution for the current ROI
    end
    
    
    methods (Access = public)
        % Constructor.
        % image: the entire image currentely being worked on.
        % segMap (optional) : a pointer to the current segmentation
        function this = GrabCut(image, segMap)
            if nargin < 1 || isempty(image)
                error('Invalid image argument while trying to create a GrabCut object.');
            end
            
            if nargin < 2 || isempty(segMap)
                this.segMap = SegmentationMap();
            else
                this.segMap = segMap;
            end
            this.regularizer = 10; % default value
            
            for i=3:-1:1
                image(:,:,i) = imadjust(image(:,:,i));
            end
            this.setImage(image);
        end
        
        % set the regularizer factor (lambda)
        % recommended values are roughly between 1 and 20
        % a high value will result in smoother borders.
        % the default value is 10.
        function setRegularizer(this,newRegularizer)
            this.regularizer = newRegularizer;
        end
        
        function r = getRegularizer(this)
            r = this.regularizer;
        end
        
        
        % updates the segmentation map with the current ROI,
        % and returns the restult.
        function [contourImage] = getMap(this)
            labelMap = this.segMap.getMap();
            tmp = labelMap(this.roiRect(1):this.roiRect(2),this.roiRect(3):this.roiRect(4));
            tmp(this.mask) = (max(labelMap(:)) + 1);
            labelMap(this.roiRect(1):this.roiRect(2),this.roiRect(3):this.roiRect(4)) = tmp;
            
            this.segMap.setMap(labelMap);
            contourImage = this.segMap.getContourImage();
        end
        
        % resets the current region of interest
        % this method must be called before defining a foreground region
        % or adding hard constraints.
        % foreground coords may be absolute (multiplied by the resizeFactor<
        % size) or relative between [0,1].
        function [contourImage] = setRoi(this, x0, y0, x1, y1)
            % TODO: clear everything that was cached
            
            [x0,x1,y0,y1] = this.toAbs(x0,x1,y0,y1);
            
            this.roiRect = [x0, x1, y0, y1];
            this.roi = this.resizedImage(x0:x1,y0:y1,:);
            % approximate foreground rectangle and launch segmentation
            h = (x1 - x0)/4;
            w = (y1 - y0)/4;
            this.mask = false(size(this.roi,1),size(this.roi,2));
            this.mask(x0+h:x1-h,y0+w:y1-w) = true;
            this.computeGrabCut(); % launch segmentation.
            contourImage = this.getMap(); % return result.
        end
        
        % Defines a rectangle which contains mostly pixels beloging to the
        % object of interest. Calling this a second time will reset segmentation,
        % and override all effects of the first call.
        function [contourImage] = defineForegroundRectangle(this, x0, y0, x1, y1)
            [x0,x1,y0,y1] = this.toAbs(x0,x1,y0,y1);
            
            this.mask = false(size(this.roi,1), size(this.roi,2));
            this.mask(rect(2):rect(2)+rect(4),rect(1):rect(1)+rect(3),:) = true;
            this.computeGrabCut(); % launch segmentation.
            contourImage = this.getMap(); % return result.
        end
        
        function addForegroundHardConstraints(this,points)
            % cache, recompute, return.
        end
        
        function addBackgroundHardConstraints(this,points)
            % cache, recompute, return.
        end
        
        % deletes the region at the specified point and sets it to
        % background (0). x,y may be absolute or relative [0,1].
        function removeRegionAtPoint(this,x,y)
            x = this.toAbsolute(x,size(this.resizedImage,1));
            y = this.toAbsolute(y,size(this.resizedImage,2));
            
            labelMap = this.segMap.getMap();
            v = labelMap(x,y);
            labelMap(labelMap == v) = 0;
            this.segMap.setMap(labelMap);
        end
    end
    
    methods (Access = protected)
        function afterImageChanged(this)
            % clear everything here
        end
    end
    
    methods (Access = private)
        function computeGrabCut(this)
            [objPDF, bkgPDF] = getPDF(this.roi, this.mask);
            optimizationOptions.NEIGHBORHOOD_TYPE = 8;
            optimizationOptions.LAMBDA_POTTS = this.regularizer;
            optimizationOptions.neighborhoodBeta = computeNeighborhoodBeta(this.roi, optimizationOptions);
            [neighborhoodWeights,~,~] = getNeighborhoodWeights_radius(this.roi, optimizationOptions);
            BKhandle = BK_Create(numel(this.mask));
            BK_SetNeighbors(BKhandle, neighborhoodWeights);
            
            counter = 1; bestE = Inf; MaxNiter = 60;
            while true
                [l, ~] = optimizeWithBK(BKhandle, size(this.mask,1), size(this.mask,2), [objPDF(:)'; bkgPDF(:)']);
                this.mask = ~logical(l-1);
                
                E = ComputeEnergy(neighborhoodWeights, double(this.mask), objPDF, bkgPDF) ;
                
                if (abs(bestE - E) < 10e-4 || counter >= MaxNiter)
                    if counter == MaxNiter
                        disp(['stopped: performed ' num2str(counter) ' iterations']);
                    else
                        disp('stopped: converged');
                    end
                    break;
                end
                counter = counter + 1;
                bestE = min(E,bestE);
                
                [objPDF, bkgPDF] = getPDF(this.roi, this.mask);
            end
            BK_Delete(BKhandle);
            clear BKhandle;
        end
        
        function [x0,x1,y0,y1] = toAbs(this, x0,x1,y0,y1)
            x0 = this.toAbsolute(x0,size(this.resizedImage,1));
            y0 = this.toAbsolute(y0,size(this.resizedImage,2));
            x1 = this.toAbsolute(x1,size(this.resizedImage,1));
            y1 = this.toAbsolute(y1,size(this.resizedImage,2));
        end
    end
    
end