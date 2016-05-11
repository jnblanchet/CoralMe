f = imread('Mushroom Coral by Brocken Inaglory.JPG');
segMap = SegmentationMap();
segMap.setMap(imread('Mushroom Coral segmentation.bmp'));
%% CONSTRUCTOR
fprintf('Creating UnassignedPixelRefinement... ');
error = false;
try
a = UnassignedPixelRefinement(f,segMap);
catch
    error = true;
end
if error
    fprintf('FAILED\n');
else
    fprintf('PASSED\n');
end

%% MAIN FUNCTIONALITY
fprintf('Attempting to call assignFreePixels... ');
error = false;
try
    newMap = a.assignFreePixels(1.0);
catch
    error = true;
end
if error
    fprintf('FAILED\n');
else
    fprintf('PASSED\n');
end

fprintf('Checking if result seems good for obvious pixels... ');
error = false;

newMap = a.assignFreePixels(0.25);
m = a.segMap.getMap();
if(m(666,313) ~= m(400,400))
    error = true;
end

if error
    fprintf('FAILED\n');
else
    fprintf('PASSED\n');
end
