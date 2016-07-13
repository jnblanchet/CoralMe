function [objPDF, bkgPDF] = getPDF(image, objectMask)

if(size(image,1) ~= size(objectMask,1) || size(image,2) ~= size(objectMask,2))
    error('The specified image and the mask should have exactly the same MxN size.');
end

Nbins = 32; % number of bins per component (e.g. RGB= NxNxN)
histAlpha = 1e-6; % minimum probability per bin

if(max(image(:)) > 1.0)
    image = double(image) ./ 255;
end

objectMask_ = reshape(objectMask,[],1,1);
pixelList_ = squeeze(reshape(image,[],1,3));
pixelList = ceil(pixelList_*Nbins);
pixelList(pixelList==0) = 1;

n = sum(sum(objectMask == 0));
M_background = hist4(pixelList(~objectMask_,:), Nbins)/(n);
M_background = (1-histAlpha) * M_background + histAlpha*(1/(Nbins^03));

n = sum(sum(objectMask == 1));
M_foreground = hist4(pixelList(objectMask_,:), Nbins)/(n);
M_foreground = (1-histAlpha) * M_foreground + histAlpha*(1/(Nbins^03));


%Calcul des termes de regions pour chaque pixel

objPDF = -log(reshape(M_foreground(sub2ind(size(M_foreground),pixelList(:,1),pixelList(:,2),pixelList(:,3))),size(image,1),size(image,2)));
bkgPDF = -log(reshape(M_background(sub2ind(size(M_background),pixelList(:,1),pixelList(:,2),pixelList(:,3))),size(image,1),size(image,2)));

% penalize the sides (always bkg)
% w = max(max(objPDF(:)),max(bkgPDF(:)));
% b = min(min(objPDF(:)),min(bkgPDF(:)));
% objPDF(1,:) = w; objPDF(end,:) = w; objPDF(:,1) = w; objPDF(:,end) = w;
% bkgPDF(1,:) = b; bkgPDF(end,:) = b; bkgPDF(:,1) = b; bkgPDF(:,end) = b;
