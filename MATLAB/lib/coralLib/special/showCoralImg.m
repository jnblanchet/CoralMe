function showCoralImg(I, labelMatrix)
% function showCoralImg(I, labelMatrix)
%
% plots image with annotaitons overlaid.
% 
%  CREDITS
%  Written and maintained by Oscar Beijbom, UCSD
%  Copyright notice: license.txt
%  Changelog: changelog.txt

% set some parameters
ppParams.type = 'none';
plotParams.colors = 'bcgrrgbcm';
plotParams.markers = '^^^^ooooo';
plotParams.sizes = [5 5 5 5 5 5 5 5 5];


rowCol = labelMatrix(:, 1:2); % row and col coordinates
gtLabels = labelMatrix(:, 3); % grount truth labels

imagesc(coralPreProcess(I, ppParams));
axis off; axis image; hold on;

% plot dummy stuff for the legend to work...
for tt = 1: 9
    plot(1,1, plotParams.markers(tt), 'MarkerEdgeColor', plotParams.colors(tt));
end
legend({'CCA', 'Turf', 'Macro', 'Sand', 'Acrop', 'Pavon', 'Monti', 'Pocill', 'Porit'});

% plot the actual markers.
for ii = 1 : size(rowCol, 1)
    plot(rowCol(ii, 2), rowCol(ii, 1), plotParams.markers(gtLabels(ii)), 'Markersize', plotParams.sizes(gtLabels(ii)), 'MarkerEdgeColor', plotParams.colors(gtLabels(ii)), 'LineWidth', 3);
end

end