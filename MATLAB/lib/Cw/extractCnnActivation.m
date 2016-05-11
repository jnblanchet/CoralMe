function features = extractCnnActivation(x0, x1, y0, y1, image)
    name = 'imagenet-vgg-verydeep-16.mat';
    net = getNet(name);
     
    x0 = max(x0,1); x1 = min(x1,size(image,1));
    y0 = max(y0,1); y1 = min(y1,size(image,2));
    patch = image(x0:x1, y0:y1,:);
    im_ = single(patch) ; % note: 255 range
    im__ = imresize(im_, net.meta.normalization.imageSize(1:2)) ;
    im__ = im__ - net.meta.normalization.averageImage ;

    res = vl_simplenn(net, im__);

    lastConvLayerOut = res(end-2).x;
    features = double(lastConvLayerOut(:));
    features = features / norm(features,2);                           
end

function net = getNet(name)
    persistent loadedNet;
    
    if isempty(loadedNet)
        loadedNet = load(name);
        loadedNet = vl_simplenn_tidy(loadedNet); % repair (old format)
    end
    net = loadedNet;
end