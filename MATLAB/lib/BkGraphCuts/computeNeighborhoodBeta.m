function neighborhoodBeta = computeNeighborhoodBeta(img, options)
% function neighborhoodBeta = computeNeighborhoodBeta(img)
% this function computes the parameter beta based on the image
% beta is used in computed the correct weights between neighboring pixels
% beta = 1./(2*mean(||(I1-I2)||^2))
% taken from GrabCut paper
[numRows numCols numChannels] = size(img); 

%     if strcmp(options.colormode,'Lab')
%         img = RGB2Lab(img);
%     end

    numSites = numRows * numCols;
    % this idxImg will hold site id for each pixel (rowwise)
    idxImg = zeros(numRows, numCols);
    % idx scans img rowwise
    idxImg(:) = 1:numSites;

    %% prepare weights 
    % right:
    me = vec(idxImg(:,1:end-1));
    neighbor = vec(idxImg(:,2:end));
    siteIdx = me;
    nSiteIdx = neighbor;
    
    
    % down:
    me = vec(idxImg(1:end-1,:));
    neighbor = vec(idxImg(2:end,:));
    siteIdx = [siteIdx; me];
    nSiteIdx = [nSiteIdx; neighbor];

    
    % diag-down-right:
    me = vec(idxImg(1:end-1,1:end-1));
    neighbor = vec(idxImg(2:end,2:end));
    siteIdx = [siteIdx; me];
    nSiteIdx = [nSiteIdx; neighbor];

    
    %diag-down-left:
    me = vec(idxImg(1:end-1,2:end));
    neighbor =  vec(idxImg(2:end,1:end-1));
    siteIdx = [siteIdx; me];
    nSiteIdx = [nSiteIdx; neighbor];

    
    if (size(img,3) == 3)
        img1 = img(:,:,1);
        img2 = img(:,:,2);
        img3 = img(:,:,3);
    
        neighborhoodBeta = 1/(2 * mean((img1(siteIdx) - img1(nSiteIdx)).^2 + ...
                                           (img2(siteIdx) - img2(nSiteIdx)).^2 + ...
                                           (img3(siteIdx) - img3(nSiteIdx)).^2));
    else
        neighborhoodBeta = 1/(2 * mean(img(siteIdx) - img(nSiteIdx)).^2);

    end
end