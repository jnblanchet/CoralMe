f = imread('Mushroom Coral by Brocken Inaglory.JPG');
[h,w,~] = size(f);
%% CONSTRUCTOR
fprintf('Creating GabCut... ');
error = false;
try
a = GrabCut(f);
catch
    error = true;
end
if error
    fprintf('FAILED\n');
else
    fprintf('PASSED\n');
end

%% Set image
fprintf('Changing image... ');
error = false;
try
    a.setImage(f);
catch
    error = true;
end
if error
    fprintf('FAILED\n');
else
    fprintf('PASSED\n');
end


%% extracting ROI
fprintf('Extracting ROI...');
error = false;
newMap = [];
try
    a.setRoi(112/h,1/w,346/h,105/w);
    newMap = a.getLabelMap();
catch
    error = true;
end
if error || numel(unique(newMap)) ~= 2;
    fprintf('FAILED\n');
else
    fprintf('PASSED\n');
end

%% extracting another ROI
fprintf('Extracting another ROI...');
error = false;
try
    a.setRoi(62/h,53/w,748/h,787/w);
catch
    error = true;
end
if error || numel(unique(a.getLabelMap())) ~= 3;
    fprintf('FAILED\n');
else
    fprintf('PASSED\n');
end

%% changing current ROI's base region
fprintf('Changing ROI base region...');
error = false;
try
    a.defineForegroundRectangle(327/h,366/w,407/h,434/w);
catch
    error = true;
end
if error || numel(unique(a.getLabelMap())) ~= 3;
    fprintf('FAILED\n');
else
    fprintf('PASSED\n');
end

%% removing last region
fprintf('Removing last region...');
error = false;
try
    a.removeLastRegion();
catch
    error = true;
end
if error || numel(unique(a.getLabelMap())) ~= 2;
    fprintf('FAILED\n');
else
    fprintf('PASSED\n');
end

%% removing last region
fprintf('Clicking a pixel to delete that region...');
error = false;
try
    a.removeRegionAtPoint(174/h,27/w);
catch
    error = true;
end
if error || numel(unique(a.getLabelMap())) ~= 1;
    fprintf('FAILED\n');
else
    fprintf('PASSED\n');
end