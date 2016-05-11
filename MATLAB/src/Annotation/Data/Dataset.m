classdef Dataset < handle
    %DATASET Handles features and machine learning for a set of regions.
    %   Detailed explanation goes here
    
    properties (Access = private)
        dsName % a unique string that identifies this dataset (used a file name for persistence)
        labelDescriptions % a cell array of strings reprensenting the label names
        representations % a cell array of strings reprensenting extractors to instanciate
        extractors % an array containing TextureExtractor objects
        featureMatrices % a cell of featureMatrix objects (one per representations)
    end
    
    properties (Access = public)
        labels % the class labels (0 is unlabeled)
        probabilities % the class-wise probability for each reprensentation
    end
    
    methods (Access = public)
        % Creates an empty dataset from the data of the specified image
        function this = Dataset(image, segmentationMap, representations)
            % instanciate texture feature extractors
            this.representations = representations;
            this.extractors = ExtractorFactory(this.representations);
            
            % extract features using
            for i=numel(this.extractors):-1:1
                featureMatrices{i} = this.extractors{i}.extractFeatures(image,segmentationMap)
            end
            features = extractFeatures(this,image,segmap)
            % NYI
        end
        
        % Loads a previously used dataset
        function this = Dataset(name)
            % NYI
        end
        
        % Set the true label of a given feature entry (region)
        function setLabel(this, idFeature, idLabel)
            % NYI
        end
        
        % Adds all data from the specified "otherDataset" to the current ds
        function appendData(this, otherDataset)
            % NYI
        end
        
        % Launches SVM training. This can be quite computationaly expensive
        % for larger dataset. It is not necessary to build a model if this
        % is an unlabeled dataset for testing (e.g. for a single unlabeled image).
        function rebuildModel(this)
            % NYI
        end
        
        % Predicts labels of the entries from the other dataset, using the
        % model from the current dataset. A model needs to exists before
        % calling this method (i.e. call rebuildModel at least once).
        % The method returns nothing explicitely, but  does not return,
        % but does three things:
        % 1) Computes class probabilities in otherDataset (accessible through a public property)
        % 2) Sets labels in otherDataset to their most likely result
        % 3) sets labelDescription of the new ds to match the training labels
        function predictClasses(this, otherDataset)
            % NYI
        end

        % Adds a new class with the specified name. Its id is returned.
        function id = addClass(this, lassLabel)
            % NYI
        end
        
        % Writes the Data to the hard drive. It can be loaded in the future
        % using "
        function save(this)
            % NYI
        end
    end
    
    methods (Acess = private)
        % Uses the current probabilities to update undefined labels.
        function fusion(this)
            % NYI
        end
        
        % Uses the current probabilities to update undefined labels.
        function this = load(name)
            % NYI
        end
    end
    
end

