function [subSampleRate, scale] = standardSSrate(imheight_cm, nrows)


thisPixelCmRatio = nrows / imheight_cm;

TARGET_PIXEL_CM_RATIO = 17.2;

subSampleRate = thisPixelCmRatio / TARGET_PIXEL_CM_RATIO;

scale = log2(subSampleRate) + 1;




end