ds = Dataset();
dsTs = Dataset();

ds.representations = {'TextonExtractor'} %, 'ClbpExtractor'};
dsTs.representations = ds.representations;

trMap = true(1,size(data,1),'logical');
trMap(2:10:size(data,1)) = false;

for i=numel(ds.representations):-1:1
    if i == 3
        ds.featureMatrices{i} = cell2mat(data(trMap,i)')';
        dsTs.featureMatrices{i} = cell2mat(data(~trMap,i)')';
    else
        ds.featureMatrices{i} = cell2mat(data(trMap,i));
        dsTs.featureMatrices{i} = cell2mat(data(~trMap,i));
    end
end

ds.labelDescriptions = labelNames;
ds.labels = labels(trMap);

ds.rebuildModel();

ds.predictClasses(dsTs);

labels(trMap)

sum(dsTs.labels == labels(~trMap)') / numel(dsTs.labels == labels(~trMap)')

% ds.save('mlc2008_200PerClass_fusion2')