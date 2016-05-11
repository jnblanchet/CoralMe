function dataOut = subsampleDataStruct(dataIn, ssfactor)
% function dataOut = subsampleDataStruct(dataIn, ssfactor)
%
% subsampleDataStruct subsamples each field of INPUT dataIn so that
% each class gets subsamples by INPUT ssfactor.
%
%  CREDITS
%  Written and maintained by Oscar Beijbom, UCSD
%  Copyright notice: license.txt
%  Changelog: changelog.txt

classes = unique(dataIn.labels);
nbrClasses = length(classes);

% subsample dataOut and labels
dataOut = dataIn;
for thisField = rowVector(fieldnames(dataOut))
   dataOut.(thisField{1}) = []; 
end

for itt = 1 : nbrClasses
    thisClass = classes(itt);
    for thisField = rowVector(fieldnames(dataOut))
        temp.(thisField{1}) = dataIn.(thisField{1})(dataIn.labels == thisClass, :);
        indexes = round(1 : ssfactor(itt) : size(temp.(thisField{1}), 1));
        dataOut.(thisField{1}) = [dataOut.(thisField{1}); temp.(thisField{1})(indexes, :)];
    end
end

end