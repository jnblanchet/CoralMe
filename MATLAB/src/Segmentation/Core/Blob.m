classdef Blob < handle
    %BLOB a small structure used by the gaussian region selector.

    properties (Access = private)
        id
        x
        y
        groupId
%         centerDiameter % pixels inside this region define the texture model
        radius % pixels inside this larger region are considered
        dirtyIndex
        % the following two fields define the region of interest
        box
        mask
    end
    
    methods
         % Constructor
        function this = Blob(x,y,outerDiameter,id,groupId)
            this.x = round(x);
            this.y = round(y);
            this.radius = round(outerDiameter);
            this.id = id;
            this.groupId = groupId;
            this.dirtyIndex = true;
        end
        
        function moveTo(this, x, y)
            this.dirtyIndex = true;
            this.x = round(x);
            this.y = round(y);
        end
        
        function mergeWith(this, otherBlob)
            this.dirtyIndex = true;
            this.groupId = otherBlob.groupId;
        end
        
        function resize(this, newRadius)
            this.dirtyIndex = true;
            this.radius = newRadius;
        end
        
        % get x,y position
        function pos = getPos(this)
            pos = [this.x,this.y];
        end
        % get groupId
        function id = getGroupId(this)
            id = this.groupId;
        end
        % get groupId
        function id = getId(this)
            id = this.id;
        end
        % get radius
        function radius = getRadius(this)
            radius = this.radius;
        end
        % get box & mask (segmentation)
        function [box,mask] = getSegmentation(this, textureMap)
            this.update(textureMap);
            box = this.box;
            mask = this.mask;
        end
    end
    
      methods (Access = private)
          function update(this, textureMap)
              if ~this.dirtyIndex
                  return;
              end
              this.dirtyIndex = false;

              [h,w,~] = size(textureMap);
             
              % only consider pixels within a defined radius
              r = this.radius;cx=r+1;cy=r+1;ix=r*2+1;iy=r*2+1;
              [xx,yy]=meshgrid(-(cx-1):(ix-cx),-(cy-1):(iy-cy));
              circleMask=double((xx.^2+yy.^2)<=r^2);
              
              % get patch
              rows = this.x-r:this.x+r;
              cols = this.y-r:this.y+r;
              % make sure it doesn't overflow
              row_m = rows > 0 & rows <= h;
              col_m = cols > 0 & cols <= w;
              rows_f = rows(row_m);
              cols_f = cols(col_m);
              this.box = [rows_f(1),rows_f(end),cols_f(1),cols_f(end)];
              p = textureMap(rows_f,cols_f,:);
              circleMask = circleMask(row_m,col_m); % crop weight mask
              
              % compute distance
              ref = repmat(textureMap(this.x,this.y,:),[numel(rows_f),numel(cols_f)]);
              similarityMask = sum(p .* ref,3) ./(sqrt(sum(p.^2,3)) .* sqrt(sum(ref.^2,3)));
              
              similarityMask = similarityMask ./ max(similarityMask(:));
              this.mask = logical(similarityMask.*circleMask > 0.9);
              
              this.mask = imclose(this.mask, strel('disk',3));
              
%               box = round(box / scaleFactor);
%               resizeTarget = round([box(2)-box(1)+0.5,box(4)-box(3)+0.5]);
%               segmentedMask = imresize(segmentedMask, resizeTarget,'nearest');
%               similarityMask = imresize(similarityMask, resizeTarget);
          end
      end
end

