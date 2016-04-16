% Represents a JSON-RPC 2.0 response. 
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

classdef JSONRPC2Response < jsonrpc2.JSONRPC2Message

    properties
        id;       % The same identifier (Number, Boolean, String) or null that came in the request to which this is responding.
        result;   % The result of running the request method.
    end
  
% =============================================================================
%                             Constructor Methods
% =============================================================================
    methods
    
        function this = JSONRPC2Response( id, result )
            % Constructor for JSONRPC2Response class.
            %
            %    Input:  
            %        id:        (string) id connecting this error response to the original
            %                            request
            %        result:    (number) one of the supported error codes (see constants)    
            %
            %    Output:
            %        new instance of this class
    
            % -------------------------------------
            %  check for required parameters
            % -------------------------------------
            if( ~exist('id','var') || ~exist('result','var') )
                exception = MException('Parameter:Missing','Missing one of required parameters: ''id'' and/or ''result''.');
                throw(exception);                
            end
            if( ~ischar(id) && ~isnumeric(id) )
                exception = MException('Parameter:InvalidType','Parameter ''id'' must be a string or numeric.');
                throw(exception);                
            end

            % -------------------------------------
            %  set instance variables
            % -------------------------------------
            this.id        = id;
            this.result   = result;
            
        end            
    
    end % constructor methods %


% =============================================================================
%                             Factory Methods
% =============================================================================
    methods (Static)  

        %% --------------------------------------------------------------------
        %   parse
        %% --------------------------------------------------------------------
        function jsonRPC2Response = parse(jsonString)
            % Parse a JSON-RPC 2.0 response error string.
            %
            %    Input:  
            %        jsonString:    (string) json string in json-rpc encoding
            %
            %    Output:
            %        jsonRPC2Response  (JSONRPC2Response) - Returns: a single instances of 
            %              JSONRPC2Response class with values from the parsed jsonString
            %              message
            
            if( ~exist('jsonString','var') )
                exception = MException('Parameter:Missing','Missing required parameter ''jsonString''.');
                throw(exception);                
            end
            if( ~ischar(jsonString) )
                exception = MException('Parameter:InvalidType','Parameter ''jsonString'' must be a string.');
                throw(exception);                
            end

            parser = jsonrpc2.JSONRPC2Parser();
            jsonRPC2Response = parser.parseJSONRPC2Response(jsonString);

        end               

    end % factory methods %


% =============================================================================
%                             Instance Methods
% =============================================================================
    methods (Access=public)
    
        %% --------------------------------------------------------------------
        %   isError
        %% --------------------------------------------------------------------
        function is_error = isError(this)
            % Is this response an error response. 
            %
            %    Input:  
            %        none
            %
            %    Output:
            %        is_error  (boolean) - Returns: Always returns false for instances of
            %                              JSONRPC2Response.  See also JSONRPC2Error.isError()

            is_error = false;

        end                    

        %% --------------------------------------------------------------------
        %   toJSONString
        %% --------------------------------------------------------------------
        function jsonString = toJSONString(this)
            % Return a JSON string representation of this JSON-RPC 2.0 response. 
            %
            %    Input:  
            %        none
            %
            %    Output:
            %        jsonString  (string) - Returns: The JSON object string representing
            %                               this JSON-RPC 2.0 response.

            % build the structure for jsonlab to interpret
            jsonStruct = struct;
            jsonStruct.jsonrpc = this.JSON_VERSION;
            jsonStruct.id      = this.id;
            jsonStruct.result  = this.result;
        
            jsonString = savejson('',jsonStruct);

        end                    
    
    end % methods %

end % classdef %

        
