function Iout = coralPreProcess(I, params)
% function Iout = coralPreProcess(I, params)
%
% coralPreProcess process INPUT image I using INPUT parameter struct:
% params.
%
%
%  CREDITS
%  Written and maintained by Oscar Beijbom, UCSD
%  Copyright notice: license.txt
%  Changelog: changelog.txt

Iout = I;
[~,~,d] = size(I);
switch params.type
    case 'none'
        
        
    case 'eachColorchannelStretch'
        for i = 1:d
            Iout(:,:,i) = imadjust(I(:,:,i), stretchlim(I(:,:,i),[params.low params.high]));
        end
        
    case 'intensitystretchRGB'
        I = double(I);
        I = I ./ 255;
        lowHigh = stretchlim(I(:), [params.low params.high]);
        I(I > lowHigh(2)) = lowHigh(2);
        I = I - lowHigh(1);
        I(I<0) = 0;
        Iout = I / max(I(:));
        
        
end
end

