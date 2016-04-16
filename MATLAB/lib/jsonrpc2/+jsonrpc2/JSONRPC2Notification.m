% Represents a JSON-RPC 2.0 notification. 
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

classdef JSONRPC2Notification < jsonrpc2.JSONRPC2Request

% =============================================================================
%                             Constructor Methods
% =============================================================================
    methods
    
        function this = JSONRPC2Notification( method, varargin )
            % Constructor for JSONRPC2Notification class.
            %
            %    Input:  
            %        method:    (string) method to call  
            %        params:    (ParamsRetriever) parameters to pass to method
            %
            %    Output:
            %        new instance of this class
    
            % -------------------------------------
            %  check for required parameters
            % -------------------------------------
            if( ~exist('method','var') )
                exception = MException('Parameter:Missing','Missing required parameter ''method''.');
                throw(exception);                
            end
            
            % -------------------------------------
            %  set instance variables
            % -------------------------------------
            this = this@jsonrpc2.JSONRPC2Request('',method,varargin{:});

        end            
    
    end % constructor methods %


% =============================================================================
%                             Factory Methods
% =============================================================================
    methods (Static)  

        %% --------------------------------------------------------------------
        %   parse
        %% --------------------------------------------------------------------
        function jsonRPC2Notification = parse(jsonString)
            % Parse a JSON-RPC 2.0 notification string.
            %
            %    Input:  
            %        jsonString:    (string) json string in json-rpc encoding
            %
            %    Output:
            %        jsonRPC2Notification  (JSONRPC2Notification) - Returns: a single 
            %              instances of JSONRPC2Notification class with values from
            %              the parsed jsonString message.  Will return a JSONRPC2Request 
            %              if an ID is present in the json string.
            
            if( ~exist('jsonString','var') )
                exception = MException('Parameter:Missing','Missing required parameter ''jsonString''.');
                throw(exception);                
            end
            if( ~ischar(jsonString) )
                exception = MException('Parameter:InvalidType','Parameter ''jsonString'' must be a string.');
                throw(exception);                
            end

            parser = jsonrpc2.JSONRPC2Parser();
            jsonRPC2Notification = parser.parseJSONRPC2Notification(jsonString);

            if( isobject(jsonRPC2Notification) || isa(jsonRPC2Notification,'jsonrpc2.JSONRPCRequest'))
                disp('WARNING: JSONRPC2Notification.parse() - Expecting to parse notification, but found request.');
            elseif( ~isobject(jsonRPC2Notification) || isa(jsonRPC2Notification,'jsonrpc2.JSONRPC2Notification'))
                exception = MException('JsonRpc:InvalidNotification',[ 'JSON Invalid: Unknown error attempting to parse notification. (',int2str(jsonrpc2.JSONRPC2Error.JSON_PARSE_ERROR),')' ]);
                throw(exception);
            end
        end               

    end % factory methods %


% =============================================================================
%                         Getter/Setter Methods
% =============================================================================
        
% =============================================================================
%                             Instance Methods
% =============================================================================
    methods (Access=public)
    
        %% --------------------------------------------------------------------
        %   toJSONString
        %% --------------------------------------------------------------------
        function jsonString = toJSONString(this)
            % Return a JSON string representation of this JSON-RPC 2.0 notification. 
            %
            %    Input:  
            %        none
            %
            %    Output:
            %        jsonString  (string) - Returns: The JSON object string representing 
            %            this JSON-RPC 2.0 notification.

            % build the structure for jsonlab to interpret
            jsonStruct = struct;
            jsonStruct.jsonrpc = this.JSON_VERSION;
            jsonStruct.method  = this.method;

            if( this.hasParameters() )
                jsonStruct.params = this.params.getParams();
            end
        
            jsonString = savejson('',jsonStruct);
        end                    
    
    end % methods %

end % classdef %

        
