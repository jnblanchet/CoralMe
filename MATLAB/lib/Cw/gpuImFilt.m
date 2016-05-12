function response=gpuImFilt(im, filterBank, gather)
%im: image to process
%filterBank: NxMxD filter bank of D filters
%gather: bool value (return cpu array if false or gpu array if true)

[~,~,f] = size(filterBank);
[h,w,d] = size(im);
imGpu = single(gpuArray(im));
filterResponses = gpuArray(zeros(h,w,d,f));

% apply filters
for n=1:f
    filterResponses(:,:,:,n)=imfilter(imGpu,filterBank(:,:,n));
end
if gather
    response = gather(filterResponses);
else
    response = filterResponses;
end

