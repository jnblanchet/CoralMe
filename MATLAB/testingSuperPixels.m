% load image
f = imread('MLC_demo.JPG');
f = f(150:end-150,150:end-150,:);
f = imresize(f,1000/max(size(f)));
imlab = vl_xyz2lab(vl_rgb2xyz(f)) ;

% extract super pixels
regionSize = 200 ;
regularizer = 400 ;
segments = vl_slic(single(imlab), regionSize, regularizer) + 1;

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

for i=1:n
    features(i,1:numBins) = hist(lbpMap(segments == i),0:numBins-1);
    features(i,numBins+1:2*numBins) = hist(colorMap(segments == i),0:numBins-1)';
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
cost = zeros(n);
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

% create index
[val,id] = sort(cost(:));
map = val~=0;
val = val(map);
id = id(map);
index = DisjointSet(n);

% generate display (iterative cuts)
segments_k = segments;
for k = 1:numel(id)
    % apply cut
    [i,j] = ind2sub([n,n],id(k));
    i = index.find(i);
    j = index.find(j);
    newId = index.union(i,j);
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