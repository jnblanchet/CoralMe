function [ train, test, params ] = normalize( mode, train, test, params)
%NORMALIZE normalize the data train and test according to mode.
%supported modes: musigmat (mu = 0, sigma = 1), minmax: min=0 max=1

if nargin <= 4 || isempty(params) % set normalizing params if needed
    params = [];
    switch mode
        case 'minmax'
            for a = 1:size(train,2);
                params.normalizer(1,a) = max(max(train(:,a)),eps);
                params.offset(1,a) = min(train(:,a));
            end
        case 'musigma'
            for a = 1:size(train,2);
                params.meanFeatures = mean(train(:,a));
                params.stdFeatures = max(std(train(:,a)),eps);
            end
    end
end

if(nargin <= 2)
    test = [];
end

switch mode
    case 'L1'
        for a = 1:size(train,1);
            train(a,:) = train(a,:) ./ sum(train(a,:));
        end
        if(~isempty(test))
            for a = 1:size(test,1);
                test(a,:) = test(a,:) ./ sum(test(a,:));
            end
        end
    case 'minmax'
        for a = 1:size(train,2);
            train(:,a) = (train(:,a) - params.offset(a)) ./ (params.normalizer(a) - params.offset(a) + eps);
            if(~isempty(test))
                test(:,a) = (test(:,a) - params.offset(a)) ./ (params.normalizer(a) - params.offset(a) + eps);
            end
        end
    case 'musigma'
        for a = 1:size(train,2);
            train(:,a) = (train(:,a) - params.meanFeatures) ./ params.stdFeatures;
            if(~isempty(test))
                test(:,a) = (test(:,a) - params.meanFeatures) ./ params.stdFeatures;
            end
        end
    case 'signbinary'
        train = sign(train);
        train(train == -1) = 0;
        if(~isempty(test))
            test = sign(test);
            test(test == -1) = 0;
        end
    case 'sign'
        train = sign(train);
        if(~isempty(test))
            test = sign(test);
        end
end

end

