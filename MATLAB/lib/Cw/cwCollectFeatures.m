function all_features = cwCollectFeatures(featureDir, prefix, idRange)
%CWCOLLECTFEATURES Feature collection method. Based on CoralLib code. This
% new version is supposed to be easier to read and maintain. It Includes
% validation to ensure all files contain an identical feature count.
% - featureDir: the path where the features were extracted
% - prefix: the prefix of the files to collect, i.e. data_<prefix>_<no>.mat
% - idRange: an array that contains the ids to collect
%
% Files must contain a structure that includes the label and the features.
%

% determine feature vector size
n = 0;
d = 0;
for i = 1:numel(idRange)
    fileNo = idRange(i);
    filepath = fullfile(featureDir, ['data_' prefix '_' num2str(fileNo) '.mat']);
    if ~exist(filepath,'file')
        display(sprintf('Warning - file "%s" not found. Skipping...',filepath));
        continue;
    end
    load(filepath) 
        
    if ~exist('fields','var')
        fields = fieldnames(data);
        fields = fields(~cellfun(@isempty, strfind(fields,'features')));
    end
    
    n = n + size(data.(fields{1}),1);
end

d = zeros(1,numel(fields));
for f = 1:numel(fields)
    d(f) = d(f) + size(data.(fields{f}),2);
end

% Initiating result
all_features = struct();
for f = 1:numel(fields)
    all_features.(fields{f}) = zeros(n,d(f));
end
all_features.labels = zeros(n,1);
idPatch = 1;

% Iterating through files
for i = 1:numel(idRange)
    fileNo = idRange(i);
    filepath = fullfile(featureDir, ['data_' prefix '_' num2str(fileNo) '.mat']);

    if ~exist(filepath,'file')
        continue;
    end
    
    load(filepath)
    numP = numel(data.labels);
    range = idPatch:idPatch + numP-1;
    for f = 1:numel(fields)
        if(size(data.(fields{f}),1) ~= numP)
            error(['File ' filepath 'does not have matching labels and feature count.']);
        end
        all_features.(fields{f})(range,:) = data.(fields{f});
    end
    all_features.labels(range) = data.labels;
    idPatch = idPatch + numP;
end

end