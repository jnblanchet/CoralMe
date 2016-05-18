classdef AnnotationManager < handle
    %ANNOTATIONMANAGER Annotation facade for remote calls
    % This class follows a "Facade"-like design and handles all machine
    % learning-related remote calls directed at the Annotation package.
    % However, all classes part of the Annotation package can be used
    % directly when working in MATLAB. The facade can also be extended to
    % support new functionalities.
    
    properties (Access = public)
        context
        datasets
        tmpDataset
        textureRepresentationsToUse
    end
    
    methods (Access = public)
        function this = AnnotationManager(context)
            this.context = context;
            this.datasets = containers.Map('KeyType','char','ValueType','any');
        end
        
        % Returns the names of the existing dataset on hard drive.
        function dsNames = listDatasets(this)
            dsOnDrive = dir('./datasets/*.mat');
            for i=numel(dsOnDrive):-1:1
                dsNames{i} = dsOnDrive(1).name(1:end-4); % remove extension
            end
        end
        
        function setReprensentationsToUse(this,varargin)
            % expecting multiple arguments of type char array here
            this.textureRepresentationsToUse = varargin;
        end
        
        % Loads a Dataset with the specified name.
        function loadDataset(this,name)
            ds = Dataset(name);
            this.datasets(name) = ds;
            this.textureRepresentationsToUse = ds.representations;
        end
        
        % Build a temporary dataset (using the current image and
        % segmentation)
        function buildTmpDataset(this)
            img = this.context.getImage();
%             for i=3:-1:1
%                 img(:,:,i) = histeq(img(:,:,i));
%             end
%             img = imresize(img,0.5); % for performance!
            this.tmpDataset = Dataset(img, this.context.segMap, this.textureRepresentationsToUse);
        end
        
        % Trains the model with the specified name, or the current model of
        % no name is specified.
        function trainModel(this,name)
            if(nargin > 1 || isempty(name))
                this.datasets(name).rebuildModel();
            else
                this.tmpDataset.rebuildModel();
            end
        end
        
        % Predicts the scores and updates the labels of the specified
        % testDataset. If testDs is omited, or empty, the current temp
        % working dataset is used instead.
        function scores = predictClasses(this, trainDsName, testDsName)
            if(nargin < 2 || isempty(testDsName))
                testDs = this.tmpDataset;
            else
                testDs = this.datasets(testDsName);
            end
            
            trainDs = this.datasets(trainDsName);
            
            trainDs.predictClasses(testDs)
            scores = testDs.scores;
            scores = scores - min(scores(:));
            scores = scores ./ max(scores(:));
            scores = uint8(floor(scores * 95)); % return some nice round integers (precision is irrelevant for user)
        end
        
        % Appends a dataset to another. Both must use the same texture
        % representations (features) and the labels used in the other
        % dataset must be a subset of the labels in the original dataset.
        function appendData(this,trainDsName, otherDsName)
            if(nargin < 2 || isempty(testDsName))
                otherDs = this.tmpDataset;
            else
                otherDs = this.datasets(otherDsName);
            end
            trainDs = this.datasets(trainDsName);
            
            trainDs.appendData(otherDs)
        end
        
        function newId = addClass(this,name,classLabel)
            if(nargin < 2 || isempty(name))
                newId = this.tmpDataset.addNewLabel(classLabel);
            else
                this.datasets(name).addNewLabel(classLabel);
            end
        end
        
        function labels = getLabelDescriptions(this,name)
            if(nargin < 2 || isempty(name))
                labels = this.tmpDataset.labelDescriptions;
            else
                labels = this.datasets(name).labelDescriptions;
            end
        end
        
        function setLabel(this, name, idRegion, idLabel)
            if(nargin < 2 || isempty(name))
                ds = this.tmpDataset;
            else
                ds = this.datasets(name);
            end
            ds.setLabel(idRegion, idLabel);
        end
        
        
    end
end

