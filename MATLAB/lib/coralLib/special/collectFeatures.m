function all_features = collectFeatures(dataDir, fileNbrs, d)
% function all_features = collectFeatures(dataDir, fileNbrs)
%
% collectFeatures collect feature files with INPUT fileNbrs from INPUT dataDir
% feature files are assumed to have names data[fileNbr].mat.
%
%
%  CREDITS
%  Written and maintained by Oscar Beijbom, UCSD
%  Copyright notice: license.txt
%  Changelog: changelog.txt

temp = load(fullfile(dataDir, sprintf('data%d.mat', fileNbrs(1))));

F = rowVector(fields(temp.data));

nSamplesPerFile = round(numel(temp.data.labels) * 1.5); %hedge a bit if the first file is super small.
nFiles = numel(fileNbrs);
all_features.features = zeros(nSamplesPerFile * nFiles, d, 'single');
all_features.labels = zeros(nSamplesPerFile * nFiles, 1);
all_features.fromfile = zeros(nSamplesPerFile * nFiles, 1);
all_features.rowCol = zeros(nSamplesPerFile * nFiles, 2);
all_features.pointNbr = zeros(nSamplesPerFile * nFiles, 1);

pos = 0;

for itt = 1 : length(fileNbrs)
    fileNbr = fileNbrs(itt);
    filepath = fullfile(dataDir, sprintf('data%d.mat', fileNbr));
    fprintf(1, 'Collecting file %s\n', filepath);
    
    temp = load(filepath);
    these_features = temp.data;
    nbrSamples = length(these_features.labels);
    
    for f = F
        all_features.(f{1})(pos + 1: pos + nbrSamples, :) = these_features.(f{1});
    end
    pos = pos + nbrSamples;
end

F = rowVector(fields(all_features));
for f = F
    all_features.(f{1}) = all_features.(f{1})(1 : pos, :);
end

end