% This is a GrabCut assisted annotation tool for fast image annotation.
% 2016 Jean-Nicola Blanchet
% http://www.CoralMe.xyz/
% GrabCut is a segmentation algorithm proposed by Y.Boykov and
% V.Kolmogorov. It assumes there are two groups within a region of
% interest: a foreground and a background. We apply it here iteratively to
% segmente multiple regions of interests.
%
% Dependencies:
% MATLAB's Image Processing Toolbox
% 
% Quick start:
% 1) Browse to the CoralMe\MATLAB folder.
% 2) Make sure to add all other folders to you MATLAB path: addpath(genpath(pwd))
% 3) If you're not running windows 64 bit or mac OS 64 bit, you'll need to
% compile the graph cut library using \lib\BkGraphCuts\BK_BuildLib.m
% 4) Define the following parameters to your needs (see below).
% 5) Hit F5 to run the application

% TODO:
% 1) refine segmentation
% 2) select a label
% 3) delete last region
% 4) delete selected region
% 5) save result to jpg file.
function main()
    clear; clc; % clear memory and console output.

    %% Parameters
    inputImagesDir = ['.' filesep 'examples' filesep  'GrabCutAnnotationTool' filesep 'input'];
    imagesFormat = '*.tif';
    outputDir = ['.' filesep 'examples' filesep  'GrabCutAnnotationTool' filesep 'output'];

    Labels = {'Coral', 'Algae', 'Others'}; % add more labels here. The resulting annotation will be saved using the IDs of these classes (1,2,3,...)
    grabCutRegularizerFactor = 10; % higher = smoother borders
    
    %% Initialization
    images = dir([inputImagesDir filesep imagesFormat]);
    instructions = {...
        'Press S to re-specify (explicitly) seed region (to describe object of interest).'...
        'Press F to refine by selecting FOREGROUND pixels (force pixel into foreground).'...
        'Press B to refine by selecting BACKGROUND pixels (force pixel into background).'...
        'Press Enter to segment a new region.'...
        'Press ESC to remove last region.'...
        'Press A to Proceed to annotation.'...
        'Press T to remove region at specified point.'...
        }';
        AnnotationLUT = []; % this is the annotation map (contains label ids)
    %% Main program
    for image = images' % loop through all images 
        f = imread([inputImagesDir filesep image.name]);
        grabCutContext = GrabCut(f);
        grabCutContext.setRegularizer(grabCutRegularizerFactor)
        f_resized = grabCutContext.getResizeImage(); % grabCut uses a smaller image for performance reasons. This by be adjusted using "grabCut.setResizeFactor(1)";
        resultOverlay = selectROI(f_resized,grabCutContext);
        % step (1) SEGMENTATION
        userIsDone = false; % this is set to true once the user is ready for annotation
        reshow = true; % this is set to false when we don't want to show the image again (update) between two operations
        while (~userIsDone) % loop while user wants to perform more segmentation operations on this image.
            if(reshow)
                showOverlay(f_resized,resultOverlay);
                title({'Initial segmentation (best guess). Press H for help.'});
                fig = gcf;
            end
            waitforbuttonpress();
            reshow = true;
            switch fig.CurrentCharacter
                case 'h' % show instructions
                    msgbox(instructions);
                    reshow = false; % don't reshow the image, nothing changed
                case 's' % allow the re-selection of the seed area
                    resultOverlay = selectForegroundRectangle(f_resized,grabCutContext);
                case 'f' % add foreground constraint
                    refineRegion(f_resized,grabCutContext,true);
                    resultOverlay = grabCutContext.getMap();
                case 'b' % add background constraint
                    refineRegion(f_resized,grabCutContext,false);
                    resultOverlay = grabCutContext.getMap();
                case 't' % remove region at selected point
                    removeAtPoint(grabCutContext);
                    resultOverlay = grabCutContext.getMap();
                case 'a' % end segmentation
                    userIsDone = true;
                case 27 % escape
                    grabCutContext.removeLastRegion();
                    resultOverlay = grabCutContext.getMap();
                case 13 % enter
                    resultOverlay = selectROI(f_resized,grabCutContext);
            end
        end
        
        % step (2) ANNOTATION
        AnnotationLUT = zeros(size(f_resized,1),size(f_resized,2),'uint8');
        resultOverlay = grabCutContext.getMap();
        segmentationMap = grabCutContext.getLabelMap();
         while (true) % loop util the user presses enter
            preview = previewAnnotation(f_resized,AnnotationLUT,numel(Labels));
            
            showOverlay(preview,resultOverlay);
            title({'Hover the mouse over a region, and use digits keys to select a class. Press L for labels. Enter to finish.'});
            [y,x,button] = ginput(1);
            
            if isempty(button) % pressing enter returns and empty set
                break;
            end
            
            switch button
                case 'h' % show instructions
                    msgbox([{['Classes 1 to ' num2str(numel(Labels))]} Labels {'(or 0 for background)'}]);
                otherwise
                    v = button - '0'; % convert to integer from 1 to 9
                    if v >= 0 && v < 9 % artificial limit. This should be changed if there are more classes added.
                        id = segmentationMap(round(x),round(y));
                        AnnotationLUT(id == segmentationMap) = v;
                    end
            end
         end
        
        % step (3) SAVE and proceed to next image.
        imwrite(AnnotationLUT,[outputDir filesep image.name])
    end
end



%% GUI operations.
function resultOverlay = selectROI(f,gcc)
    imshow(f);
    title('\color{blue}Drag click (hold left mouse down and move) to select a rectangular region containing the entire object of interest.')
    roi = getrect(); % returns [x,y,width,height]
    [x0,y0,x1,y1] = adjustCoords( roi, size(f));
    resultOverlay = gcc.setRoi(x0, y0, x1, y1); % returns RGB-A overlay
end

function resultOverlay = selectForegroundRectangle(f,gcc)
    title('\color{red}Drag click (hold left mouse down and move) to select a rectangular region containing mostly pixels in the object of interest.')
    roi = getrect(); % returns [x,y,width,height]
    [x0,y0,x1,y1] = adjustCoords( roi, size(f));
    resultOverlay = gcc.defineForegroundRectangleFullImageCoords(x0, y0, x1, y1); % returns RGB-A overlay
end


function refineRegion(f,gcc, isForeground)
    title('Use drag click to select a forground region.');
    roi = getrect(); % returns [x,y,width,height]
    [x0,y0,x1,y1] = adjustCoords( roi, size(f));
    if(isForeground)
        gcc.addForegroundHardConstraints(x0,y0,x1,y1);
    else
        gcc.addBackgroundHardConstraints(x0,y0,x1,y1);
    end
end

function removeAtPoint(gcc)
    title('Select a region to remove.');
    [y,x] = ginput(1);
    gcc.removeRegionAtPoint(x,y);
end

function fusedImage = previewAnnotation(f,indexMap,numClasses)
    fusedImage = zeros(size(f,1),size(f,2),size(f,3));
    fusedImage(:,:,1) = double(indexMap) ./ numClasses;
    fusedImage(:,:,2) = 1.0;
    fusedImage(:,:,3) = indexMap > 0;
    fusedImage = uint8((double(f)*3 + (255 * hsv2rgb(fusedImage)))/4);
end

function showOverlay(f,resultOverlay)
    for c=1:3
        f(:,:,c) = uint8(~resultOverlay(:,:,4)) .* f(:,:,c) + resultOverlay(:,:,c) .* resultOverlay(:,:,4);
    end
    imshow(f)
end

% hFig=figure('Position',[200 200 1600 600]);
%       movegui(hFig,'center') 
% uicontrol('Parent',hFig,'Style','pushbutton','String','View Data','Units','normalized','Position',[0.0 0.5 0.4 0.2],'Visible','on');