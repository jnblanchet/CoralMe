% controls:
% esc = exit (cursor must be on image)
% left mouse = select nearest blob
% right mouse = new blob
% c = copy selected blob to this position
% r = resize selected blob to this size
% d = delete selected blob


%% load image, prepare selector
% f = imread('AIMS_demo.JPG');
% f = imresize(f,500/max(size(f)));
f = imread('MLC_demo.JPG');
f = imresize(f,750/max(size(f)));
selector = SmartRegionSelector(f);
imshow(f);

%% endless loop, press esc to exit
selectedId = 0;
while(true)
    
    [y,x,button]=ginput(1);

    if( button == 27)
        break;
    elseif (button == 3)
        % create a new blob and select it
        selectedId = selector.createBlob(x,y);
    elseif (button == 1)
        % find closest blob and select it
        minDist = Inf;
        for b = 1:numel(selector.Blobs)
            if  ~isempty(selector.Blobs{b})
                dist = norm(selector.Blobs{b}.getPos() - [x,y]);
                if dist < minDist
                    minDist = dist;
                    selectedId = b;
                end
            end
        end
    elseif (button == 99) % c: copy
        if selector.isValidBlobId(selectedId)
            selectedId = selector.copyBlobToLocation(selectedId, x, y);
        end
    elseif (button == 100) % d: delete
        if selector.isValidBlobId(selectedId)
            selector.deleteBlob(selectedId);
        end
    elseif (button == 114) % r: resize
        if selector.isValidBlobId(selectedId)
            newSize = round(norm(selector.Blobs{selectedId}.getPos() - [x,y]));
            selector.resizeBlobRegion(selectedId, newSize);
        end
    end

    contourImage = selector.getMap();
    if selector.isValidBlobId(selectedId)
        pos = selector.Blobs{selectedId}.getPos();
        contourImage = insertMarker(contourImage,[pos(2) pos(1)], 'o','color','green','size',5);
%         insertMarker(contourImage,pos,'x','color','green','size',100);
%         contourImage = insertShape(contourImage, 'FilledRectangle', [pos(2) pos(1) 20 20], 'LineWidth', 10);
    end
    imshow(f .* uint8(~contourImage(:,:,[4 4 4])) + contourImage(:,:,1:3) .* contourImage(:,:,[4 4 4]));
    drawnow
    
    %     imageHandle = get(gca,'Children');
    %     set(imageHandle ,'CData',contourImage);
    %     drawnow;
end

