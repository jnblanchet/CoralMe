classdef RemoteCallServer < matWebSocketServer
    %REMOTECALLSERVER handles client requests (parsing, encoding, etc.)
    
    properties (Access = private)
        ContextMap
    end
    
    methods
        function this = RemoteCallServer(port)
            %Constructor
            this@matWebSocketServer(port);
            this.ContextMap = containers.Map('KeyType','double','ValueType','any');
        end
    end
    
    methods (Access = protected)
        function onOpen(this,message,conn)
            display(['New connection was accepted: ' message]);
            this.ContextMap(conn.hashCode) = Context();
        end
        
        function onMessage(this,message,conn)
            % parse request();
%             try
                request = jsonrpc2.JSONRPC2Request.parse(message);
%             catch
%                 response = jsonrpc2.JSONRPC2Error( 0, jsonrpc2.JSONRPC2Error.JSON_PARSE_ERROR,'unable to parse json from last request!');
%                 this.send(conn,response.toJSONString());
%             end
            
            % decode arguments();
%             try
                request.params.params = this.decodeArguments(request.params.params);
%             catch
%                 response = jsonrpc2.JSONRPC2Error( 0, jsonrpc2.JSONRPC2Error.JSON_PARSE_ERROR,'unable to decode arguments!');
%                 this.send(conn,response.toJSONString());
%             end
            
            
            % handle request
            context = this.ContextMap(conn.hashCode);
%             try
                result = context.handleRequest(request);
%             catch err
%                 if(~isfield(err,'code'))
%                     code = jsonrpc2.JSONRPC2Error.JSON_INTERNAL_ERROR;
%                 else
%                     code = err;
%                 end
%                 response = jsonrpc2.JSONRPC2Error( 0, code,err.message);
%                 this.send(conn,response.toJSONString());
%             end
            
            % send response if needed
%             try
                if ~request.isNotification()
                    response = jsonrpc2.JSONRPC2Response( request.id, this.encodeArguments(result) );
                    json_response = response.toJSONString();
                    this.send(conn,json_response);
                end
%             catch err
%                 response = jsonrpc2.JSONRPC2Error( 0, jsonrpc2.JSONRPC2Error.JSON_INTERNAL_ERROR, sprintf('Unable to send response, MATLAB error: "%s".',err.message));
%                 this.send(conn,response.toJSONString());
%             end
        end
        
        function onError(this,message,conn)
            display(['Recieved an error from client: ' message]);
        end
        
        function onClose(this,message,conn)
            display(['Closing connection: ' message]);
            this.ContextMap.remove(conn.hashCode);
        end
    end
    
    methods (Access = private)
        
        % decode images into matlab matrices
        function argsOut = decodeArguments(this, argsIn)
            argsOut = cell(size(argsIn));
            for i = 1:numel(argsIn)
                if ischar(argsIn{i}) && strcmp(argsIn{i}(1:10),'data:image')
                    split = strsplit(argsIn{i},',');
                    header = upper(split{1});
                    image = split{2};
                    image = base64decode(image);
                    % find format
                    fmt = {'JPEG','JPG','PNG','BMP','CUR','PPM','GIF','PBM','RAS','HDF4','PCX','TIFF','ICO','PGM','XWD'};
                    for j=1:numel(fmt)
                        if ~isempty(strfind(header,['/' fmt{j}]))
                            break;
                        end
                    end
                    argsOut{i} = imdecode( image, fmt{j});
                    
                else
                    argsOut{i} = argsIn{i};
                end
            end
        end
        
        % encode the image argument in base64 URL format
        function argOut = encodeArguments(this, argIn)
            [h,w,d] = size(argIn);
            if h >=2 && w >= 2 && d == 3 % this is an image.
                body64 = base64encode(imencode( argIn, 'JPEG'));
                argOut = strcat('data:image/jpeg;base64,', body64);
            else
                argOut = argIn;
            end
        end
    end
end

