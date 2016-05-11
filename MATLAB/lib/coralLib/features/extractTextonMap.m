function textonMap = extractTextonMap(featureParams, featurePrep, I)
% function textonMap = extractTextonMap(featureParams, featurePrep, I)
%
% extractTextonMap filters INPUT image I using coralApplyFilterWrapper. It
% then map the filtered image to a textonmap using textons defined in INPUT
% featurePrep.
%
%
%  CREDITS
%  Written and maintained by Oscar Beijbom, UCSD
%  Copyright notice: license.txt
%  Changelog: changelog.txt

% set local structs.
textons = mergeCellContent(featurePrep.textons(1, :));
totalNbrChannels =  size(textons, 2);

% filter image
if(size(I,3) == 1)
    img = I(:,:,[1 1 1]);
else
    img = I;
end
FIallChannels = coralApplyFilterWrapper(img, featureParams, featurePrep.filterMeta, totalNbrChannels);

% create texton map
[nbrRows nbrCols nbrDims] = size(FIallChannels);
FIallChannels = reshape(FIallChannels, nbrRows * nbrCols, nbrDims);

textonMap = mapToDictionary(FIallChannels, textons);

textonMap = reshape(textonMap, nbrRows, nbrCols, 1);


end