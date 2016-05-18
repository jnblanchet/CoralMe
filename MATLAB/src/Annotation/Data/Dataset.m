classdef Dataset < handle
    %DATASET Handles features and machine learning for a set of regions.
    %   Detailed explanation goes here
    
    properties (Access = public)
        dsName % a unique string that identifies this dataset (used a file name for persistence)
        representations % a cell array of strings reprensenting extractors to instanciate
        extractors % an array containing TextureExtractor objects
        featureMatrices % a cell of featureMatrix objects (one per representations)
    end
    
    properties (Access = public)
        labelDescriptions % a cell array of strings reprensenting the label names
        labels % the class labels (0 is unlabeled)
        svmScores % the class-wise probability for each reprensentation
        scores % the score output (post fusion) for each region and class
        svmModels % the SvmModels objects (one per representation)
        trainingInProgress; % resource protection (only 1 training at a time)
    end
    
    methods (Access = public)
        % Creates an empty dataset from the data of the specified image.
        % two possible signatures:
        % Dataset(name) % loads a dataset with the specified name
        % Dataset(image, segmentationMap, representations) % creates a new dataset from the specified image.
        function this = Dataset(arg1, segmentationMap, representations)
            if(nargin == 1)
                loadedAttributes = this.reLoad(arg1); % this is the name
                fieldNames = fieldnames(loadedAttributes);
                for i = 1:size(fieldNames,1)
                    this.(fieldNames{i}) = loadedAttributes.(fieldNames{i});
                end
            elseif(nargin == 3)
                segmentationMap.fixIds(); % fix ids just in case
                % instanciate texture feature extractors
                this.representations = representations;
                this.extractors = extractorFactory(this.representations);
                
                % extract features using
                for i=numel(this.extractors):-1:1
                    this.featureMatrices{i} = this.extractors{i}.extractFeatures(arg1, segmentationMap);
                end
                this.labels = zeros(size(this.featureMatrices{1},1),1);
            end
            this.trainingInProgress = false;
        end
        
        % Set the true label of a given feature entry (region)
        function setLabel(this, idRegion, idLabel)
            % todo check if indexing is correct here:
            this.labels(idRegion) = idLabel;
            
            for i=1:numel(this.representations)
                this.svmScores(idRegion,:,i) = 0;
                this.svmScores(idRegion,idLabel,i) = 1.0; % now 100% certainty
            end
        end
        
        % Adds all data from the specified "otherDataset" to the current ds
        function appendData(this, otherDataset)
            % Check that all labels from the otherDataset are part of this
            % dataset and convert them using a LUT
            u = unique(otherDataset.labels);
            lblConverter = zeros(1,u(end));
            for i = 1:numel(u)
                otherLbl = otherDataset.labelDescriptions{u};
                indx = strfind(this.labelDescriptions,otherLbl);
                index = find(not(cellfun('isempty', indx)));
                if(isempty(index))
                    error('Cannot merge: labels in otherDs are not part of labels in this dataset. Add them first!');
                end
                lblConverter(u) = index;
            end
            
            % match representations
            u = numel(otherDataset.representations);
            extractrOrder = zeros(1,u);
            for i = 1:u
                indx = strfind(this.representations,otherDataset.representations{i});
                index = find(not(cellfun('isempty', indx)));
                if(isempty(index))
                    error('Cannot merge: the texture representations are not the same.');
                end
                extractrOrder(i) = index;
            end
            % merging process:
            % 1) featureMatrices
            for i = 1:numel(this.featureMatrices)
                this.featureMatrices{extractrOrder(i)} = [ ...
                    this.featureMatrices{extractrOrder(i)};
                    otherDataset.featureMatrices{i};
                ];
            end
            % 2) labels
            this.labels = [this.labels; lblConverter(otherDataset.labels)];

            % 3) featureMatrices
            for i = 1:numel(this.featureMatrices)
                this.featureMatrices{extractrOrder(i)} = [ ...
                    this.featureMatrices{extractrOrder(i)};
                    otherDataset.featureMatrices{i};
                ];
            end
        end
        
        % Launches SVM training. This can be quite computationaly expensive
        % for larger dataset. It is not necessary to build a model if this
        % is an unlabeled dataset for testing (e.g. for a single unlabeled image).
        % If training is already in progress in another thread, call will
        % have no effect.
        function rebuildModel(this)
            if(~this.trainingInProgress)
                this.trainingInProgress= true;
                validMap = (this.labels > 0); % only known labels can be used for training
                for i=numel(this.representations):-1:1
                    this.svmModels{i} = SvmModel();
                    this.svmModels{i}.train(this.featureMatrices{i}(validMap,:), this.labels(validMap));
                end
                this.trainingInProgress = false;
            end
        end
        
        % Predicts labels of the entries from the other dataset, using the
        % model from the current dataset. A model needs to exists before
        % calling this method (i.e. call rebuildModel at least once).
        % The method returns nothing explicitely, but  does not return,
        % but does three things:
        % 1) Computes class svmScores in otherDataset (accessible through a public property)
        % 2) Sets labels in otherDataset to their most likely result
        % 3) sets labelDescription of the other ds to match the training labels
        function predictClasses(this, otherDataset)
            if(numel(this.svmModels) == 0)
                error('There are no svm models for this dataset. Use rebuildModel().');
            end
            
            for i=numel(this.svmModels):-1:1
                otherDataset.svmScores(:,:,i) = this.svmModels{i}.test(otherDataset.featureMatrices{i});
            end
            otherDataset.labelDescriptions = this.labelDescriptions;
            otherDataset.fusion(); % this updates labels
            
        end
        
        % Adds a new class with the specified name. Its id is returned.
        function id = addNewLabel(this, classLabel)
            this.labelDescriptions{end+1} = classLabel;
            id = numel(this.labelDescriptions);
        end
        
        % Writes the Data to the hard drive. It can be loaded in the future
        % using "
        function save(this, name)
            if(nargin > 1 && ~isempty(name))
                this.dsName = name;
            elseif isempty(this.dsName)
                error('No name was specified while attempting to save the dataset.')
            end
            matFile = this.nameToMatFile(this.dsName);
            
            dsName = this.dsName;
            labelDescriptions = this.labelDescriptions;
            representations = this.representations;
            featureMatrices = this.featureMatrices; %TODO: this could be lazy loading in the future
            labels = this.labels;
            svmModels = this.svmModels;
            save(matFile,'dsName','labelDescriptions', 'representations', 'featureMatrices', 'labels', 'svmModels');
        end
    end
    
    methods (Access = private)
        % Uses the current svmScores to update undefined labels.
        function fusion(this)
            n = size(this.svmScores,1);
            
            for i = n:-1:1 % for each classified region
                if(numel(this.labels) < i || this.labels(i) == 0)
                    tmp = reshape(this.svmScores(i,:,:),[],size(this.svmScores,3),1);
                    this.scores(i,:) = log(prod(tmp,2)+eps);
                    [~,this.labels(i)] = max(this.scores(i,:));
                end
            end
            
        end
        
        % Uses the current svmScores to update undefined labels.
        function this = reLoad(this,name)
            matFile = this.nameToMatFile(name);
            dataFolder = 'datasets';
            if ~exist([dataFolder filesep name '.mat'],'file');
                error('The specified dataset was not found.');
            end
            this = load(matFile);
            % NOTE: if feature extraction on new image is supported in the
            % future (outside of the constructor), extractors will have to
            % be re-instanciated here.
        end
        
        function matFile = nameToMatFile(this, name)
            dataFolder = 'datasets';
            if ~exist(dataFolder,'dir')
                mkdir(dataFolder);
            end
            matFile = [dataFolder filesep name '.mat'];
        end
    end
    
end

