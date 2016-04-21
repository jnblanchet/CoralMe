classdef Context < handle
    %CONTEXT a facade that contains data on a single user session.
    %   Detailed explanation goes here
    
    properties (Access = private)
        image
        % Map that contains all instances of all CoralMeTools
        % (needs to be flushed when image is changed)
        CoralMeMap
    end
    
    methods (Access = public)
        function this = Context()
            this.CoralMeMap = containers.Map('KeyType','char','ValueType','any');
        end
        
        function ready = isReady(this)
            ready = true;
        end
                
        function result = handleRequest(this, request)            
            
            % parse classname.method
            split = strsplit(request.method,'.');
            if numel(split) ~= 2
                errorStruct.message = 'Invalid request structure, expected: "ClassName.methodName".';
                errorStruct.code = jsonrpc2.JSONRPC2Error.JSON_INVALID_PARAMS;
                error(errorStruct)
            end
            className = split{1}; method = split{2};

            % get the target class instance (or create one)
            if this.CoralMeMap.isKey(className);
                instance = this.CoralMeMap(className);
            else
%                 try
                    instance = coralMeFactory(this, className);
%                 catch err
%                     errorStruct.message = err.message;
%                     errorStruct.code = jsonrpc2.JSONRPC2Error.JSON_INTERNAL_ERROR;
%                     error(errorStruct)
%                 end
                this.CoralMeMap(className) = instance;
            end
            
            % make sure it's really a method
            if ~ismethod(instance,method);
                errorStruct.message = sprintf('Class "%s" does not support method call "%s".',className,method);
                errorStruct.code = jsonrpc2.JSONRPC2Error.JSON_METHOD_NOT_FOUND;
                error(errorStruct)
            end
            
            % build the command
            % build output
            mc = meta.class.fromName(className);
            mp = findobj(mc.MethodList,'Name',method);
            if isempty(mp.OutputNames)
                out = '';
                result = [];
            else
                out = 'result =';
            end
            % build parameters
            args = request.getParams();
            if numel(args) > 0
                for i=numel(args):-1:1
                    arguments{i} = ['args{' num2str(i) '}'];
                    descr{i} = [class(args{i}) '[' num2str(size(args{i})) ']'];
                end
                arguments = strjoin(arguments,',');
                descr = strjoin(descr,',');
            else
                arguments  = '';
                descr = '';
            end
            
            % invoke it!
%             try
                display(sprintf('Evaluating: "%s.%s(%s)";',className,method,descr));
                command = sprintf('%s instance.%s(%s);',out,method,arguments);
                eval(command); % TODO: find a better way to do this.
%             catch err
%                 errorStruct.message = sprintf('Unable to complete request, MATLAB error:"%s".',err.message);
%                 errorStruct.code = jsonrpc2.JSONRPC2Error.JSON_INTERNAL_ERROR;
%                 error(errorStruct)
%             end
        end
        
        % getters
        function image = getImage(this)
            image = this.image;
        end
        % setters
        function setImage(this, image)
            flushAllObjects(this);
            this.image = image;
        end
    end
    
    methods (Access = private)        
        function flushAllObjects(this)
            this.CoralMeMap = containers.Map('KeyType','char','ValueType','any');
        end
    end
    
end

