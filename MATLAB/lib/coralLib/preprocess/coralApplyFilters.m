function filterReponse = coralApplyFilters(I, filterMeta)
% function FIC = coralApplyFilters(I, filterMeta)
%
% coralApplyFilters uses fft_filt_2 to filter an intensity image
% with filters specified in INPUT struct filterMeta.
%
%  CREDITS
%  Written and maintained by Oscar Beijbom, UCSD
%  Copyright notice: license.txt
%  Changelog: changelog.txt

persistent useGpuFlag;

if(isempty(useGpuFlag))
    try
        gpuDevice;
        useGpuFlag = true;
    catch
        useGpuFlag = false;
    end
end

F = filterMeta.F;
Fids = filterMeta.Fids;
nbrOriented = filterMeta.nbrOriented * 2;
nbrCircular = filterMeta.nbrCircular * 2;
nbrFilters = nbrOriented + nbrCircular;

if useGpuFlag == 1
    FI = gpuImFilt(I,F, false);
else
    FI = fft_filt_2(I, F, 1);
end

tmp = zeros(size(FI, 1), size(FI, 2), nbrFilters);
if useGpuFlag == 1
    FIC = gpuArray(tmp);
else
    FIC = tmp;
end

for r = rowVector(unique(Fids))
    ind = Fids == r;
    if (sum(ind) > 1)
        thisFI = abs(FI(:,:,ind));
        FIC(:,:,r) = max(thisFI, [], 3);
    else
        FIC(:,:,r) = FI(:,:,ind);
    end
end

% normalize according to Fowles.
L = sqrt(sum(FIC.^2, 3));
FIC = FIC.*repmat(log(1 + L./.03) ./ L, [1 1 size(FIC, 3)]);
if useGpuFlag == 1
    filterReponse = gather(FIC);
else
    filterReponse = FIC;
end

end


