% load image
f = imread('MLC_demo.JPG');
f = f(150:end-150,150:end-150,:);
f = imresize(f,1000/max(size(f)));
imlab = vl_xyz2lab(vl_rgb2xyz(f)) ;

% extract super pixels
regionSize = 100 ;
regularizer = 200;
segments = vl_slic(single(imlab), regionSize, regularizer,'MinRegionSize',(.5*regionSize)^2) + 1;

% extract texture map
im_g = rgb2gray(f);
[h,w,~] = size(im_g);
samplingPoints = 8; distance = 1;
mapping = LbpMapping(samplingPoints,'riu2');
[~,map] = Lbp(im_g,distance,samplingPoints,mapping); % extract lbp map
lbpMap = imresize(map, [h,w],'nearest');
colorNorm = comprehensiveColorNorm(f); % generate colorMap
hsv = rgb2hsv(colorNorm);
numBins = 10; % numel(uniquemapping)), hard coded for speed
colorMap = uint8(hsv(:,:,1)*(numBins-1));

% extract feature vector for each cell
n = max(segments(:));
features = zeros(n,2*numBins);
weights = zeros(n,1);
for i=1:n
    map = segments == i;
    weights(i) = sum(map(:));
    features(i,1:numBins) = hist(lbpMap(map),0:numBins-1);
    features(i,numBins+1:2*numBins) = hist(colorMap(map),0:numBins-1)';
end

% normalize Features
features = features ./ repmat(max(features),n,1);

% find neighbors 4-connected (to represent as a graph)
isConnected = false(n);
for i = 2:h
    for j = 2:w
        if(segments(i,j) ~= segments(i-1,j))
            isConnected(segments(i,j), segments(i-1,j)) = true;
            isConnected(segments(i-1,j), segments(i,j)) = true;
        end
        if(segments(i,j) ~= segments(i,j-1))
            isConnected(segments(i,j), segments(i,j-1)) = true;
            isConnected(segments(i,j-1), segments(i,j)) = true;
        end
    end
end

% evaluate cost
cost = ones(n) * Inf;
for i = 1:n
    for j = i+1:n
        if isConnected(i,j)
            v = features(i,:);
            u = features(j,:);
            %             cost(i,j) = sum((features(i,:) - features(j,:)).^2);
            cost(i,j) = 1- (sum(v .* u) ./(sqrt(sum(u*u')) .* sqrt(sum(v*v'))));
            cost(j,i) = cost(i,j);
        end
    end
end

% loop cut
index = DisjointSet(n);
segments_k = segments;

while(true)
    [val,id] = min(cost(:));
   % apply cut
    [i,j] = ind2sub([n,n],id);
    cost(i,j) = Inf; cost(j,i) = Inf; % cannot merge anymore!
    display(sprintf('attempting to merge %d with %d with score=%.2f',i,j,log(val)))
    i = index.find(i);
    j = index.find(j);
    i = index.find(i); j = index.find(j);
    newId = index.union(i,j);
    % update cost
    for x=n:-1:1
        % row
        if ~isinf(cost(i,x)) && ~isinf(cost(j,x))
            newRowVal(x) = (cost(i,x) * weights(i) + cost(j,x) * weights(j)) ./ (weights(i) + weights(j));
        elseif isinf(cost(i,x)) && ~isinf(cost(j,x))
            newRowVal(x) = cost(j,x);
        elseif ~isinf(cost(i,x)) && isinf(cost(j,x))
            newRowVal(x) = cost(i,x);
        else
            newRowVal(x) = Inf;
        end
        
        %col
        if ~isinf(cost(x,i)) && ~isinf(cost(x,j))
            newColVal(x) = (cost(x,i) * weights(i) + cost(x,j) * weights(j)) ./ (weights(i) + weights(j));
        elseif isinf(cost(x,i)) && ~isinf(cost(x,j))
            newColVal(x) = cost(x,j);
        elseif ~isinf(cost(x,i)) && isinf(cost(x,j))
            newColVal(x) = cost(x,i);
        else
            newColVal(x) = Inf;
        end
    end
    
    weights(newId) = weights(i) + weights(j);
    cost(newId,:) = newRowVal;
    cost(:,newId) = newColVal;
    % update segment
    segments_k(segments_k == i | segments_k == j) = newId;
    % generate display
    s = size(f);
    labels_rgb = label2rgb(uint8(segments_k),'jet');
    labels_rgb = imresize(labels_rgb,s(1:2),'nearest');
    labels = segments_k;
    labels = ~~abs(imfilter(labels,[-1,-1,-1;-1,8,-1;-1,-1,-1], 'same'));
    % labels = imclose(labels,strel('disk',3));
    labels = imresize(labels,s(1:2));
    labels = imdilate(labels,strel('disk',1));
    contourImage = uint8(zeros(size(f)));
    pos = uint8(~labels);
    neg = uint8(labels);
    for c=1:3
        contourImage(:,:,c) = f(:,:,c) .* pos + labels_rgb(:,:,c) .* neg;
    end
    imshow(contourImage);
    drawnow
    pause(.2);
end