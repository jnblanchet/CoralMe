f = imread('Mushroom Coral by Brocken Inaglory.JPG');

%% CONSTRUCTOR
fprintf('Creating SuperPixelExtractor... ');
error = false;
try
a = SuperPixelExtractor(f);
catch
    error = true;
end
if error
    fprintf('FAILED\n');
else
    fprintf('PASSED\n');
end

%% Set image
fprintf('Setting a new image with no arguments... ');
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


%% extracting superpixels
fprintf('Extracting superpixels...');
error = false;
try
    a.getMap();
catch
    error = true;
end
if error
    fprintf('FAILED\n');
else
    fprintf('PASSED\n');
end

%%
fprintf('Extracting superpixels with custom parameters...');
error = false;
try
    
    a.setResizeFactor(1.0);
    a.setRegionSize(150);
    a.setRegularizer(200);
    m = a.getMap();
catch
    error = true;
end
if error
    fprintf('FAILED\n');
else
    fprintf('PASSED\n');
end