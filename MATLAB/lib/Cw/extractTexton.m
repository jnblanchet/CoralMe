function [features, cache] = extractTexton(x0,x1,y0,y1, mask, image, imageName, cache)
%EXTRACTTEXTON extracts a texton feature vector on the specified image.
% The function extracts the texton map for an entire image, and returns the
% texton feature vector for the specified patch location on the image (with
% a custom segmentation map optionally). It can use GPU acceleration (set
% global variable GlobalUseGpuFlag to 1.
%
% input:
%   * x0: the top bound of the patch of interest.
%   * x1: the bottom bound of the patch of interest.
%   * y0: the left bound of the patch of interest.
%   * y1: the right bound of the patch of interest. (x,y) indexing
%   * mask: an optional binary map describing the region to use (empty to
%   use the whole patch [])
%   * image: the image to use.
%   * imageName: the image name, used to cache texture map to speed up
%   multiple quries on the same patch. You can bypass this feature by
%   passing your patch as the image parameter, and querying a single patch
%   that covers the entire image.
% output:
%   * features : the texton feture vector.


%% Cache stuff for speedup
    persistent dict; % cache for speedup
    
    if isempty(dict)
        dict = load('BeijbomTextonDictionary');
    end
        
    % cache map
    if isempty(cache) || isempty(cache.lastImage) || strcmp(cache.lastImage,imageName) ~= 1
        s = min(2E6 / (size(image,1) * size(image,2)),1);
        im_ = imresize(image,s);
        im__ = imPad( im_, 50, 'symmetric');
        textons = extractTextonMap(dict.featparam, dict.featprep, im__);
        textons_ = imPad( textons, -50, 'replicate');
        cache.textonMap = imresize(textons_,[size(image,1),size(image,2)],'nearest');
    end


    x0 = max(x0,1);
    y0 = max(y0,1);
    x1 = min(x1,size(cache.textonMap,1));
    y1 = min(y1,size(cache.textonMap,2));
    patch = cache.textonMap(x0:x1, y0:y1);
    
    if(isempty(mask))
        features = hist(patch(:), 1 : dict.featparam.totalTextons);
    else
        features = hist(patch(mask), 1 : dict.featparam.totalTextons);
    end

    features = features ./ sum(features);

    cache.lastImage = imageName;
end