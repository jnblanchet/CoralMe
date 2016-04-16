function [ textureMap ] = computeTextureMap( image, kernelSize)
%COMPUTETEXTUREMAP returns a 20 channel map consisting in 10 LBP bins and
%10 hue histogram bins.

im_g = rgb2gray(image);
[h,w,~] = size(im_g);
samplingPoints = 8; distance = 1;
mapping = LbpMapping(samplingPoints,'riu2');

% Extract lbp map
[~,map] = Lbp(im_g,distance,samplingPoints,mapping);
lbpMap = imresize(map, [h,w],'nearest');

% Generate colorMap
colorNorm = comprehensiveColorNorm(image);
hsv = rgb2hsv(colorNorm);
numBins = 10; % numel(uniquemapping)), hard coded for speed
colorMap = uint8(hsv(:,:,1)*(numBins-1));

% Extract pixel-wise local feature vector (using a disk kernel)
r=kernelSize;cx=r+1;cy=r+1;ix=r*2+1;iy=r*2+1;
[xx,yy]=meshgrid(-(cx-1):(ix-cx),-(cy-1):(iy-cy));
mask=double((xx.^2+yy.^2)<=r^2);
newD = numel(unique(mapping(:))) + numBins;

% check for gpu availability
try
    d = gpuDevice;
    OK = d.SupportsDouble;
catch
    OK = false;
end

% run on either gpu or cpu
if(OK) % gpu
    textureMap = gpuArray(zeros(h,w,newD));
    for i=1:10 % lbp
        textureMap(:,:,i) = imfilter(gpuArray(double(lbpMap == (i-1))),mask);
    end
    for i=11:20 % color
        textureMap(:,:,i) = imfilter(gpuArray(double(colorMap == (i-11))),mask);
    end
    textureMap = gather(textureMap);
else % cpu
    textureMap = zeros(h,w,newD);
    for i=1:10 % lbp
        textureMap(:,:,i) = imfilter(double(lbpMap == (i-1)),mask);
    end
    for i=11:20 % color
        textureMap(:,:,i) = imfilter(double(colorMap == (i-11)),mask);
    end
end

end

