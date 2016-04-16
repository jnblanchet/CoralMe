% Utility class for retrieving JSON-RPC 2.0 named parameters (key-value pairs packed into a JSON Object). 
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

classdef NamedParamsRetriever < jsonrpc2.ParamsRetriever

  
% =============================================================================
%                             Constructor Methods
% =============================================================================
    methods
    
        function this = NamedParamsRetriever(params)
            % Constructor for NamedParamsRetriever class.
            %
            %    Input:  
            %        params:        (struct) named parameters
            %
            %    Output:
            %        new instance of this class
    
            if( ~exist('params','var') )
                exception = MException('Parameter:Missing','Missing required parameter ''params''.');
                throw(exception);                
            end
            if( ~isstruct(params) )
                exception = MException('Parameter:InvalidType','Parameter ''params'' must be a struct.');
                throw(exception);
            end
            
            this.params = params;
        end            
    
    end % constructor methods %


% =============================================================================
%                         Getter/Setter Methods
% =============================================================================
        
% =============================================================================
%                             Instance Methods
% =============================================================================
    methods (Access=public)
    
        %% --------------------------------------------------------------------
        %   hasParam
        %% --------------------------------------------------------------------
        function has_param = hasParam(this,name)
            % Returns true if a parameter by the specified name exists, else false. 
            %
            %    Input:  
            %        name   (string) - The parameter name. 
            %
            %    Output:
            %        has_param  (boolean) - Returns: true if the parameter exists; otherwise, false.
            
            if( ~exist('name','var') )
                exception = MException('Parameter:Missing','Missing required parameter ''name''.');
                throw(exception);                
            end
            if( ~ischar(name) )
                exception = MException('Parameter:InvalidType','Parameter ''name'' must be a string.');
                throw(exception);
            end

            has_param = false;
            if( isfield(this.params,name) ), has_param = true; end
            
        end % hasParam %
        
    
        %% --------------------------------------------------------------------
        %   get
        %% --------------------------------------------------------------------
        function value = get(this,name)
            % Retrieves the specified parameter which can be of any type.
            %
            %    Input:  
            %        name   (string) - The parameter name. 
            %
            %    Output:
            %        has_param  (boolean) - Returns: true if the parameter exists; otherwise, false.
            
            if( ~exist('name','var') )
                exception = MException('Parameter:Missing','Missing required parameter ''name''.');
                throw(exception);                
            end
            if( ~ischar(name) )
                exception = MException('Parameter:InvalidType','Parameter ''name'' must be a string.');
                throw(exception);
            end

            if( ~this.hasParam(name) )
                exception = MException('NamedParams:InvalidParams',['Missing parameter ',name,'.  (',jsonrpc2.NamedParams.JSON_INVALID_PARAMS,')'] );
                throw(exception);
            end
            value = this.params.(name);
            
        end % get %
        
    
        %% --------------------------------------------------------------------
        %   toJSONString
        %% --------------------------------------------------------------------
        function jsonString = toJSONString(this)
            % Returns a JSON string representation of this set of params for use in a JSON-RPC 2.0 request or notification. 
            % NOTE: Generally not used.  The conversion to JSON string is usually done as part of the request or notification's toJSONString method.
            %
            %    Input:  
            %        none
            %
            %    Output:
            %        jsonString  (string) - Returns: The JSON object string representing the parameters portion of a JSON-RPC 2.0 request or notification.

            jsonString = savejson('',this.params);

        end % toJSONString %       
    
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
           has_named = true;
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
           has_positional = false;
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
           has_parameters = true;
       end
    
    end % methods %
    
% =============================================================================
%                             Protected Methods
% =============================================================================
    methods (Access=protected)
        %% --------------------------------------------------------------------
        %   calculateSize
        %% --------------------------------------------------------------------
        function calc_size = calculateSize(this)
            % Calculates the parameter count.  Used by size getter method.
            %
            %    Input:  
            %        none
            %
            %    Output:
            %        size  (int) - Returns: count of parameters
             
            calc_size = length(fieldnames(this.params)); 
        end


    end % methods %

end % classdef %

        
