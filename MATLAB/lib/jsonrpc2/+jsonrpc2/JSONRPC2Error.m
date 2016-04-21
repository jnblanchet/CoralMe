% Represents a JSON-RPC 2.0 error response. 
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

classdef JSONRPC2Error < jsonrpc2.JSONRPC2Message

    properties
        id        % The same identifier (Number, Boolean, String) or null that came in the request to which this is responding.
        errcode;  % error code  (NOTE: Use one of the constants in the JSONRPC2Error file.)
        errmsg;   % error message
    end

    properties (Constant)
        %-----------------  
        % ERROR CONSTANTS
        %-----------------  
        % jsonrpc 2.0 spec error messages defined at: http://www.jsonrpc.org/specification#response_object  
        
        JSON_INVALID_REQUEST                   = -32600;     % JSON ERROR: Invalid Request  - The JSON sent is not a valid Request object.
        JSON_METHOD_NOT_FOUND                  = -32601;     % JSON ERROR: Method not found - The method does not exist / is not available.
        JSON_INVALID_PARAMS                    = -32602;     % JSON ERROR: Invalid params   - Invalid method parameter(s).
        JSON_INTERNAL_ERROR                    = -32603;     % JSON ERROR: Internal error   - Internal JSON-RPC error.
        JSON_PARSE_ERROR                       = -32700;     % JSON ERROR: Parse error      - Invalid JSON was received by the server.
        % -32000 to rt-32099 - JSON: Server error - Reserved for implementation-defined server-errors.
        
        % additional definitions for JSON: Server errors defined at: http://xmlrpc-epi.sourceforge.net/specs/rfc.fault_codes.php
        
        JSON_TRANSPORT_ERROR                   = -32300;   % XML RPC ERROR: transport error  (error number defined by xmlrpc)
        JSON_SYSTEM_ERROR                      = -32400;   % XML RPC ERROR: system error (error number defined by xmlrpc)
        JSON_APPLICATION_ERROR                 = -32500;   % XML RPC ERROR: application error (error number defined by xmlrpc)
        JSON_PARSE_ERROR_UNSUPPORTED_ENCODING  = -32701;   % XML RPC ERROR: parse error. unsupported encoding (error number defined by xmlrpc)
        JSON_PARSE_ERROR_INVALID_CHAR_ENCODING = -32702;   % XML RPC ERROR: parse error. invalid character for encoding (error number defined by xmlrpc)

        % ---- Application can define these.
        
        JSON_DM_GENERAL_PROCESSING_ERROR = -32000;  % JSON ERROR: -32000 to -32099 - Server error - Reserved for implementation-defined server-errors.
    end

  
% =============================================================================
%                             Constructor Methods
% =============================================================================
    methods
    
        function this = JSONRPC2Error( id, errcode, errmsg )
            % Constructor for JSONRPC2Error class.
            %
            %    Input:  
            %        id:        (string) id connecting this error response to the original request
            %        errcode:   (number) one of the supported error codes (see constants)    
            %        errmsg:    (Object) error message
            %
            %    Output:
            %        new instance of this class
 
            % -------------------------------------
            %  check for required parameters
            % -------------------------------------
            if( ~exist('id','var') || ~exist('errcode','var') || ~exist('errmsg','var') )
                exception = MException('Parameter:Missing','Missing one of required parameters: ''id'' and/or ''method''.');
                throw(exception);                
            end
            if( ~ischar(id) && ~isnumeric(id) )
                exception = MException('Parameter:InvalidType','Parameter ''id'' must be a string or numeric.');
                throw(exception);                
            end
            if( ~isnumeric(errcode) )
                exception = MException('Parameter:InvalidType','Parameter ''errcode'' must be numeric.');
                throw(exception);                
            end
            
            % -------------------------------------
            %  set instance variables
            % -------------------------------------
            this.id        = id;
            this.errcode   = errcode;
            this.errmsg    = errmsg;
            
        end            
    
    end % constructor methods %


% =============================================================================
%                             Factory Methods
% =============================================================================
    methods (Static)  

        %% --------------------------------------------------------------------
        %   parse
        %% --------------------------------------------------------------------
        function jsonRPC2Error = parse(jsonString)
            % Parse a JSON-RPC 2.0 error response string.
            %
            %    Input:  
            %        jsonString:    (string) json string in json-rpc encoding
            %
            %    Output:
            %        jsonRPC2Error  (JSONRPC2Error) - Returns: a single instances 
            %              of JSONRPC2Error class with values from the parsed 
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
            jsonRPC2Error = parser.parseJSONRPC2Response(jsonString);

            if( strcmp(class(jsonRPC2Error),'jsonrpc2.JSONRPCResponse' ) )
                disp('WARNING: JSONRPC2Error.parse() - Expecting to parse response error, but found success response.');
            elseif( ~strcmp(class(jsonRPC2Error),'jsonrpc2.JSONRPC2Error') )
                exception = MException('JsonRpc:InvalidError',[ 'JSON Invalid: Unknown error attempting to parse error response. (',int2str(jsonrpc2.JSONRPC2Error.JSON_PARSE_ERROR),')' ]);
                throw(exception);
            end
        end               

    end % factory methods %


% =============================================================================
%                         Getter/Setter Methods
% =============================================================================
    methods
    
      % using auto-generated methods
                    
    end % methods %
        
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
            %        is_error  (boolean) - Returns: Always returns true for instances of
            %                              JSONRPC2Error.  See also JSONRPC2Response.isError()

            is_error = true;

        end                    

        %% --------------------------------------------------------------------
        %   toJSONString
        %% --------------------------------------------------------------------
        function jsonString = toJSONString(this)
            % Return a JSON string representation of this JSON-RPC 2.0 error response. 
            %
            %    Input:  
            %        none
            %
            %    Output:
            %        jsonString  (string) - Returns: The JSON object string representing 
            %             this JSON-RPC 2.0 error response.

            % build the structure for jsonlab to interpret
            jsonStruct = struct;
            jsonStruct.jsonrpc = this.JSON_VERSION;
            jsonStruct.id      = this.id;
            
            errStruct = struct;
            errStruct.code     = this.errcode;
            errStruct.message  = this.errmsg;
            jsonStruct.error   = errStruct;
        
            jsonString = savejson('',jsonStruct);

        end                    
    
    end % methods %

end % classdef %

        
