f = imread('Mushroom Coral by Brocken Inaglory.JPG');
f = imresize(f,0.25); % it's a bit big

%% CONSTRUCTOR
fprintf('Creating SmartRegionSelector with no arguments... ');
error = false;
try
    a = SmartRegionSelector([]);
    error = true; % should fail!
catch
end
if error
    fprintf('FAILED\n');
else
    fprintf('PASSED\n');
end

%%
fprintf('Creating SmartRegionSelector... ');
try
    a = SmartRegionSelector(f);
    fprintf('PASSED\n');
catch 
    fprintf('FAILED\n');
end

%%
fprintf('Checking if texture map size is correct... ');
if isequal(size(a.TextureMap), [size(f,1),size(f,2),20])
    fprintf('PASSED\n');
else
    fprintf('FAILED\n');
end

%% BLOBS
fprintf('Adding Blob... ');
id = a.createBlob(125,100);
pos = a.Blobs{id}.getPos;
if a.Blobs{id}.getId == id && pos(1) == 125 && pos(2) == 100
    fprintf('PASSED\n');
else
    fprintf('FAILED\n');
end

%%
fprintf('Moving Blob... ');
a.moveBlob(id,100,115);
pos = a.Blobs{id}.getPos;
if pos(1) == 100 && pos(2) == 115
    fprintf('PASSED\n');
else
    fprintf('FAILED\n');
end

%%
fprintf('Copying Blob... ');
newBlobId1 = a.copyBlobToLocation(id, 150, 100);
if numel(a.Blobs) == 2 && a.Blobs{id}.getGroupId == a.Blobs{newBlobId1}.getGroupId
    fprintf('PASSED\n');
else
    fprintf('FAILED\n');
end

%% 
fprintf('Copying Blob to new position... ');
newBlobId2 = a.copyBlobToLocation(id, 140, 65);
pos = a.Blobs{newBlobId2}.getPos;
if a.Blobs{id}.getGroupId == a.Blobs{newBlobId2}.getGroupId && pos(1) == 140 && pos(2) == 65
    fprintf('PASSED\n');
else
    fprintf('FAILED\n');
end

%% 
fprintf('Deleting Blob... ');
a.deleteBlob(newBlobId1);
if isempty(a.Blobs{newBlobId1})
    fprintf('PASSED\n');
else
    fprintf('FAILED\n');
end

%% 
fprintf('Resizing Blob region... ');
a.resizeBlobRegion(id, 50);
if isempty(a.Blobs{newBlobId1})
    fprintf('PASSED\n');
else
    fprintf('FAILED\n');
end

%%
fprintf('Segmenting coral region... ');
try
    a.resizeBlobRegion(id, 50);
    a.resizeBlobRegion(a.copyBlobToLocation(id, 100, 75),25);
    a.resizeBlobRegion(a.copyBlobToLocation(id, 140, 100),100);
    contour = a.getMap();
    % imshow(contourImage);
    fprintf('PASSED\n');
catch
    fprintf('FAILED\n');
end
