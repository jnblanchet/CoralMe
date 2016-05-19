ds = Dataset();
dsTs = Dataset();

ds.representations = {'TextonExtractor'};
dsTs.representations = ds.representations;

% trMap = true(1,size(data,1),'logical');
% trMap(1:10:size(data,1)) = false;

for i=numel(ds.representations):-1:1
    if i == 3
        ds.featureMatrices{i} = cell2mat(data(:,i)')';
%         dsTs.featureMatrices{i} = cell2mat(data(~trMap,i)')';
    else
        ds.featureMatrices{i} = cell2mat(data(:,i));
%         dsTs.featureMatrices{i} = cell2mat(data(~trMap,i));
    end
end

ds.labelDescriptions = labelNames;
ds.labels = labels(:);

ds.rebuildModel();

% ds.predictClasses(dsTs);

ds.save('mlc2008_200PerClass_textons')

% [conf,rate]=confmat(lbl,labels(~trMap));
% imagesc(conf)
% colorbar()
% title(num2str(rate))

% ds.save('mlc2008_200PerClass_fusion2')