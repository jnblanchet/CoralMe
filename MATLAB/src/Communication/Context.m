classdef Context < handle
    %CONTEXT contains data on a single user session.
    %   Detailed explanation goes here
    
    properties (Access = private)
        image
        resizeFactor
        resizedImage
        regionMap
        kernelSize
        
        % Map that contains all instances of all CoralMeTools
        % (needs to be flushed when image is changed)
        CoralMeMap
    end
    
    methods (Access = public)
        function this = Context()
            this.CoralMeMap = containers.Map('KeyType','char','ValueType','any');
        end
        
        function result = handleRequest(this, request)
            % get the target clss instance (or create one)
            split = strsplit(request.method,'.');
            className = split{1}; method = split{2};
            if this.CoralMeMap.isKey(className);
                instance = this.CoralMeMap(className);
            else
                instance = coralMeFactory(this, className);
                this.CoralMeMap(className) = instance;
            end
            
            % make sure it's really a method
            if ~ismethod(instance,method);
                error('Class %s does not have a method "%s".')
            end
            
            % build the command
            mc = meta.class.fromName(className);
            mp = findobj(mc.MethodList,'Name',method);
            if isempty(mp.OutputNames)
                out = '';
                result = [];
            else
                out = 'result ='
            end
            args = request.getParams();
            for i=1:numel(args)
                arguments{i} = ['args{' num2str(i) '}'];
            end
            arguments = strjoin(arguments,',');
 
            command = sprintf('%s instance.%s(%s)',out,method,arguments);
            
            eval(command); % TODO: find a better way to do this.
        end

        % getters
        function resizeFactor = getResizeFactor(this)
            resizeFactor = this.resizeFactor;
        end
        
        function segmentationMap = getSegmentationMap(this)
            segmentationMap = [];
        end
        
        function segmentationOverlay = getSegmentationOverlay(this)
            segmentationOverlay = [];
        end
        
        function resizedImage = getResizeImage(this)
            resizedImage = this.resizedImage;
        end
        
        function kernelSize = getKernelSize(this)
            kernelSize = this.kernelSize;
        end
        
        % setters
        function setImage(this, image)
            this.image = image;
            if(isempty(this.resizeFactor))
                this.resizeFactor = min(1,750 / max(size(image))); % default size
            end
            this.resizeImage();
        end
        
        function setKernelSize(this, kernelSize)
            this.kernelSize = kernelSize;
        end
        
        function setResizeFactor(this,resizeFactor)
            this.resizeFactor = resizeFactor;
        end
    end
    
    methods (Access = private)
        function requiresImage(this)
            if isEmpty(this.image)
                error('Image has not yet been set. Call Context.setImage(image) first.');
            end
        end
        
        % resize Image
        function resizeImage(this)
            % TODO: replace imresize to remove image processing toolbox
            % dependency
            this.resizedImage = imresize(this.image ,this.resizeFactor);
        end
        
        function flushAllObjects(this)
            
        end
    end
    
end

