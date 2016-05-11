function weightstr = makeLibsvmWeightString( weights )
    labelIndex = 1 : length(weights);

    % set weight string
    weightstr = [];
    for thisClass = 1 : length(weights)
        weightstr = [weightstr '-w', num2str(labelIndex(thisClass)), ' ', num2str(weights(thisClass)), ' ']; %#ok<AGROW>
    end
end

