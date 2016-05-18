function extractors = extractorFactory(textureRepresentations)
    %CORALMEFACTORY creates a cell array of concrete texture feature
    % extractor instances.
        % in:   textureRepresentations a cell array containing the names of
        % the extractors to create. See below for options. At least 1
        % extractor is required.
        % out:  a cell array of extractor objects.
        
        extractors = cell(numel(textureRepresentations),1);
        for i = numel(textureRepresentations):-1:1
            switch textureRepresentations{i}
                case 'TextonExtractor'
                    extractors{i} = TextonExtractor(); 
                case 'ClbpExtractor'
                    extractors{i} = ClbpExtractor();
                case 'CnnActivationExtractor'
                    extractors{i} = CnnActivationExtractor();
                otherwise
                    error('The ExtractorFactory can''t create the requested extractor.')
            end
        end
end