function [features, cache] = extractClbpWithColor(x0, x1, y0, y1, mask, image, imageName, cache)
% Check number of colors for image
[~, ~, nChannels] = size(image);
% Lbp Params
samplingPoints = 8; distance = 1;
mapping = ClbpMapping(samplingPoints,'riu2');

if isempty(cache) || isempty(cache.lastImage) || strcmp(cache.lastImage,imageName) ~= 1
    % grayscale image
    if(nChannels > 1)
        cache.imgG = rgb2gray(image);
    else
        cache.imgG = image;
    end
    % LBP
    clbpIn = double(cache.imgG);
    %     clbpIn= (clbpIn-mean(clbpIn(:)))/std(clbpIn(:))*20+128; % image normalization, to remove global intensity
    
    [cache.LbpMap_S,cache.LbpMap_M,cache.LbpMap_C] = Clbp(clbpIn,distance,samplingPoints,mapping,'x');
    cache.LbpMap_S = imresize(cache.LbpMap_S, size(cache.imgG),'nearest');
    cache.LbpMap_M = imresize(cache.LbpMap_M, size(cache.imgG),'nearest');
    cache.LbpMap_C = imresize(cache.LbpMap_C, size(cache.imgG),'nearest');
    
    cache.imCN = comprehensiveColorNorm(image);
end
patchRows = x0:x1;
patchCols = y0:y1;
patch = image(patchRows,patchCols,:);

%% initialization
% Compute Gray level image
if (nChannels == 3)
    patchGray = cache.imgG(patchRows,patchCols);
else
    patchGray = patch;
end

if(isempty(mask))
    mask = true(size(patchGray));
end
if(~islogical(mask))
    mask = logical(mask);
end


%% CLBP FILTERING
clbpS = cache.LbpMap_S(patchRows,patchCols);
clbpM = cache.LbpMap_M(patchRows,patchCols);
clbpC = cache.LbpMap_C(patchRows,patchCols);

histS = hist(clbpS(:),0:mapping.num-1);
clbpMC = clbpC .* mapping.num + clbpM;
histMC = hist(clbpMC(:),0:mapping.num*2-1);
histS = histS ./ sum(histS(:));
histMC = histMC ./ sum(histMC(:));

%% Color features: Hue Hist and Opponent angle
if(nChannels > 1)
    number_of_bins = 16;
    
    patchCN = cache.imCN(patchRows,patchCols,:);
    
    [h,w,~] = size(patchCN);
    patchCountH = ceil(h ./ 20); % patches are hardcoded to 20x20 in this library
    patchCountW = ceil(w ./ 20);
    
    c_R = imresize(patchCN(:,:,1), [patchCountH*20,patchCountW*20]);
    c_G = imresize(patchCN(:,:,2), [patchCountH*20,patchCountW*20]);
    c_B = imresize(patchCN(:,:,3), [patchCountH*20,patchCountW*20]);
    c_mask = imresize(mask, [patchCountH*20,patchCountW*20],'nearest');
    
    isValid = false(patchCountH,patchCountW);
    %% check if the subpatch is mostly masked
    for j=1:patchCountW
        for i=1:patchCountH
            col_s = (i-1) * 20 + 1;
            col_e = i * 20;
            row_s = (j-1) * 20 + 1;
            row_e = j * 20;
            subMask = c_mask(col_s:col_e,row_s:row_e);
            if(sum(sum(subMask)) / numel(subMask) > .5)
                isValid(i,j) = true;
            end
        end
    end
    
    noValid = sum(sum(isValid));
    patches_R = zeros(400,noValid);
    patches_G = zeros(400,noValid);
    patches_B = zeros(400,noValid);
    
    idx = 1;
    for j=1:patchCountW
        for i=1:patchCountH
            if(isValid(i,j))
                col_s = (i-1) * 20 + 1;
                col_e = i * 20;
                row_s = (j-1) * 20 + 1;
                row_e = j * 20;
                patches_R(:,idx) = reshape(c_R(col_s:col_e,row_s:row_e),[400,1]);
                patches_G(:,idx) = reshape(c_G(col_s:col_e,row_s:row_e),[400,1]);
                patches_B(:,idx) = reshape(c_B(col_s:col_e,row_s:row_e),[400,1]);
                idx = idx + 1;
            end
        end
    end
    
    hueDesc = hueDescriptor(patches_R,patches_G,patches_B,number_of_bins);
    hueDesc = sum(hueDesc,2);
    hueDesc = hueDesc' ./ (eps+sum(hueDesc(:)));
    OADesc = opponentDescriptor(patches_R,patches_G,patches_B,number_of_bins);
    OADesc = OADesc(:,~isnan(sum(OADesc,1))); % remove NaN's
    OADesc = sum(OADesc,2);
    OADesc = OADesc' ./ (eps+sum(OADesc(:)));
    
end
features = [histS,histMC, hueDesc, OADesc];

cache.lastImage = imageName;
end