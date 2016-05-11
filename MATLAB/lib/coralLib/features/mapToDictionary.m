function map = mapToDictionary(I, dictionary)
% function map = mapToDictionary(I, dictionary)
% 
% I is column stacked images, basically formatted to work with pdist2
% mapToDictionary maps INPUT image I to INPUT dictionary using the L2
% distance. pdist2 is part of the Piotr Dollar MATLAB toolbox.
% 
%  CREDITS
%  Written and maintained by Oscar Beijbom, UCSD
%  Copyright notice: license.txt
%  Changelog: changelog.txt

global GlobalUseGpuFlag;
    
map = zeros(size(I, 1), 1);
% divide in 100 parts
P = round(linspace(0, size(I,1), 100));

for i = 2 : length(P)
    thisChunk = I(P(i-1) + 1 : P(i), :);
    if GlobalUseGpuFlag == 1
        dist = pdist2(gpuArray(thisChunk), gpuArray(dictionary), 'sqeuclidean' );
    else
        dist = pdist2(thisChunk, dictionary, 'sqeuclidean' );
    end
    [~,pos] = min(dist, [], 2);
    if GlobalUseGpuFlag == 1
        res = gather(pos);
    else
        res = pos;
    end
    map(P(i-1) + 1 : P(i), :) = res;
end

end