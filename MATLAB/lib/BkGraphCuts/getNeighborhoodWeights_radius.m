function [neighborhoodWeights idxImg nMaskWeight] = getNeighborhoodWeights_radius(img, optimizationOptions)

img = double(img);
    [numRows numCols dummy] = size(img);
    numSites = numRows * numCols;
    type = optimizationOptions.NEIGHBORHOOD_TYPE;
%     if size(img,3) == 3 && strcmp(optimizationOptions.colormode,'Lab')
%         img = RGB2Lab(img);
%     end
%         
    % this idxImg will hold site id for each pixel (rowwise)
    idxImg = zeros(numRows, numCols);
    
    % idx scans img colwise
    idxImg(:) = 1:numSites;
    

    switch type
        case 4
            radius = 1;
        case 8
            radius = 1;
        case 16
            radius = 2;
    end
    
    % negibhros go from -r to +r
    i = -radius:radius;
    j = -radius:radius;
    [shiftRows, shiftCols] = ndgrid(i,j);
    a = shiftRows;
    a(:) = 1:numel(shiftRows);
    
    switch type
        case 4
            nMask = false(size(shiftRows));
            nMask(2,3) = 1;
            nMask(3,2) = 1;
        case 8
            nMask = (a > a(radius+1,radius+1));
            
        case 16
            nMask = (a > a(radius+1,radius+1));
            nMask(1:2:end,end) = 0;
            nMask(end,1:2:end) = 0;
    end
    nMaskWeight = 1./sqrt(shiftRows.^2 + shiftCols.^2);
    nMaskWeight(radius+1,radius+1) = 0;
%     figure; imagesc(nMask); colorbar; hold on; title('half neighborhood'); colormap gray
    % prepare weights (distance based to begin with)    
    % these are the neighbors we need to consider
    shiftRows = shiftRows(nMask);
    shiftCols = shiftCols(nMask);
    
    % collect pairs (me,neighbor,weight)
    siteIdx = [];
    nSiteIdx = [];
    weights = [];
    
    [allRows, allCols] = ndgrid(1:numRows, 1:numCols);
    % go over all possible shifts
    for currShift = 1:length(shiftRows)
        currRowShift = shiftRows(currShift);
        currColShift = shiftCols(currShift);
    
        % add the shift and only take those pixels that have neighbors
        % inside the image
        nRows = allRows + currRowShift;
        meIdx = (nRows <= numRows) & (nRows>=1);
        
        nCols = allCols + currColShift;
        meIdx = (nCols <= numCols) & (nCols>=1) & meIdx;
        
        % these are the indices of the the pixels that have negibhors with
        % currShift inside the image
        me = idxImg(meIdx);
        % and those are the indexes of the neighbors
        neighbor = vec(idxImg(sub2ind([numRows, numCols],nRows(meIdx),nCols(meIdx))));
        
        siteIdx = [siteIdx ; me];
        nSiteIdx = [nSiteIdx ; neighbor];
        weights = [weights; ones(length(neighbor),1)./sqrt(currRowShift.^2 + currColShift.^2)];
        
    end
        
        
    % if options.neighborhoodBeta != 0, compute weights based on the image
    % it is (1/dist) * exp(-beta * (I1-I2)^2)
    if (optimizationOptions.neighborhoodBeta)
        colourdiff = zeros(length(siteIdx),1);
        for i=1:size(img,3)
            channel = vec(img(:,:,i));
            colourdiff = colourdiff + (channel(siteIdx) - channel(nSiteIdx)).^2;
        end
        weights = 0.75*exp(-optimizationOptions.neighborhoodBeta * colourdiff).*weights + 0.25*weights;
    end
    weights = weights .* optimizationOptions.LAMBDA_POTTS;
    % else use distance based weights
    
    neighborhoodWeights = sparse(siteIdx, nSiteIdx, weights, numSites, numSites, ((2*radius+1)^2)*numSites);
end