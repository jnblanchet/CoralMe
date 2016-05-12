f = imread('Mushroom Coral by Brocken Inaglory.JPG');
f = imresize(f,0.25);
segMap = SegmentationMap();
segMap.setMap(imread('Mushroom Coral segmentation.bmp'));

representations = {'TextonExtractor','ClbpExtractor','CnnActivationExtractor'};

%% CONSTRUCTOR
fprintf('Creating Dataset from an image... ');
error = false;
% try
    a = Dataset(f,segMap,representations);
% catch
%     error = true;
% end

if(numel(a.labels) ~= 2)
    error = true;
end

if error
    fprintf('FAILED\n');
else
    fprintf('PASSED\n');
end



%
fprintf('Saving dataset... ');
error = false;
try
    a.save('ThisIsTheTestDataset');
catch
    error = true;
end

if error
    fprintf('FAILED\n');
else
    fprintf('PASSED\n');
end

%
fprintf('Reloading dataset... ');
error = false;
% try
    b = Dataset('ThisIsTheTestDataset');
% catch
%     error = true;
% end

if error
    fprintf('FAILED\n');
else
    fprintf('PASSED\n');
end

% try building Dataset again with 3 classes
%% CONSTRUCTOR
fprintf('Creating Dataset no background class (0)... ');
error = false;
segMap.setMap(segMap.getMap() + 1);
try
    a = Dataset(f,segMap,representations);
catch
    error = true;
end

if(numel(a.labels) ~= 3)
    error = true;
end

if error
    fprintf('FAILED\n');
else
    fprintf('PASSED\n');
end

%
fprintf('Create two new classes ... ');
error = false;
try
    a.addNewLabel('Algae');
    a.addNewLabel('Soft Coral');
catch
    error = true;
end

if(numel(a.labelDescriptions) ~= 2)
    error = true;
end

if error
    fprintf('FAILED\n');
else
    fprintf('PASSED\n');
end

% 
fprintf('Manually setting ground truth labels... ');
error = false;
try
    a.setLabel(1, 2);
    a.setLabel(2, 1);
catch
    error = true;
end

if error
    fprintf('FAILED\n');
else
    fprintf('PASSED\n');
end


% 
fprintf('Training models... ');
error = false;
try
    a.rebuildModel();
catch
    error = true;
end

if error
    fprintf('FAILED\n');
else
    fprintf('PASSED\n');
end

% 
fprintf('Getting predictions... ');
error = false;
try
    a.predictClasses(b);
catch
    error = true;
end

if(sum(b.labels == 0) > 0) % make sure all labels were assigned
    error = true;
end

if error
    fprintf('FAILED\n');
else
    fprintf('PASSED\n');
end

% 
fprintf('Merging two datasets... ');
error = false;
try
    a.appendData(b);
catch
    error = true;
end

if(sum(b.labels == 0) > 0) % make sure all labels were assigned
    error = true;
end

if error
    fprintf('FAILED\n');
else
    fprintf('PASSED\n');
end


