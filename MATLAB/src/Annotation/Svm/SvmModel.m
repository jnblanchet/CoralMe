classdef SvmModel < handle
    % handles an SVM models
    
    properties (Access = public)
        model % LIBSVM's struct
    end
    
    methods (Access = public)
        function this = SvmModel()
        end
        
        % builds a model using the specified features
        function model = train(this, features, labels)
            classLabels = unique(labels);
            % normalize data
            features(isnan(features)) = 0; % eliminate any possible extraction errors.
            [ features, ~, this.model.normalizer ] = normalize( 'minmax', features);
            
            data.features = features;
            data.labels = labels;
            
            % get weights
            w = getSVMssfactor(data, min(2000,max(hist(labels,1:numel(classLabels)))), classLabels); % a few samples per class is quite enough for training
%             data = subsampleDataStruct(data, w);
            
            model = trainSimpleSVM(data, w, numel(classLabels));
            this.model.svm = model;
        end
        
        % tests the specified data on the model (must call train first)
        function probabilities = test(this, features)
            [ features, ~, ~ ] = normalize( 'minmax', features, [], this.model.normalizer);
            
            [~, ~, probEstimates] = svmpredict(zeros(size(features,1),1), features, this.model.svm, '-b 1');
            
            removedClasses = true(this.model.svm.nr_class,1);
            removedClasses(this.model.svm.Label) = false;
            [~,reOrderIds] = sort([this.model.svm.Label',find(removedClasses)']);
            probabilities = probEstimates(:,reOrderIds);
        end
        
    end
    
end