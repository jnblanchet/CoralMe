function model = trainSimpleSVM(trainData, trainingWeights, nClasses, optC, optG)
%TRAINSIMPLESVM trains a model with model selection. (one-against-one)
% input:
%   * trainData: a struct containing .features and .labels
%   * testData: a struct containing .features and .labels
%   * trainingWeights: an array of size classCount containing training weights
%   * nClasses: nClasses the number of classes in the dataset
% output:
%   * model: the model.


    valTrW = getSVMssfactor(trainData, 200, 1:nClasses);
    valData = subsampleDataStruct(trainData, valTrW);
    if(nargin <= 4)
        % optimise hyperparameters
        [optC, optG] = cwGridSearchSVM(valData.features,valData.labels, valTrW);
    end
    
    % set the options string for the classifier.
    params = struct(); params.gamma = optG; params.C = optC;
    params.prob = 1; params.quiet = 1;
    optStr = makeLibsvmOptionString(params, trainingWeights);

    % Train classifier
    model = svmtrain(trainData.labels, trainData.features, optStr);