function [ssfactor stats] = getSVMssfactor(data, targetNbrSamplesPerClass, classes)
% function [ssfactor stats] = getSVMssfactor(data,
% targetNbrSamplesPerClass)
%
% getSVMfactor calculates the sub sample factor for each category in order
% to achieve a maximum of INPUT targetNbrSamplesPerClass samples per class.
%
%
%  CREDITS
%  Written and maintained by Oscar Beijbom, UCSD
%  Copyright notice: license.txt
%  Changelog: changelog.txt


nbrClasses = length(classes);

% Prepare the train data and model weights.
% find subsamples factors for the train data.
for itt = 1 : nbrClasses
    thisClass = classes(itt);
    stats.nbrTotalSamples(itt) = sum(data.labels == thisClass);
    stats.ssfactor(itt) = max(1, stats.nbrTotalSamples(itt) / targetNbrSamplesPerClass);
    stats.nbrTrainSamples(itt) = stats.nbrTotalSamples(itt) / stats.ssfactor(itt);
end

ssfactor = stats.ssfactor;

end