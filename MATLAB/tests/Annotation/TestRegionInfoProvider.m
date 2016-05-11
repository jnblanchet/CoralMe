map = zeros(300,'uint16');

map(1:150,1:150) = 1;
map(1:150,151:300) = 2;
map(151:300,1:150) = 3;
map(151:300,151:300) = 4;
map(120:192,35:110) = 4;

segMap = SegmentationMap();
segMap.setMap(map);

%% CONSTRUCTOR
fprintf('Creating RegionInfoProvider... ');
error = false;
try
a = RegionInfoProvider(segMap);
catch
    error = true;
end
if error
    fprintf('FAILED\n');
else
    fprintf('PASSED\n');
end

%% getCenters
fprintf('Calling getGoodRegionCenters... ');
error = false;
try
    c = a.getGoodRegionCenters();
catch
    error = true;
end
if error
    fprintf('FAILED\n');
else
    fprintf('PASSED\n');
end

%
fprintf('Expecting centers matrix size to be 3 x 2... ');
error = false;
c = a.getGoodRegionCenters();
if ~isequal(size(c),[numel(1:max(map(:))-1),2])
    error = true;
end

if error
    fprintf('FAILED\n');
else
    fprintf('PASSED\n');
end

%
fprintf('Expecting last region to have a center around position .75, .75 ... ');
error = false;
c = a.getGoodRegionCenters();
eps = .01;
if norm(c(3,:) - [.75,.75]) > eps
    error = true;
end

if error
    fprintf('FAILED\n');
else
    fprintf('PASSED\n');
end

%
fprintf('Expecting colors from the legend to be the right ones ... ');
colorLegend = a.getRegionColors();
segMap.get
