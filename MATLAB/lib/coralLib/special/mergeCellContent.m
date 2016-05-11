function matrixOut = mergeCellContent(cellIn)
% merge cell content to one matrix.
%
%
%  CREDITS
%  Written and maintained by Oscar Beijbom, UCSD
%  Copyright notice: license.txt
%  Changelog: changelog.txt

matrixOut = [];
for i = 1:length(cellIn)
    matrixOut  = [matrixOut ; cellIn{i}]; %#ok<AGROW>
end

end