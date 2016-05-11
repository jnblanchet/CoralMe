function [ data, map ] = processImageGraphCut( image, imageName, labels, positions, id, featureCache, workingDir)
%PROCESSIMAGEMULTISIZE The entry point for feature extraction using graph cut.
% "labels" and "positions" can be empty (will not apply custom filter).

    isTrain = ~isempty(labels) && ~isempty(positions);
    
    file = [featureCache filesep 'data_graphcut_' num2str(id) '.mat'];
    if ~isTrain || ~exist(file,'file')
        % create groundtruth map
        if (isTrain)
            expertLabelMap = zeros(size(image,1),size(image,2));
            for p=1:numel(labels)
                expertLabelMap(positions(p,2),positions(p,1)) = labels(p);
            end
        end
        % segment
        [ map, bb ] = segmentMlcImage( image );
        % Extract adaptive graph cut features for some points
        idx = 1;
        for p=2:numel(bb) % start at 2, first one is quadrat   
            box = round(bb(p).BoundingBox);
            x0 = box(2); x1 = x0 + box(4);
            y0 = box(1); y1 = y0 + box(3);
            mask = (map(x0:x1,y0:y1) == p);
            % only keep region with 2 or more points of a single class (custom filtering, applicable only for training)
            if (isTrain)
                expertLabelMapCropped = expertLabelMap(x0:x1,y0:y1);
                expertLabelsInsideRegion = expertLabelMapCropped(mask);
                expertLabelsInsideRegion = expertLabelsInsideRegion(expertLabelsInsideRegion~=0);
                if(numel(expertLabelsInsideRegion) < 2 || numel(unique(expertLabelsInsideRegion)) > 1)
                    continue;
                end
            end
            % extract features
            data.featuresClbp(idx,:) = extractClbpWithColor(x0, x1, y0, y1, mask, image, imageName, workingDir);
            data.featuresCnn(idx,:) = extractCnnActivation(x0, x1, y0, y1, mask, image, imageName, workingDir);
            data.featuresTex(idx,:) = extractTexton(x0,x1,y0,y1, mask, image, imageName, workingDir);
            if(isTrain)
                data.labels(idx) = expertLabelsInsideRegion(1);
            end
            data.idOnMap(idx) = p;
            idx = idx + 1;
        end
        % write to hard drive
        if(isTrain)
            save(file,'data');
        end
    end

end

