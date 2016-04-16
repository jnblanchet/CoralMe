% Represents a JSON-RPC 2.0 request. 
%
% Copyright (c) 2014, Cornell University, Lab of Ornithology
% All rights reserved.
%
% Distributed under BSD license.  See LICENSE_BSD.txt for full license.
%
% DEPENDS ON:
% 1.  jsonlab
%
% author: E. L. Rayle (elr37 at cornell)
% date: 01/22/2014
%
% NOTE: Interface design based on Java implementation by The Transaction Company.
%       http://software.dzhuvinov.com/json-rpc-2.0-base.html
%       http://software.dzhuvinov.com/files/jsonrpc2base/javadoc/index.html

classdef JSONRPC2Request < jsonrpc2.JSONRPC2Message

    properties
        id;       % The request identifier (Number, Boolean, String) for Requests.  Empty string for Notifications.
        method;   % The name of the requested method to run.
        params;   % The parameters (named or positional) to send to the request method.
    end

  
% =============================================================================
%                             Constructor Methods
% =============================================================================
    methods
    
        function this = JSONRPC2Request(id, method, varargin )
            % Constructor for JSONRPC2Request class.
            %
            %    Input:  
            %        id:        (string) id identifying this request
            %        method:    (string) method to call  
            %        params:    (ParamsRetriever) parameters to pass to method
            %
            %    Output:
            %        new instance of this class
    
            % -------------------------------------
            %  check for invalid number of arguments
            % -------------------------------------
            numvarargs = length(varargin);
            if( numvarargs > 1 )
                exception = MException('Parameter:TooMany','Too many parameters sent to JSONRPC2Request constructor.  2 or 3 supported.' );
                throw(exception);
            end

            % -------------------------------------
            %  check for required parameters
            % -------------------------------------
            if( ~exist('id','var') || ~exist('method','var') )
                exception = MException('Parameter:Missing','Missing one of required parameters: ''id'' and/or ''method''.');
                throw(exception);                
            end
            if( ~ischar(id) && ~isnumeric(id) )
                exception = MException('Parameter:InvalidType','Parameter ''id'' must be a string or numeric.');
                throw(exception);                
            end
            if( ~ischar(method) )
                exception = MException('Parameter:InvalidType','Parameter ''method'' must be a string.');
                throw(exception);                
            end
            
            % -------------------------------------
            %  set instance variables
            % -------------------------------------
            this.id       = id;
            this.method   = method;
            
            if( numvarargs < 1 )
                this.params = [];  %  send empty if no parameters
            else
                this.params   = varargin{1};
            end
        end            
    
    end % constructor methods %


% =============================================================================
%                             Factory Methods
% =============================================================================
    methods (Static)  

        %% --------------------------------------------------------------------
        %   parse
        %% --------------------------------------------------------------------
        function jsonRPC2Request = parse(jsonString)
            % Parse a JSON-RPC 2.0 request string.
            %
            %    Input:  
            %        jsonString:    (string) json string in json-rpc encoding
            %
            %    Output:
            %        jsonRPC2Request  (JSONRPC2Request) - Returns: a single instances 
            %              of JSONRPC2Request class with values from the parsed 
            %              jsonString message
            
            if( ~exist('jsonString','var') )
                exception = MException('Parameter:Missing','Missing required parameter ''jsonString''.');
                throw(exception);                
            end
            if( ~ischar(jsonString) )
                exception = MException('Parameter:InvalidType','Parameter ''jsonString'' must be a string.');
                throw(exception);                
            end

            parser = jsonrpc2.JSONRPC2Parser();
            jsonRPC2Request = parser.parseJSONRPC2Request(jsonString);

        end               

    end % factory methods %


% =============================================================================
%                         Getter/Setter Methods
% =============================================================================
    methods   
    
        %% --------------------------------------------------------------------
        %   get/setID
        %% --------------------------------------------------------------------
        function id = get.id(this)
            if( this.isNotification() ) 
                exception = MException('JsonRpc:UnsupportedMethod','Method get.id is not supported for Notifications.');
                throw(exception);
            end
            id = this.id; 
        end
        function set.id(this,newID)
            is_notification = this.isNotification();
            if( is_notification && ~isempty(newID) ) % must allow setting of empty string to prevent failure in request super-constructor
                exception = MException('JsonRpc:UnsupportedMethod','Method set.id is not supported for Notifications.');
                throw(exception);
            elseif( ~is_notification && isempty(newID) ) % ID must have a value if it is a request
                exception = MException('JsonRpc:BadValue','ID must have a value for Requests.');
                throw(exception);
            end
            this.id = newID; 
        end
                    
        %% --------------------------------------------------------------------
        %   get/setParams
        %% --------------------------------------------------------------------
        function params = get.params(this)
            % Always return retriever class version of params.
            % From the retriever class, call getParams() method to get the raw cell/struct data.
            params = this.params; 
        end
        function set.params(this,newParams)
            % Allow setting from retriever classes or raw cell/struct data.
            if( isnumeric(newParams) && isempty(newParams))
                this.params = jsonrpc2.ParamsRetriever.Factory();
            else
                this.params = jsonrpc2.ParamsRetriever.Factory(newParams);
            end
        end  
   
    end % methods %
        
% =============================================================================
%                             Instance Methods
% =============================================================================
    methods (Access=public)
    
        %% --------------------------------------------------------------------
        %   isNotification
        %% --------------------------------------------------------------------
        function is_notification = isNotification(this)
            % Is this a notification (i.e., a request without an id). 
            %
            %    Input:  
            %        none
            %
            %    Output:
            %        is_notification  (boolean) - Returns: True, if this is a notification; otherwise, false

            is_notification = false;
            if(strcmp(class(this),'jsonrpc2.JSONRPC2Notification')) 
                is_notification = true;
            end

        end                    

        %% --------------------------------------------------------------------
        %   toJSONString
        %% --------------------------------------------------------------------
        function jsonString = toJSONString(this)
            % Return a JSON string representation of this JSON-RPC 2.0 request. 
            %
            %    Input:  
            %        none
            %
            %    Output:
            %        jsonString  (string) - Returns: The JSON object string representing this JSON-RPC 2.0 request.

            % build the structure for jsonlab to interpret
            jsonStruct = struct;
            jsonStruct.jsonrpc = this.JSON_VERSION;
            jsonStruct.id      = this.id;
            jsonStruct.method  = this.method;

            if( this.hasParameters() )
                jsonStruct.params = this.params.getParams();
            end
        
            jsonString = savejson('',jsonStruct);

        end                    
    
    end % methods %

% =============================================================================
%                             Helper Methods
% =============================================================================
    methods (Access=public)
    
       function has_named = hasNamedParameters(this)
            % Does this request have named parameters?
            %
            %    Input:  
            %        none
            %
            %    Output:
            %        has_named  (boolean) - Returns: true if request has named 
            %             parameters; otherwise, false
            has_named = this.params.hasNamedParameters();
       end
       
       function has_positional = hasPositionalParameters(this)
            % Does this request have positional parameters?
            %
            %    Input:  
            %        none
            %
            %    Output:
            %        has_named  (boolean) - Returns: true if request has positional 
            %             parameters; otherwise, false
            has_positional = this.params.hasPositionalParameters();
       end
       
      function has_parameters = hasParameters(this)
            % Does this request have parameters?
            %
            %    Input:  
            %        none
            %
            %    Output:
            %        has_named  (boolean) - Returns: true if request has 
            %             parameters; otherwise, false
            has_parameters = this.params.hasParameters();
      end

      function params = getParams(this)
            % Return any parameters associated with this request.
            %
            %    Input:  
            %        none
            %
            %    Output:
            %        params  (cell/struct) - Returns: params if any exist; 
            %             otherwise, []
            params = [];
            if( this.hasParameters() )
                params = this.params.getParams();
            end
       end
       
    end % methods %

end % classdef %

        
