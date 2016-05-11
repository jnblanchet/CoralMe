function optStr = makeLibsvmOptionString(options, weights, labelIndex)

if nargin == 2
    labelIndex = 1 : length(weights);
end

% set weight string
weightstr = [];
for thisClass = 1 : length(weights)
    weightstr = [weightstr '-w', num2str(labelIndex(thisClass)), ' ', num2str(weights(thisClass)), ' ']; %#ok<AGROW>
end

if ~isfield(options, 'type')
    options.type = 2;
end
if ~isfield(options, 'degree')
    options.degree = 2;
end
if ~isfield(options, 'coef0')
    options.coef0 = 0;
end
if ~isfield(options, 'quiet')
    options.quiet = 0;
end

% merge to options string.
optStr = sprintf('-t %d -d %d -g %.4f -r %.4f -c %.4f -b %d %s', options.type, options.degree, exp(options.gamma), options.coef0, exp(options.C), options.prob, weightstr);

if (options.quiet)
    optStr = [optStr '-q '];
end


end
