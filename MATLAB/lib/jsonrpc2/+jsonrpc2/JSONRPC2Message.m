% The base abstract class for JSON-RPC 2.0 requests, notifications and responses. 
% Provides common methods for parsing (from JSON string) and serialisation (to 
% JSON string) of these three message types. 
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

classdef JSONRPC2Message < handle

    properties (Constant)
        JSON_VERSION          = '2.0';  % Supported JSON-RPC version
    end

    properties (SetAccess = private, GetAccess = private)
    end

  
% =============================================================================
%                             Constructor Methods
% =============================================================================
    methods
    
        function this = JSONRPC2Message( )
            % Constructor for JSONRPC2Message class.
            %
            %    Input:  
            %        none
            %
            %    Output:
            %        new instance of this class
            
        end            
    
    end % constructor methods %


% =============================================================================
%                             Factory Methods
% =============================================================================
    methods (Static)  

        %% --------------------------------------------------------------------
        %   parse
        %% --------------------------------------------------------------------
        function jsonRPC2Message = parse(jsonString)
            % Parse a JSON-RPC 2.0 request string.
            % NOTE: It is much more efficient to use the parse method specific to 
            %       the message type if it is known in advance.
            %
            %    Input:  
            %        jsonString:    (string) json string in json-rpc encoding
            %
            %    Output:
            %        jsonRPC2Request  (JSONRPC2Message) - Returns: a single instances 
            %              of JSONRPC2Message class with values from the parsed 
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
            jsonRPC2Message = parser.parseJSONRPC2Message(jsonString);
        end               

    end % factory methods %


% =============================================================================
%                         Getter/Setter Methods
% =============================================================================
    methods (Access=public)
    
    end % methods %
        
% =============================================================================
%                             Instance Methods
% =============================================================================
    methods (Access=public)
    
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
            %        jsonString  (string) - Returns: The JSON object string representing 
            %              this JSON-RPC 2.0 request.

            % Need to use this method in one of the subclasses.  Message parent class has no json fields.
            jsonString = '';
        end                    
    
    end % methods %

end % classdef %

        
