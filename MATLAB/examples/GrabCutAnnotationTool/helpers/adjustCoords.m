function [ x0,y0,x1,y1 ] = adjustCoords( roi, size)
% fits an roi region (e.g. from getrect()) into an image to avoid out of
% bound. Returns values are expressed as relative position [0,1].
    x0 = min(max(1,roi(2)),size(1)) / size(1);
    y0 = min(max(1,roi(1)),size(2))/ size(2);
    x1 = min(max(1,roi(2)+roi(4)),size(1)) / size(1);
    y1 = min(max(1,roi(1)+roi(3)),size(2)) / size(2);
end