function instance = coralMeFactory(context, className)
    %CORALMEFACTORY creates an instance of a CoralMe class.
        % For security purposes (XSS, code injections), these are the only
        % objects that can be queried remotely (RPC).
        % For this reason, any extension to the API need to be added here.
        % in:   context (Context class) that contains useful parameters
        %       className a char array containing the name of the class
        % out:  a new instance of the requested class.
        
        switch className
            case 'Context'
                instance = context;
            case 'SmartRegionSelector'
                requiresImage(context);
                instance = SmartRegionSelector(context.getImage(), context.segMap);
            case 'SuperPixelExtractor'
                requiresImage(context);
                instance = SuperPixelExtractor(context.getImage(), context.segMap);
            case 'GraphCutMergeTool'
                requiresSegmentationMap(context);
                instance = GraphCutMergeTool(context.segMap);
            otherwise
                error('coralMeFactory.m does not allow this class to be created.')
        end
end

function requiresImage(context)
    if isempty(context.getImage())
        error('Image has not yet been set. Call Context.setImage(image) first.');
    end
end

function requiresSegmentationMap(context)
    if isempty(context.segMap)
        error('Image has not yet been segmented. Use other tools first (e.g. SuperpixelExtractor).');
    end
end